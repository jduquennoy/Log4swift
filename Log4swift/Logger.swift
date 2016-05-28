//
//  Logger.swift
//  log4swift
//
//  Created by Jérôme Duquennoy on 14/06/2015.
//  Copyright © 2015 Jérôme Duquennoy. All rights reserved.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//

import Foundation

/**
A logger is identified by a UTI identifier, it defines a threshold level and a destination appender
*/
@objc public final class Logger: NSObject {
  public enum DictionaryKey: String {
    case ThresholdLevel = "ThresholdLevel"
    case AppenderIds = "AppenderIds"
    case Asynchronous = "Asynchronous"
    case ArgOutputLevel = "ArgOutputLevel"
  }
  
  private static let loggingQueue: dispatch_queue_t = {
    let createdQueue = dispatch_queue_create("log4swift.dispatchLoggingQueue", DISPATCH_QUEUE_SERIAL)
    dispatch_set_target_queue(createdQueue, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0))
    return createdQueue
  }()
  
  /// The UTI string that identifies the logger. Example : product.module.feature
  public let identifier: String
  
  internal var parent: Logger?
  
  private var thresholdLevelStorage: LogLevel
  private var appendersStorage: [Appender]
  private var asynchronousStorage = false
  private var argOutputLevelStorage: ArgOutputLevel

  /// If asynchronous is true, only the minimum of work will be done on the main thread, the rest will be deffered to a low priority background thread.
  /// The order of the messages will be preserved in async mode.
  public var asynchronous: Bool {
    get {
      if let parent = self.parent {
        return parent.asynchronous
      } else {
        return self.asynchronousStorage
      }
    }
    set {
      self.breakDependencyWithParent()
      self.asynchronousStorage = newValue
    }
  }
  
  /// The threshold under which log messages will be ignored.
  /// For example, if the threshold is Warning:
  /// * logs issued with a Debug or Info will be ignored
  /// * logs issued wiht a Warning, Error or Fatal level will be processed
  public var thresholdLevel: LogLevel {
    get {
      if let parent = self.parent {
        return parent.thresholdLevel
      } else {
        return self.thresholdLevelStorage
      }
    }
    set {
      self.breakDependencyWithParent()
      self.thresholdLevelStorage = newValue
    }
  }

  /// The list of destination appenders for the log messages.
  public var appenders: [Appender] {
    get {
      if let parent = self.parent {
        return parent.appenders
      } else {
        return self.appendersStorage
      }
    }
    set {
      self.breakDependencyWithParent()
      self.appendersStorage = newValue
    }
  }
  
  /// The argument output level defining how arguments are logged.
  public var argOutputLevel: ArgOutputLevel {
    get {
      if let parent = self.parent {
        return parent.argOutputLevel
      } else {
        return self.argOutputLevelStorage
      }
    }
    set {
      self.breakDependencyWithParent()
      self.argOutputLevelStorage = newValue
    }
  }

  
  /// Creates a new logger with the given identifier, log level and appenders.
  /// The identifier will not be modifiable, and should not be an empty string.
  public init(identifier: String, level: LogLevel = LogLevel.Debug, argOutputLevel: ArgOutputLevel = ArgOutputLevel.Off, appenders: [Appender] = []) {
    self.identifier = identifier
    self.thresholdLevelStorage = level
    self.appendersStorage = appenders
    self.argOutputLevelStorage = argOutputLevel
  }

  convenience override init() {
    self.init(identifier: "", appenders: Logger.createDefaultAppenders())
  }
  
  /// Create a logger that is a child of the given logger.
  /// The created logger will follow the parent logger's configuration until it is manually modified.
  convenience init(parentLogger: Logger, identifier: String) {
    self.init(identifier: identifier, level: parentLogger.thresholdLevel, argOutputLevel: parentLogger.argOutputLevel, appenders: [Appender]() + parentLogger.appenders)
    self.parent = parentLogger
  }
  
  /// Updates the logger with the content of the configuration dictionary.
  internal func updateWithDictionary(dictionary: Dictionary<String, AnyObject>, availableAppenders: Array<Appender>) throws {
    breakDependencyWithParent()
    
    if let safeLevelString = dictionary[DictionaryKey.ThresholdLevel.rawValue] as? String {
      if let safeLevel = LogLevel(safeLevelString) {
        self.thresholdLevel = safeLevel
      } else {
        throw NSError.Log4swiftErrorWithDescription("Invalid '\(DictionaryKey.ThresholdLevel.rawValue)' value for logger '\(self.identifier)'")
      }
    }
    
    if let appenderIds = dictionary[DictionaryKey.AppenderIds.rawValue] as? Array<String> {
      appendersStorage.removeAll()
      for currentAppenderId in appenderIds {
        if let foundAppender = availableAppenders.find({$0.identifier == currentAppenderId}) {
          appendersStorage.append(foundAppender)
        } else {
          throw NSError.Log4swiftErrorWithDescription("No such appender '\(currentAppenderId)' for logger \(self.identifier)")
        }
      }
    }
    
    if let asynchronous = dictionary[DictionaryKey.Asynchronous.rawValue] as? Bool {
      self.asynchronous = asynchronous
    }
    
    if let safeArgOutputString = dictionary[DictionaryKey.ArgOutputLevel.rawValue] as? String {
      if let safeArgOutputLevel = ArgOutputLevel(safeArgOutputString) {
        self.argOutputLevel = safeArgOutputLevel
      } else {
        throw NSError.Log4swiftErrorWithDescription("Invalid '\(DictionaryKey.ArgOutputLevel.rawValue)' value for logger '\(self.identifier)'")
      }
    }
  }
  
  func resetConfiguration() {
    self.thresholdLevel = .Debug
    self.argOutputLevel = .Off
    self.appenders = Logger.createDefaultAppenders()
    self.asynchronousStorage = false
  }
  
  // MARK: Logging methods

  /// Logs the entering of a function and its parameters with a trace level
  @nonobjc public func entering(args: Any..., file: String = #file, line: Int = #line, function: String = #function) {
    if (!self.willIssueLogForLevel(.Trace)) {
      return
    }
    
    self.logEnteringInternal(file: file, line: line, function: function, args: args)
  }
  /// Logs the exiting of a function and its return values with a trace level
  @nonobjc public func exiting(args: Any..., file: String = #file, line: Int = #line, function: String = #function) {
    if (!self.willIssueLogForLevel(.Trace)) {
      return
    }
    
    self.logExitingInternal(file: file, line: line, function: function, args: args)
  }
  /// Logs the message and the given values according to the argOutputLevel of the logger with a trace level
  @nonobjc public func values(message message:String = "", _ args: Any..., file: String = #file, line: Int = #line, function: String = #function) {
    if (!self.willIssueLogForLevel(.Trace)) {
      return
    }
    
    self.logValuesInternal(message: message, file: file, line: line, function: function, args: args)
  }
  /// Logs the provided message with a trace level.
  @nonobjc public func trace(format: String, file: String = #file, line: Int = #line, function: String = #function, _ args: CVarArgType...) {
    let formattedMessage = format.format(args)
    self.log(formattedMessage, level: LogLevel.Trace, file: file, line: line, function: function)
  }
  /// Logs the provided message with a debug level.
  @nonobjc public func debug(format: String, file: String = #file, line: Int = #line, function: String = #function, _ args: CVarArgType...) {
    let formattedMessage = format.format(args)
    self.log(formattedMessage, level: LogLevel.Debug, file: file, line: line, function: function)
  }
  /// Logs the provided message with an info level
  @nonobjc public func info(format: String, file: String = #file, line: Int = #line, function: String = #function, _ args: CVarArgType...) {
    let formattedMessage = format.format(args)
    self.log(formattedMessage, level: LogLevel.Info, file: file, line: line, function: function)
  }
  /// Logs the provided message with a warning level
  @nonobjc public func warning(format: String, file: String = #file, line: Int = #line, function: String = #function, _ args: CVarArgType...) {
    let formattedMessage = format.format(args)
    self.log(formattedMessage, level: LogLevel.Warning, file: file, line: line, function: function)
  }
  /// Logs the provided message with an error level
  @nonobjc public func error(format: String, file: String = #file, line: Int = #line, function: String = #function, _ args: CVarArgType...) {
    let formattedMessage = format.format(args)
    self.log(formattedMessage, level: LogLevel.Error, file: file, line: line, function: function)
  }
  /// Logs the provided message with a fatal level
  @nonobjc public func fatal(format: String, file: String = #file, line: Int = #line, function: String = #function, _ args: CVarArgType...) {
    let formattedMessage = format.format(args)
    self.log(formattedMessage, level: LogLevel.Fatal, file: file, line: line, function: function)
  }
  
  /// Logs the entering of a function and its parameters returned by the closure with a trace level
  /// If the logger's or appender's configuration prevents the message to be issued, the closure will not be called.
  @nonobjc public func entering(file file: String = #file, line: Int = #line, function: String = #function, closure: () -> [Any]) {
    self.logEnteringInternal(file: file, line: line, function: function, closure: closure)
  }
  /// Logs the exiting of a function and its return values returned by the closure with a trace level
  /// If the logger's or appender's configuration prevents the message to be issued, the closure will not be called.
  @nonobjc public func exiting(file file: String = #file, line: Int = #line, function: String = #function, closure: () -> [Any]) {
    self.logExitingInternal(file: file, line: line, function: function, closure: closure)
  }
  /// Logs the message and the given values according to the argOutputLevel of the logger with a trace level
  /// If the logger's or appender's configuration prevents the message to be issued, the closure will not be called.
  @nonobjc public func values(message message: String = "", file: String = #file, line: Int = #line, function: String = #function, closure: () -> [Any]) {
    self.logValuesInternal(message: message, file: file, line: line, function: function, closure: closure)
  }
  /// Logs a the message returned by the closure with a debug level
  /// If the logger's or appender's configuration prevents the message to be issued, the closure will not be called.
  @nonobjc public func trace(file: String = #file, line: Int = #line, function: String = #function, closure: () -> String) {
    self.log(closure, level: LogLevel.Trace, file: file, line: line, function: function)
  }
  /// Logs a the message returned by the closure with a debug level
  /// If the logger's or appender's configuration prevents the message to be issued, the closure will not be called.
  @nonobjc public func debug(file: String = #file, line: Int = #line, function: String = #function, closure: () -> String) {
    self.log(closure, level: LogLevel.Debug, file: file, line: line, function: function)
  }
  /// Logs a the message returned by the closure with an info level
  /// If the logger's or appender's configuration prevents the message to be issued, the closure will not be called.
  @nonobjc public func info(file: String = #file, line: Int = #line, function: String = #function, closure: () -> String) {
    self.log(closure, level: LogLevel.Info, file: file, line: line, function: function)
  }
  /// Logs a the message returned by the closure with a warning level
  /// If the logger's or appender's configuration prevents the message to be issued, the closure will not be called.
  @nonobjc public func warning(file: String = #file, line: Int = #line, function: String = #function, closure: () -> String) {
    self.log(closure, level: LogLevel.Warning, file: file, line: line, function: function)
  }
  /// Logs a the message returned by the closure with an error level
  /// If the logger's or appender's configuration prevents the message to be issued, the closure will not be called.
  @nonobjc public func error(file: String = #file, line: Int = #line, function: String = #function, closure: () -> String) {
    self.log(closure, level: LogLevel.Error, file: file, line: line, function: function)
  }
  /// Logs a the message returned by the closure with a fatal level
  /// If the logger's or appender's configuration prevents the message to be issued, the closure will not be called.
  @nonobjc public func fatal(file: String = #file, line: Int = #line, function: String = #function, closure: () -> String) {
    self.log(closure, level: LogLevel.Fatal, file: file, line: line, function: function)
  }
  
  /// Returns true if a message sent with the given level will be issued by at least one appender.
  public func willIssueLogForLevel(level: LogLevel) -> Bool {
    return level.rawValue >= self.thresholdLevel.rawValue && self.appenders.reduce(false) { (shouldLog, currentAppender) in
      shouldLog || level.rawValue >= currentAppender.thresholdLevel.rawValue
    }
  }
  
  @nonobjc internal func log(message: String, level: LogLevel, file: String? = nil, line: Int? = nil, function: String? = nil) {
    if(self.willIssueLogForLevel(level)) {
      var info: LogInfoDictionary = [
        .LoggerName: self.identifier,
        .LogLevel: level,
        .Timestamp: getSecondsSince1970()
      ]
      if let file = file {
        info[.FileName] = file
      }
      if let line = line {
        info[.FileLine] = line
      }
      if let function = function {
        info[.Function] = function
      }

      let logClosure = {
        for currentAppender in self.appenders {
          currentAppender.log(message, level: level, info: info)
        }
      }

      self.executeLogClosure(logClosure)
    }
  }
  
  @nonobjc internal func log(closure: () -> (String), level: LogLevel, file: String? = nil, line: Int? = nil, function: String? = nil) {
    if(self.willIssueLogForLevel(level)) {
      var info: LogInfoDictionary = [
        .LoggerName: self.identifier,
        .LogLevel: level,
        .Timestamp: getSecondsSince1970()
      ]
      if let file = file {
        info[.FileName] = file
      }
      if let line = line {
        info[.FileLine] = line
      }
      if let function = function {
        info[.Function] = function
      }

      let logClosure = {
        let logMessage = closure()
        for currentAppender in self.appenders {
          currentAppender.log(logMessage, level: level, info: info)
        }
      }
      self.executeLogClosure(logClosure)
    }
  }
  
  @nonobjc internal func logEnteringInternal(file file: String? = nil, line: Int? = nil, function: String? = nil, closure: () -> [Any]) {
    if (!self.willIssueLogForLevel(.Trace)) {
      return
    }
    
    let args = closure()
    
    self.logEnteringInternal(file: file, line: line, function: function, args: args)
  }
  
  @nonobjc internal func logEnteringInternal(file file: String? = nil, line: Int? = nil, function: String? = nil, closure: () -> [AnyObject]) {
    if (!self.willIssueLogForLevel(.Trace)) {
      return
    }
    
    let objects = closure()
    var args = [Any]()
    
    for o in objects {
      args.append(o)
    }
    
    self.logEnteringInternal(file: file, line: line, function: function, args: args)
  }
  
  @nonobjc internal func logEnteringInternal(file file: String? = nil, line: Int? = nil, function: String? = nil, objArgs: [AnyObject]) {
    if (!self.willIssueLogForLevel(.Trace)) {
      return
    }
    
    var objects = [Any]()
    
    for o in objArgs {
      objects.append(o)
    }
    
    self.logEnteringInternal(file: file, line: line, function: function, args: objects)
  }
  
  @nonobjc internal func logEnteringInternal(file file: String? = nil, line: Int? = nil, function: String? = nil, args: [Any]) {
    if (!self.willIssueLogForLevel(.Trace)) {
      return
    }
    
    var message = "ENTERING - "
    
    let numArgs = args.count
    
    if (numArgs == 0) {
      message += "without parameters"
    } else if (numArgs == 1) {
      message += "with 1 parameter"
    } else {
      message += "with \(numArgs) parameters"
    }
    
    if self.argOutputLevel.rawValue >= ArgOutputLevel.ValueOnly.rawValue && numArgs > 0 {
      message += ": "
      message += dumpArguments(args)
    }
    
    self.log(message, level: .Trace, file: file, line: line, function: function)
  }
  
  @nonobjc internal func logExitingInternal(file file: String? = nil, line: Int? = nil, function: String? = nil, closure: () -> [Any]) {
    if (!self.willIssueLogForLevel(.Trace)) {
      return
    }
    
    let args = closure()
    
    self.logExitingInternal(file: file, line: line, function: function, args: args)
  }
  
  @nonobjc internal func logExitingInternal(file file: String? = nil, line: Int? = nil, function: String? = nil, closure: () -> [AnyObject]) {
    if (!self.willIssueLogForLevel(.Trace)) {
      return
    }
    
    let objects = closure()
    var args = [Any]()
    
    for o in objects {
      args.append(o)
    }
    
    self.logExitingInternal(file: file, line: line, function: function, args: args)
  }
  
  @nonobjc internal func logExitingInternal(file file: String? = nil, line: Int? = nil, function: String? = nil, objArgs: [AnyObject]) {
    if (!self.willIssueLogForLevel(.Trace)) {
      return
    }
    
    var objects = [Any]()
    
    for o in objArgs {
      objects.append(o)
    }
    
    self.logExitingInternal(file: file, line: line, function: function, args: objects)
  }
  
  @nonobjc internal func logExitingInternal(file file: String? = nil, line: Int? = nil, function: String? = nil, args: [Any]) {
    if (!self.willIssueLogForLevel(.Trace)) {
      return
    }
    
    var message = "EXITING - "
    
    let numArgs = args.count
    
    if (numArgs == 0) {
      message += "without return value"
    } else if (numArgs == 1) {
      message += "with 1 return value"
    } else {
      message += "with \(numArgs) return values"
    }
    
    if self.argOutputLevel.rawValue >= ArgOutputLevel.ValueOnly.rawValue && numArgs > 0 {
      message += ": "
      message += dumpArguments(args)
    }
    
    self.log(message, level: .Trace, file: file, line: line, function: function)
  }
  
  @nonobjc internal func logValuesInternal(message message: String?, file: String? = nil, line: Int? = nil, function: String? = nil, closure: () -> [Any]) {
    if (!self.willIssueLogForLevel(.Trace)) {
      return
    }
    
    let args = closure()
    
    self.logValuesInternal(message: message, file: file, line: line, function: function, args: args)
  }
  
  @nonobjc internal func logValuesInternal(message message: String?, file: String? = nil, line: Int? = nil, function: String? = nil, closure: () -> [AnyObject]) {
    if (!self.willIssueLogForLevel(.Trace)) {
      return
    }
    
    let objects = closure()
    var args = [Any]()
    
    for o in objects {
      args.append(o)
    }
    
    self.logValuesInternal(message: message, file: file, line: line, function: function, args: args)
  }
  
  @nonobjc internal func logValuesInternal(message message: String?, file: String? = nil, line: Int? = nil, function: String? = nil, objArgs: [AnyObject]) {
    if (!self.willIssueLogForLevel(.Trace)) {
      return
    }
    
    var objects = [Any]()
    
    for o in objArgs {
      objects.append(o)
    }
    
    self.logValuesInternal(message: message, file: file, line: line, function: function, args: objects)
  }
  
  @nonobjc internal func logValuesInternal(message message: String?, file: String? = nil, line: Int? = nil, function: String? = nil, args: [Any]) {
    if (!self.willIssueLogForLevel(.Trace)) {
      return
    }
    
    var theMessage = message ?? ""
    
    if self.argOutputLevel.rawValue >= ArgOutputLevel.ValueOnly.rawValue && args.count > 0 {
      if !theMessage.isEmpty {
        theMessage += ": "
      }
      
      theMessage += dumpArguments(args)
    }
    
    if theMessage.isEmpty {
      return
    }
    
    self.log(theMessage, level: .Trace, file: file, line: line, function: function)
  }
  
  // MARK: Private methods
  private func executeLogClosure(logClosure: () -> ()) {
    if(self.asynchronous) {
      dispatch_async(Logger.loggingQueue, logClosure)
    } else {
      logClosure()
    }
  }
  
  private func breakDependencyWithParent() {
    guard let parent = self.parent else {
      return
    }
    self.thresholdLevelStorage = parent.thresholdLevel
    self.appendersStorage = parent.appenders
    self.parent = nil
  }
  
  
  private func dumpArguments(args: [Any]) -> String {
    if (self.argOutputLevel.rawValue < ArgOutputLevel.ValueOnly.rawValue || args.isEmpty) {
      return ""
    }
    
    //let arguments = RemoveStackedArrays(args)
    
    var result = ""
    var isFirst = true
    
    for arg in args {
      if (!isFirst) {
        result += ", "
      }
      else {
        isFirst = false
      }
      
      if (self.argOutputLevel.rawValue >= ArgOutputLevel.ValueWithType.rawValue) {
        let argMirror = Mirror(reflecting: arg)
        
        print(argMirror.subjectType, separator: "", terminator: "", toStream: &result)
        
        result += ": "
      }
      
      debugPrint(arg, separator: "", terminator: "", toStream: &result)
    }
    
    return result
  }
  
  private func RemoveStackedArrays(array: [Any]) -> [Any] {
    if array.count == 1 {
      if let stackedArray = array[0] as? [Any] {
        return RemoveStackedArrays(stackedArray)
      }
    }
    
    return array
  }
  
  private final class func createDefaultAppenders() -> [Appender] {
    return [StdOutAppender("defaultAppender")]
  }
}
