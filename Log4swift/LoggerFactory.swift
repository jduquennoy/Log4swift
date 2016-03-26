//
//  LoggerFactory.swift
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
The logger factory is responsible for
* loading configuration from files or dictionaries
* holding the loggers and appenders
* matching UTI identifiers to loggers
*/
@objc public final class LoggerFactory: NSObject {
  static public let sharedInstance = LoggerFactory()
  
  /// Errors that can be thrown by logger factory
  public enum Error: ErrorType {
    case InvalidLoggerIdentifier
  }
  
  internal var configurationFileObserver: FileObserver?
  
  /// The root logger is the catchall logger used when no other logger matches. It is the only non-optional logger of the factory.
  public let rootLogger = Logger()
  internal var loggers = Dictionary<String, Logger>()
  
  // MARK: Configuration

  /// Adds the given logger to the list of available loggers. If a logger with the same identifier already exists, it will be replaced by the new one.
  /// Adding a logger with an empty identifier will cause an error. Use the root logger instead of defining a logger with an empty identifier.
  @objc public func registerLogger(newLogger: Logger) throws {
    if(newLogger.identifier.isEmpty) {
      throw Error.InvalidLoggerIdentifier
    }
    
    self.loggers[newLogger.identifier] = newLogger
    self.clearAutoGeneratedLoggers()
  }
  
  @objc public func resetConfiguration() {
    self.loggers.removeAll()
    self.rootLogger.resetConfiguration()
  }
  
  // MARK: Acccessing loggers

  /// Returns the logger for the given identifier.
  /// If an exact match is found, the associated logger will be returned. If not, a new logger will be created on the fly base on the logger with with the longest maching identifier.
  /// Ultimately, if no logger is found, the root logger will be used as a base.
  /// Once the logger has been created, it is associated with its identifier, and can be updated independently from other loggers.
  @objc public func getLogger(identifierToFind: String) -> Logger {
    let foundLogger: Logger
    
    if let loggerFromCache = self.loggers[identifierToFind] {
      foundLogger = loggerFromCache
    } else {
      var reducedIdentifier = identifierToFind.stringByRemovingLastComponentWithDelimiter(".")
      var loggerToCopy = self.rootLogger
      while (loggerToCopy === self.rootLogger && !reducedIdentifier.isEmpty) {
        if let loggerFromCache = self.loggers[reducedIdentifier] {
          loggerToCopy = loggerFromCache
        }
        reducedIdentifier = reducedIdentifier.stringByRemovingLastComponentWithDelimiter(".")
      }
      
      foundLogger = Logger(parentLogger: loggerToCopy, identifier: identifierToFind)
      self.loggers[identifierToFind] = foundLogger
    }
    
    return foundLogger
  }
 
  private func clearAutoGeneratedLoggers() {
    for (key, logger) in self.loggers {
      if(logger.parent != nil) {
        self.loggers.removeValueForKey(key)
      }
    }
  }
}

extension LoggerFactory {
  
  /**
  Configures the root logger to output logs to the Xcode console.
  Logs coloring will be enabled if you have XcodeColors installed.
  This configuration is not meant to be used for production.
  
  **This method will replace your current configuration by a new one.**
  */
  public func configureForXcodeConsole(thresholdLevel: LogLevel = .Debug) {
    self.resetConfiguration()
    
    let xcodeAppender = StdOutAppender("xcodeAppender")
    xcodeAppender.thresholdLevel = thresholdLevel
    xcodeAppender.errorThresholdLevel = .Debug
    xcodeAppender.setTextColor(.DarkRed, level: .Fatal)
    xcodeAppender.setTextColor(.Red, level: .Error)
    xcodeAppender.setTextColor(.Orange, level: .Warning)
    xcodeAppender.setTextColor(.Blue, level: .Info)
    xcodeAppender.setTextColor(.DarkGrey, level: .Debug)
    xcodeAppender.setTextColor(.LightGrey, level: .Trace)

    do {
      let formatter = try PatternFormatter(identifier: "xcodeFormatter", pattern: "%d{'format':'%F %T'} %m")
      xcodeAppender.formatter = formatter
    } catch {
      // we apply no formatter if an error occures (this should never happen)
      NSLog("Could not set the formatter for the XCodeConsole configuration : \(error)")
    }
    
    self.rootLogger.appenders = [xcodeAppender]
  }

  /**
  Configures the root logger to output logs to the system logging system, making them available in the "Console" application.
  This configuration is suitable for production use.
  
  **This method will replace your current configuration by a new one.**
  */
  public func configureForSystemConsole(thresholdLevel: LogLevel = .Warning) {
    self.resetConfiguration()
    
    let systemConsoleAppender = ASLAppender("systemConsoleAppender")
    systemConsoleAppender.thresholdLevel = thresholdLevel
    
    self.rootLogger.appenders = [systemConsoleAppender]
  }

  /**
  Configures the root logger to output logs to NSLogger. SSL and local cache will be enabled on the appender.
  This configuration is not meant to be used for production.
  
  **This method will replace your current configuration by a new one.**
  */
  public func configureForNSLogger(remoteHost: String = "127.0.0.1", remotePort: UInt32 = 50000, thresholdLevel: LogLevel = .Debug) {
    self.resetConfiguration()
    
    let nsloggerAppender = NSLoggerAppender(identifier: "nsloggerAppender", remoteHost: remoteHost, remotePort: remotePort, useLocalCache: true, useSSL: true)
    nsloggerAppender.thresholdLevel = thresholdLevel
    
    self.rootLogger.appenders = [nsloggerAppender]
  }
}