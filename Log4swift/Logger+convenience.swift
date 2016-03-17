//
//  Logger+convenience.swift
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

/**
This extension of the Logger class provides several convenience class methods to make use of log4swift easier in simple cases.
*/
extension Logger {
  
  public class func getLogger(loggerId: String) -> Logger {
    return LoggerFactory.sharedInstance.getLogger(loggerId);
  }
  
  // MARK: Logging class methods

  /// Logs the provided message with a trace level using the root logger of the shared logger factory
  public class func trace(format: String, _ args: CVarArgType...) {
    let formattedMessage = format.format(args)
    LoggerFactory.sharedInstance.rootLogger.log(formattedMessage, level: LogLevel.Trace);
  }
  /// Logs the provided message with a debug level using the root logger of the shared logger factory
  public class func debug(format: String, _ args: CVarArgType...) {
    let formattedMessage = format.format(args)
    LoggerFactory.sharedInstance.rootLogger.log(formattedMessage, level: LogLevel.Debug);
  }
  /// Logs the provided message with a info level using the root logger of the shared logger factory
  public class func info(format: String, _ args: CVarArgType...) {
    let formattedMessage = format.format(args)
    LoggerFactory.sharedInstance.rootLogger.log(formattedMessage, level: LogLevel.Info);
  }
  /// Logs the provided message with a warning level using the root logger of the shared logger factory
  public class func warning(format: String, _ args: CVarArgType...) {
    let formattedMessage = format.format(args)
    LoggerFactory.sharedInstance.rootLogger.log(formattedMessage, level: LogLevel.Warning);
  }
  /// Logs the provided message with a error level using the root logger of the shared logger factory
  public class func error(format: String, _ args: CVarArgType...) {
    let formattedMessage = format.format(args)
    LoggerFactory.sharedInstance.rootLogger.log(formattedMessage, level: LogLevel.Error);
  }
  /// Logs the provided message with a fatal level using the root logger of the shared logger factory
  public class func fatal(format: String, _ args: CVarArgType...) {
    let formattedMessage = format.format(args)
    LoggerFactory.sharedInstance.rootLogger.log(formattedMessage, level: LogLevel.Fatal);
  }

  /// Logs a the message returned by the closer with a trace level using the root logger of the shared logger factory
  /// If the logger's or appender's configuration prevents the message to be issued, the closure will not be called.
  @nonobjc public class func trace(closure: () -> (String)) {
    LoggerFactory.sharedInstance.rootLogger.log(closure, level: .Trace);
  }
  /// Logs a the message returned by the closer with a debug level using the root logger of the shared logger factory
  /// If the logger's or appender's configuration prevents the message to be issued, the closure will not be called.
  @nonobjc public class func debug(closure: () -> (String)) {
    LoggerFactory.sharedInstance.rootLogger.log(closure, level: .Debug);
  }
  /// Logs a the message returned by the closer with an info level using the root logger of the shared logger factory
  /// If the logger's or appender's configuration prevents the message to be issued, the closure will not be called.
  @nonobjc public class func info(closure: () -> (String)) {
    LoggerFactory.sharedInstance.rootLogger.log(closure, level: .Info);
  }
  /// Logs a the message returned by the closer with a warning level using the root logger of the shared logger factory
  /// If the logger's or appender's configuration prevents the message to be issued, the closure will not be called.
  @nonobjc public class func warning(closure: () -> (String)) {
    LoggerFactory.sharedInstance.rootLogger.log(closure, level: .Warning);
  }
  /// Logs a the message returned by the closer with an error level using the root logger of the shared logger factory
  /// If the logger's or appender's configuration prevents the message to be issued, the closure will not be called.
  @nonobjc public class func error(closure: () -> (String)) {
    LoggerFactory.sharedInstance.rootLogger.log(closure, level: .Error);
  }
  /// Logs a the message returned by the closer with a fatal level using the root logger of the shared logger factory
  /// If the logger's or appender's configuration prevents the message to be issued, the closure will not be called.
  @nonobjc public class func fatal(closure: () -> (String)) {
    LoggerFactory.sharedInstance.rootLogger.log(closure, level: .Fatal);
  }
  
}