//
//  Logger.swift
//  log4swift
//
//  Created by Jérôme Duquennoy on 14/06/2015.
//  Copyright © 2015 Jérôme Duquennoy. All rights reserved.
//
// Log4swift is free software: you can redistribute it and/or modify
// it under the terms of the GNU Lesser General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// Log4swift is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU Lesser General Public License for more details.
//
// You should have received a copy of the GNU Lesser General Public License
// along with Foobar. If not, see <http://www.gnu.org/licenses/>.
//

/**
A logger is identified by a UTI identifier, it defines a threshold level and a destination appender
*/
@objc public class Logger {
  public enum DictionaryKey: String {
    case ThresholdLevel = "ThresholdLevel"
    case AppenderIds = "AppenderIds"
  }
  
  /// The UTI string that identifies the logger. Exemple : product.module.feature
  public let identifier: String;

  internal var parent: Logger?;
  
  private var thresholdLevelStorage: LogLevel;
  private var appendersStorage: [Appender];

  /// The threshold under which log messages will be ignored.
  /// For exemple, if the threshold is Warning:
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

  convenience init() {
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
    
    if let safeLevelString = dictionary[DictionaryKey.ThresholdLevel.rawValue] as? String {
      if let safeLevel = LogLevel(safeLevelString) {
        self.thresholdLevel = safeLevel;
      } else {
        throw Error.InvalidOrMissingParameterException(parameterName: DictionaryKey.ThresholdLevel.rawValue);
      }
    }
    
    self.appenders.removeAll();
    if let appenderIds = dictionary[DictionaryKey.AppenderIds.rawValue] as? Array<String> {
      appenders.removeAll();
      for currentAppenderId in appenderIds {
        if let foundAppender = availableAppenders.find({$0.identifier ==  currentAppenderId}) {
          appenders.append(foundAppender);
        } else {
          throw Error.InvalidOrMissingParameterException(parameterName: DictionaryKey.AppenderIds.rawValue);
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
  public func debug(format: String, _ args: CVarArgType...) {
    self.log(format.format(getVaList(args)), level: LogLevel.Debug);
  }
  /// Logs the provided message with an info level
  public func info(format: String, _ args: CVarArgType...) {
    self.log(format.format(getVaList(args)), level: LogLevel.Info);
  }
  /// Logs the provided message with a warning level
  public func warn(format: String, _ args: CVarArgType...) {
    self.log(format.format(getVaList(args)), level: LogLevel.Warning);
  }
  /// Logs the provided message with an error level
  public func error(format: String, _ args: CVarArgType...) {
    self.log(format.format(getVaList(args)), level: LogLevel.Error);
  }
  /// Logs the provided message with a fatal level
  public func fatal(format: String, _ args: CVarArgType...) {
    self.log(format.format(getVaList(args)), level: LogLevel.Fatal);
  }
  
  /// Logs a the message returned by the closer with a debug level
  /// If the logger's or appender's configuration prevents the message to be issued, the closure will not be called.
  @nonobjc public func debug(closure: () -> String) {
    self.log(closure, level: LogLevel.Debug);
  }
  /// Logs a the message returned by the closer with an info level
  /// If the logger's or appender's configuration prevents the message to be issued, the closure will not be called.
  @nonobjc public func info(closure: () -> String) {
    self.log(closure, level: LogLevel.Info);
  }
  /// Logs a the message returned by the closer with a warning level
  /// If the logger's or appender's configuration prevents the message to be issued, the closure will not be called.
  @nonobjc public func warn(closure: () -> String) {
    self.log(closure, level: LogLevel.Warning);
  }
  /// Logs a the message returned by the closer with an error level
  /// If the logger's or appender's configuration prevents the message to be issued, the closure will not be called.
  @nonobjc public func error(closure: () -> String) {
    self.log(closure, level: LogLevel.Error);
  }
  /// Logs a the message returned by the closer with a fatal level
  /// If the logger's or appender's configuration prevents the message to be issued, the closure will not be called.
  @nonobjc public func fatal(closure: () -> String) {
    self.log(closure, level: LogLevel.Fatal);
  }
  
  /// Returns true if a message sent with the given level will be issued by at least one appender.
  public func willIssueLogForLevel(level: LogLevel) -> Bool {
    return level.rawValue >= self.thresholdLevel.rawValue && self.appenders.reduce(false) { (shouldLog, currentAppender) in
      shouldLog || level.rawValue >= currentAppender.thresholdLevel.rawValue
    }
  }
  
  @nonobjc internal func log(message: String, level: LogLevel) {
    if(self.willIssueLogForLevel(level)) {
      let info: LogInfoDictionary = [
        LogInfoKeys.LoggerName: self.identifier,
        LogInfoKeys.LogLevel: level,
      ];
      for currentAppender in self.appenders {
        currentAppender.log(message, level:level, info: info);
      }
    }
  }
  
  @nonobjc internal func log(closure: () -> (String), level: LogLevel) {
    if(self.willIssueLogForLevel(level)) {
      let logMessage = closure();
      let info: LogInfoDictionary = [
        LogInfoKeys.LoggerName: self.identifier,
        LogInfoKeys.LogLevel: level,
      ];
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
    return [ConsoleAppender("defaultAppender")];
  }
  
}