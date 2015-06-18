//
//  Logger.swift
//  log4swift
//
//  Created by Jérôme Duquennoy on 14/06/2015.
//  Copyright © 2015 jerome. All rights reserved.
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
public class Logger {
  
  /// The UTI string that identifies the logger.  
  /// Exemple : product.module.feature
  public let identifier: String;
  
  /// The threshold under which log messages will be ignored.
  public var thresholdLevel: LogLevel;
  
  public var appenders: [Appender];
  
  convenience init() {
    self.init(identifier: "", level: LogLevel.debug, appenders: Logger.createDefaultAppenders());
  }
  
  convenience init(configurationDictionary: Dictionary<String, AnyObject>)
  {
    let identifier = "";
    let level = LogLevel.debug;
    
    self.init(identifier: identifier,level: level, appenders: Logger.createDefaultAppenders());
  }
  
  init(identifier: String, level: LogLevel, appenders: [Appender]) {
    self.identifier = identifier;
    self.thresholdLevel = level;
    self.appenders = appenders;
  }
  
  // MARK: Logging methods
  
  public func debug(message: String) {
    self.log(message, level: LogLevel.debug);
  }
  public func info(message: String) {
    self.log(message, level: LogLevel.info);
  }
  public func warn(message: String) {
    self.log(message, level: LogLevel.warning);
  }
  public func error(message: String) {
    self.log(message, level: LogLevel.error);
  }
  public func fatal(message: String) {
    self.log(message, level: LogLevel.fatal);
  }

  public func debug(closure: () -> String) {
    self.log(closure, level: LogLevel.debug);
  }
  public func info(closure: () -> String) {
    self.log(closure, level: LogLevel.info);
  }
  public func warn(closure: () -> String) {
    self.log(closure, level: LogLevel.warning);
  }
  public func error(closure: () -> String) {
    self.log(closure, level: LogLevel.error);
  }
  public func fatal(closure: () -> String) {
    self.log(closure, level: LogLevel.fatal);
  }

  private func willIssueLogForLevel(level: LogLevel) -> Bool {
    return level.rawValue >= self.thresholdLevel.rawValue && self.appenders.reduce(false) { (shouldLog, currentAppender) in
      shouldLog || level.rawValue >= currentAppender.thresholdLevel.rawValue
    }
  }
  
  private func log(message: String, level: LogLevel) {
    if(level.rawValue >= self.thresholdLevel.rawValue) {
      for currentAppender in self.appenders {
        currentAppender.log(message, level:level);
      }
    }
  }

  private func log(closure: () -> (String), level: LogLevel) {
    if(self.willIssueLogForLevel(level)) {
      let logMessage = closure();
      for currentAppender in self.appenders {
        currentAppender.log(logMessage, level:level);
      }
    }
  }

  private final class func createDefaultAppenders() -> [Appender] {
    return [ConsoleAppender(identifier: "defaultAppender")];
  }
  
}