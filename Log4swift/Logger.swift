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
  }
  
  private static let loggingQueue:DispatchQueue = {
    let createdQueue: DispatchQueue
    
    if #available(OSX 10.10, *) {
      createdQueue = DispatchQueue(label: "log4swift.dispatchLoggingQueue", qos: .background, attributes: []) //(label: "log4swift.dispatchLoggingQueue", attributes: [.serial, .background])
    } else {
      let backgroundQueue = DispatchQueue.global(priority: .background)
      createdQueue = DispatchQueue(label: "log4swift.dispatchLoggingQueue", attributes: [], target: backgroundQueue)
    }
    return createdQueue
  }()
  
  /// The UTI string that identifies the logger. Example : product.module.feature
  public let identifier: String
  
  internal var parent: Logger?
  
  private var thresholdLevelStorage: LogLevel
  private var appendersStorage: [Appender]
  private var asynchronousStorage = false

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

  
  /// Creates a new logger with the given identifier, log level and appenders.
  /// The identifier will not be modifiable, and should not be an empty string.
  public init(identifier: String, level: LogLevel = LogLevel.Debug, appenders: [Appender] = []) {
    self.identifier = identifier
    self.thresholdLevelStorage = level
    self.appendersStorage = appenders
  }

  convenience override init() {
    self.init(identifier: "", appenders: Logger.createDefaultAppenders())
  }
  
  /// Create a logger that is a child of the given logger.
  /// The created logger will follow the parent logger's configuration until it is manually modified.
  public convenience init(parentLogger: Logger, identifier: String) {
    self.init(identifier: identifier, level: parentLogger.thresholdLevel, appenders: [Appender]() + parentLogger.appenders)
    self.parent = parentLogger
  }
  
  /// Updates the logger with the content of the configuration dictionary.
  internal func update(withDictionary dictionary: Dictionary<String, Any>, availableAppenders: Array<Appender>) throws {
    breakDependencyWithParent()
    
    if let safeLevelString = dictionary[DictionaryKey.ThresholdLevel.rawValue] as? String {
      if let safeLevel = LogLevel(safeLevelString) {
        self.thresholdLevel = safeLevel
      } else {
				throw NSError.Log4swiftError(description: "Invalid '\(DictionaryKey.ThresholdLevel.rawValue)' value for logger '\(self.identifier)'")
      }
    }
    
    if let appenderIds = dictionary[DictionaryKey.AppenderIds.rawValue] as? Array<String> {
      appendersStorage.removeAll()
      for currentAppenderId in appenderIds {
				if let foundAppender = availableAppenders.find(filter: {$0.identifier == currentAppenderId}) {
          appendersStorage.append(foundAppender)
        } else {
          throw NSError.Log4swiftError(description: "No such appender '\(currentAppenderId)' for logger \(self.identifier)")
        }
      }
    }
    
    if let asynchronous = dictionary[DictionaryKey.Asynchronous.rawValue] as? Bool {
      self.asynchronous = asynchronous
    }
  }
  
  func resetConfiguration() {
    self.thresholdLevel = .Debug
    self.appenders = Logger.createDefaultAppenders()
    self.asynchronousStorage = false
  }
  
  // MARK: Logging methods

  /// Logs the provided message with a trace level.
  @nonobjc public func trace(_ format: String, _ args: CVarArg..., file: String = #file, line: Int = #line, function: String = #function) {
		let formattedMessage = format.format(args: args)
		self.log(message: formattedMessage, level: LogLevel.Trace, file: file, line: line, function: function)
  }
  /// Logs the provided message with a debug level.
  @nonobjc public func debug(_ format: String, _ args: CVarArg..., file: String = #file, line: Int = #line, function: String = #function) {
    let formattedMessage = format.format(args: args)
    self.log(message: formattedMessage, level: LogLevel.Debug, file: file, line: line, function: function)
  }
  /// Logs the provided message with an info level
  @nonobjc public func info(_ format: String, _ args: CVarArg..., file: String = #file, line: Int = #line, function: String = #function) {
    let formattedMessage = format.format(args: args)
    self.log(message: formattedMessage, level: LogLevel.Info, file: file, line: line, function: function)
  }
  /// Logs the provided message with a warning level
  @nonobjc public func warning(_ format: String, _ args: CVarArg..., file: String = #file, line: Int = #line, function: String = #function) {
    let formattedMessage = format.format(args: args)
    self.log(message: formattedMessage, level: LogLevel.Warning, file: file, line: line, function: function)
  }
  /// Logs the provided message with an error level
  @nonobjc public func error(_ format: String, _ args: CVarArg..., file: String = #file, line: Int = #line, function: String = #function) {
    let formattedMessage = format.format(args: args)
    self.log(message: formattedMessage, level: LogLevel.Error, file: file, line: line, function: function)
  }
  /// Logs the provided message with a fatal level
  @nonobjc public func fatal(_ format: String, _ args: CVarArg..., file: String = #file, line: Int = #line, function: String = #function) {
    let formattedMessage = format.format(args: args)
    self.log(message: formattedMessage, level: LogLevel.Fatal, file: file, line: line, function: function)
  }

  /// Logs a the message returned by the closure with a debug level
  /// If the logger's or appender's configuration prevents the message to be issued, the closure will not be called.
  @nonobjc public func trace(file: String = #file, line: Int = #line, function: String = #function, closure: @escaping () -> String) {
		self.log(closure: closure, level: LogLevel.Trace, file: file, line: line, function: function)
  }
  /// Logs a the message returned by the closure with a debug level
  /// If the logger's or appender's configuration prevents the message to be issued, the closure will not be called.
  @nonobjc public func debug(file: String = #file, line: Int = #line, function: String = #function, closure: @escaping () -> String) {
    self.log(closure: closure, level: LogLevel.Debug, file: file, line: line, function: function)
  }
  /// Logs a the message returned by the closure with an info level
  /// If the logger's or appender's configuration prevents the message to be issued, the closure will not be called.
  @nonobjc public func info(file: String = #file, line: Int = #line, function: String = #function, closure: @escaping () -> String) {
    self.log(closure: closure, level: LogLevel.Info, file: file, line: line, function: function)
  }
  /// Logs a the message returned by the closure with a warning level
  /// If the logger's or appender's configuration prevents the message to be issued, the closure will not be called.
  @nonobjc public func warning(file: String = #file, line: Int = #line, function: String = #function, closure: @escaping () -> String) {
    self.log(closure: closure, level: LogLevel.Warning, file: file, line: line, function: function)
  }
  /// Logs a the message returned by the closure with an error level
  /// If the logger's or appender's configuration prevents the message to be issued, the closure will not be called.
  @nonobjc public func error(file: String = #file, line: Int = #line, function: String = #function, closure: @escaping () -> String) {
    self.log(closure: closure, level: LogLevel.Error, file: file, line: line, function: function)
  }
  /// Logs a the message returned by the closure with a fatal level
  /// If the logger's or appender's configuration prevents the message to be issued, the closure will not be called.
  @nonobjc public func fatal(file: String = #file, line: Int = #line, function: String = #function, closure: @escaping () -> String) {
    self.log(closure: closure, level: LogLevel.Fatal, file: file, line: line, function: function)
  }
  
  /// Returns true if a message sent with the given level will be issued by at least one appender.
  public func willIssueLogForLevel(_ level: LogLevel) -> Bool {
    return level.rawValue >= self.thresholdLevel.rawValue && self.appenders.reduce(false) { (shouldLog, currentAppender) in
      shouldLog || level.rawValue >= currentAppender.thresholdLevel.rawValue
    }
  }
  
  @nonobjc internal func log(message: String, level: LogLevel, file: String? = nil, line: Int? = nil, function: String? = nil) {
    if(self.willIssueLogForLevel(level)) {
      var info: LogInfoDictionary = [
        .LoggerName: self.identifier,
        .LogLevel: level,
        .Timestamp: NSDate().timeIntervalSince1970,
        .ThreadId: currentThreadId(),
        .ThreadName: currentThreadName()
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
					currentAppender.log(message, level:level, info: info)
        }
      }

      self.executeLogClosure(logClosure)
    }
  }
  
  @nonobjc internal func log(closure: @escaping () -> (String), level: LogLevel, file: String? = nil, line: Int? = nil, function: String? = nil) {
    if(self.willIssueLogForLevel(level)) {
      var info: LogInfoDictionary = [
        .LoggerName: self.identifier,
        .LogLevel: level,
        .Timestamp: NSDate().timeIntervalSince1970,
        .ThreadId: currentThreadId(),
        .ThreadName: currentThreadName()
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
					currentAppender.log(logMessage, level:level, info: info)
        }
      }
      self.executeLogClosure(logClosure)
    }
  }
  
  // MARK: Private methods
  private func executeLogClosure(_ logClosure: @escaping () -> ()) {
    if(self.asynchronous) {
      Logger.loggingQueue.async(execute: logClosure)
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

  private final class func createDefaultAppenders() -> [Appender] {
    return [StdOutAppender("defaultAppender")]
  }
}

/// returns the current thread name
private func currentThreadName() -> String {
  if Thread.isMainThread {
    return "main"
  } else {
    var name: String = Thread.current.name ?? ""
    if name.isEmpty {
      let queueNameBytes = __dispatch_queue_get_label(nil)
      if let queuName = String(validatingUTF8: queueNameBytes) {
        name = queuName
      }
    }
    if name.isEmpty {
      name = String(format: "%p", Thread.current)
    }
    
    return name
  }
}

internal func currentThreadId() -> UInt64 {
  var threadId: UInt64 = 0
  if (pthread_threadid_np(nil, &threadId) != 0) {
    threadId = UInt64(pthread_mach_thread_np(pthread_self()));
  }
  return threadId
}
