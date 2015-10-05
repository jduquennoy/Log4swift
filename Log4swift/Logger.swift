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

import Foundation;

/**
A logger is identified by a UTI identifier, it defines a threshold level and a destination appender
*/
@objc public final class Logger: NSObject {
  public enum DictionaryKey: String {
    case ThresholdLevel = "ThresholdLevel"
    case AppenderIds = "AppenderIds"
  }
  
  /// The UTI string that identifies the logger. Example : product.module.feature
  public let identifier: String;

  internal var parent: Logger?;
  
  private var thresholdLevelStorage: LogLevel;
  private var appendersStorage: [Appender];

  /// The threshold under which log messages will be ignored.
  /// For example, if the threshold is Warning:
  /// * logs issued with a Debug or Info will be ignored
  /// * logs issued wiht a Warning, Error or Fatal level will be processed
  public var thresholdLevel: LogLevel {
    get {
      if let parent = self.parent {
        return parent.thresholdLevel;
      } else {
        return self.thresholdLevelStorage;
      }
    }
    set {
      self.breakDependencyWithParent();
      self.thresholdLevelStorage = newValue;
    }
  };

  /// The list of destination appenders for the log messages.
  public var appenders: [Appender] {
    get {
      if let parent = self.parent {
        return parent.appenders;
      } else {
        return self.appendersStorage;
      }
    }
    set {
      self.breakDependencyWithParent();
      self.appendersStorage = newValue;
    }
  };

  
  /// Creates a new logger with the given identifier, log level and appenders.
  /// The identifier will not be modifiable, and should not be an empty string.
  public init(identifier: String, level: LogLevel = LogLevel.Debug, appenders: [Appender] = []) {
    self.identifier = identifier;
    self.thresholdLevelStorage = level;
    self.appendersStorage = appenders;
  }

  convenience override init() {
    self.init(identifier: "", appenders: Logger.createDefaultAppenders());
  }
  
  /// Create a logger that is a child of the given logger.
  /// The created logger will follow the parent logger's configuration until it is manually modified.
  convenience init(parentLogger: Logger, identifier: String) {
    self.init(identifier: identifier, level: parentLogger.thresholdLevel, appenders: [Appender]() + parentLogger.appenders);
    self.parent = parentLogger;
  }
  
  /// Updates the logger with the content of the configuration dictionary.
  internal func updateWithDictionary(dictionary: Dictionary<String, AnyObject>, availableAppenders: Array<Appender>) throws {
    breakDependencyWithParent();
    
    if let safeLevelString = dictionary[DictionaryKey.ThresholdLevel.rawValue] as? String {
      if let safeLevel = LogLevel(safeLevelString) {
        self.thresholdLevel = safeLevel;
      } else {
        throw InvalidOrMissingParameterException("Invalid '\(DictionaryKey.ThresholdLevel.rawValue)' value for logger '\(self.identifier)'");
      }
    }
    
    if let appenderIds = dictionary[DictionaryKey.AppenderIds.rawValue] as? Array<String> {
      appendersStorage.removeAll();
      for currentAppenderId in appenderIds {
        if let foundAppender = availableAppenders.find({$0.identifier == currentAppenderId}) {
          appendersStorage.append(foundAppender);
        } else {
          throw InvalidOrMissingParameterException("No such appender '\(currentAppenderId)' for logger \(self.identifier)");
        }
      }
    }
  }
  
  func resetConfiguration() {
    self.thresholdLevel = .Debug;
    self.appenders = Logger.createDefaultAppenders();
  }
  
  // MARK: Logging methods
  
  /// Logs the provided message with a debug level.
  @nonobjc public func debug(format: String, file: String = __FILE__, line: Int = __LINE__, _ args: CVarArgType...) {
    self.log(format.format(getVaList(args)), level: LogLevel.Debug, file: file, line: line);
  }
  /// Logs the provided message with an info level
  @nonobjc public func info(format: String, file: String = __FILE__, line: Int = __LINE__, _ args: CVarArgType...) {
    self.log(format.format(getVaList(args)), level: LogLevel.Info, file: file, line: line);
  }
  /// Logs the provided message with a warning level
  @nonobjc public func warning(format: String, file: String = __FILE__, line: Int = __LINE__, _ args: CVarArgType...) {
    self.log(format.format(getVaList(args)), level: LogLevel.Warning, file: file, line: line);
  }
  /// Logs the provided message with an error level
  @nonobjc public func error(format: String, file: String = __FILE__, line: Int = __LINE__, _ args: CVarArgType...) {
    self.log(format.format(getVaList(args)), level: LogLevel.Error, file: file, line: line);
  }
  /// Logs the provided message with a fatal level
  @nonobjc public func fatal(format: String, file: String = __FILE__, line: Int = __LINE__, _ args: CVarArgType...) {
    self.log(format.format(getVaList(args)), level: LogLevel.Fatal, file: file, line: line);
  }
  
  /// Logs a the message returned by the closer with a debug level
  /// If the logger's or appender's configuration prevents the message to be issued, the closure will not be called.
  @nonobjc public func debug(file: String = __FILE__, line: Int = __LINE__, closure: () -> String) {
    self.log(closure, level: LogLevel.Debug, file: file, line: line);
  }
  /// Logs a the message returned by the closer with an info level
  /// If the logger's or appender's configuration prevents the message to be issued, the closure will not be called.
  @nonobjc public func info(file: String = __FILE__, line: Int = __LINE__, closure: () -> String) {
    self.log(closure, level: LogLevel.Info, file: file, line: line);
  }
  /// Logs a the message returned by the closer with a warning level
  /// If the logger's or appender's configuration prevents the message to be issued, the closure will not be called.
  @nonobjc public func warning(file: String = __FILE__, line: Int = __LINE__, closure: () -> String) {
    self.log(closure, level: LogLevel.Warning, file: file, line: line);
  }
  /// Logs a the message returned by the closer with an error level
  /// If the logger's or appender's configuration prevents the message to be issued, the closure will not be called.
  @nonobjc public func error(file: String = __FILE__, line: Int = __LINE__, closure: () -> String) {
    self.log(closure, level: LogLevel.Error, file: file, line: line);
  }
  /// Logs a the message returned by the closer with a fatal level
  /// If the logger's or appender's configuration prevents the message to be issued, the closure will not be called.
  @nonobjc public func fatal(file: String = __FILE__, line: Int = __LINE__, closure: () -> String) {
    self.log(closure, level: LogLevel.Fatal, file: file, line: line);
  }
  
  /// Returns true if a message sent with the given level will be issued by at least one appender.
  public func willIssueLogForLevel(level: LogLevel) -> Bool {
    return level.rawValue >= self.thresholdLevel.rawValue && self.appenders.reduce(false) { (shouldLog, currentAppender) in
      shouldLog || level.rawValue >= currentAppender.thresholdLevel.rawValue
    }
  }
  
  @nonobjc internal func log(message: String, level: LogLevel, file: String? = nil, line: Int? = nil) {
    if(self.willIssueLogForLevel(level)) {
      var info: LogInfoDictionary = [
        LogInfoKeys.LoggerName: self.identifier,
        LogInfoKeys.LogLevel: level,
      ];
      if let file = file {
        info[.FileName] = file;
      }
      if let line = line {
        info[.FileLine] = line;
      }
      for currentAppender in self.appenders {
        currentAppender.log(message, level:level, info: info);
      }
    }
  }
  
  @nonobjc internal func log(closure: () -> (String), level: LogLevel, file: String? = nil, line: Int? = nil) {
    if(self.willIssueLogForLevel(level)) {
      let logMessage = closure();
      var info: LogInfoDictionary = [
        .LoggerName: self.identifier,
        .LogLevel: level,
      ];
      if let file = file {
        info[.FileName] = file;
      }
      if let line = line {
        info[.FileLine] = line;
      }
      for currentAppender in self.appenders {
        currentAppender.log(logMessage, level:level, info: info);
      }
    }
  }
  
  // MARK: Private methods
  
  private func breakDependencyWithParent() {
    guard let parent = self.parent else {
      return;
    }
    self.thresholdLevelStorage = parent.thresholdLevel;
    self.appendersStorage = parent.appenders;
    self.parent = nil;
  }
  
  private final class func createDefaultAppenders() -> [Appender] {
    return [StdOutAppender("defaultAppender")];
  }
  
}