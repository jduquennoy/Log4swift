//
//  LoggerFactory+loadFromFile.swift
//  Log4swift
//
//  Created by Jérôme Duquennoy on 03/07/2015.
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

import Foundation

extension LoggerFactory {
  public enum DictionaryKey: String {
    case ClassName = "Class"
    case Formatters = "Formatters"
    case Appenders = "Appenders"
    case Loggers = "Loggers"
    case RootLogger = "RootLogger"
  };
    
  /// Reads a whole configuration from the given dictionary.  
  /// **Warning:** This will destroy all current loggers and appenders, replacing them by those found in that configuration.
  public func readConfiguration(configurationDictionary: Dictionary<String, AnyObject>) throws -> (Array<Formatter>, Array<Appender>, Array<Logger>) {
    var formatters = Array<Formatter>();
    var appenders = Array<Appender>();
    var loggers = Array<Logger>();
    
    // Formatters
    if let formattersArray = configurationDictionary[DictionaryKey.Formatters.rawValue] as? Array<Dictionary<String, AnyObject>> {
      for currentFormatterDefinition in formattersArray {
        let formatter = try processFormatterDictionary(currentFormatterDefinition);
        formatters.append(formatter);
      }
    }
    
    // Appenders
    if let appendersArray = configurationDictionary[DictionaryKey.Appenders.rawValue] as? Array<Dictionary<String, AnyObject>> {
      for currentAppenderDefinition in appendersArray {
        let appender = try processAppenderDictionary(currentAppenderDefinition, formatters: formatters);
        appenders.append(appender);
      }
    }
    
    // Loggers
    if let loggersArray = configurationDictionary[DictionaryKey.Loggers.rawValue] as? Array<Dictionary<String, AnyObject>> {
      for currentLoggerDefinition in loggersArray {
        let logger = try processLoggerDictionary(currentLoggerDefinition, appenders: appenders);
        loggers.append(logger);
      }
    }
    
    
    return (formatters, appenders, loggers);
  }
  
  private func processFormatterDictionary(dictionary: Dictionary<String, AnyObject>) throws -> Formatter {
    let formatter: Formatter;
    if let className = dictionary[DictionaryKey.ClassName.rawValue] as? String {
      if let formatterType = formatterForClassName(className) {
        formatter = try formatterType.init(dictionary: dictionary);
      } else {
        throw Error.InvalidOrMissingParameterException(parameterName: DictionaryKey.ClassName.rawValue)
      }
    } else {
      throw Error.InvalidOrMissingParameterException(parameterName: DictionaryKey.ClassName.rawValue)
    }
    
    return formatter;
  }
  
  private func formatterForClassName(className: String) -> Formatter.Type? {
    let type: Formatter.Type?;
    switch(className) {
    case "PatternFormatter":
      type = PatternFormatter.self;
    default:
      type = nil;
    }
    return type;
  }

  private func processAppenderDictionary(dictionary: Dictionary<String, AnyObject>, formatters: Array<Formatter>) throws -> Appender {
    let appender: Appender;
    if let className = dictionary[DictionaryKey.ClassName.rawValue] as? String {
      if let appenderType = appenderForClassName(className) {
        appender = try appenderType.init(dictionary, availableFormatters: formatters);
      } else {
        throw Error.InvalidOrMissingParameterException(parameterName: DictionaryKey.ClassName.rawValue)
      }
    } else {
      throw Error.InvalidOrMissingParameterException(parameterName: DictionaryKey.ClassName.rawValue)
    }
    
    return appender;
  }
  
  private func appenderForClassName(className: String) -> Appender.Type? {
    let type: Appender.Type?;
    switch(className) {
    case "ConsoleAppender":
      type = ConsoleAppender.self;
    case "FileAppender":
      type = FileAppender.self;
    case "NSLoggerAppender":
      type = NSLoggerAppender.self;
    default:
      type = nil;
    }
    return type;
  }

  private func processLoggerDictionary(dictionary: Dictionary<String, AnyObject>, appenders: Array<Appender>) throws -> Logger {
    let logger: Logger;

    logger = try Logger(dictionary, availableAppenders: appenders);
    
    return logger;
  }
}