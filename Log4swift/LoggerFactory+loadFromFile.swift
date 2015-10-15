//
//  LoggerFactory+loadFromFile.swift
//  Log4swift
//
//  Created by Jérôme Duquennoy on 03/07/2015.
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

extension LoggerFactory {
  public enum DictionaryKey: String {
    case ClassName = "Class"
    case Formatters = "Formatters"
    case Appenders = "Appenders"
    case Loggers = "Loggers"
    case RootLogger = "RootLogger"
    case Identifier = "Identifier"
  };
  
  public func readConfigurationFromPlistFile(filePath: String) throws {
    let configurationNSDictionary = NSDictionary(contentsOfFile: filePath);
    if let configurationDictionary = configurationNSDictionary as? Dictionary<String, AnyObject> {
      try self.readConfiguration(configurationDictionary);
    }
  }
  
  /// Reads a whole configuration from the given dictionary.
  public func readConfiguration(configurationDictionary: Dictionary<String, AnyObject>) throws {
    try self.readConfigurationToTupple(configurationDictionary);
  }
  
  // This internal method returns all created objects in a tupple, to make testing easier.
  // The public version does not return a tupple, an thus is compatible with Objective-C.
  internal func readConfigurationToTupple(configurationDictionary: Dictionary<String, AnyObject>) throws -> (Array<Formatter>, Array<Appender>, Array<Logger>) {
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
    
    // Root logger
    if let rootLoggerDictionary = configurationDictionary[DictionaryKey.RootLogger.rawValue] as? Dictionary<String, AnyObject> {
      try self.rootLogger.updateWithDictionary(rootLoggerDictionary, availableAppenders: appenders);
    } else if configurationDictionary[DictionaryKey.RootLogger.rawValue] != nil {
      throw InvalidOrMissingParameterException("The '\(DictionaryKey.RootLogger.rawValue)' parameter should be a dictionary");
    }
    
    // Loggers
    if let loggersArray = configurationDictionary[DictionaryKey.Loggers.rawValue] as? Array<Dictionary<String, AnyObject>> {
      let sortedLoggersArray = loggersArray.sort({ (a, b) -> Bool in
        do {
          let identifierA: String = try self.identifierFromConfigurationDictionary(a);
          let identifierB: String = try self.identifierFromConfigurationDictionary(b);
          return identifierA.characters.count < identifierB.characters.count;
        } catch {
          return false;
        }
      });
      
      for currentLoggerDefinition in sortedLoggersArray {
        let logger = try processLoggerDictionary(currentLoggerDefinition, appenders: appenders)
        loggers.append(logger);
        try registerLogger(logger);
      }
    }
    
    return (formatters, appenders, loggers);
  }
  
  private func processFormatterDictionary(dictionary: Dictionary<String, AnyObject>) throws -> Formatter {
    let identifier = try identifierFromConfigurationDictionary(dictionary);
    let formatter: Formatter;
    if let className = dictionary[DictionaryKey.ClassName.rawValue] as? String {
      if let formatterType = formatterForClassName(className) {
        formatter = formatterType.init(identifier);
        try formatter.updateWithDictionary(dictionary);
      } else {
        throw InvalidOrMissingParameterException("Unknown formatter class '\(className)' for formatter '\(identifier)'");
      }
    } else {
      throw InvalidOrMissingParameterException("Missing '\(DictionaryKey.ClassName.rawValue) parameter for formatter '\(identifier)'");
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
    let identifier = try identifierFromConfigurationDictionary(dictionary);
    let appender: Appender;
    if let className = dictionary[DictionaryKey.ClassName.rawValue] as? String {
      if let appenderType = appenderForClassName(className) {
        appender = appenderType.init(identifier);
        try appender.updateWithDictionary(dictionary, availableFormatters: formatters);
      } else {
        throw InvalidOrMissingParameterException("Unknown appender class '\(className)' for appender '\(identifier)'");
      }
    } else {
      throw InvalidOrMissingParameterException("Missing '\(DictionaryKey.ClassName.rawValue) parameter for appender '\(identifier)'")
    }
    
    return appender;
  }
  
  private func appenderForClassName(className: String) -> Appender.Type? {
    let type: Appender.Type?;
    switch(className.lowercaseString) {
    case "stdoutappender":
      type = StdOutAppender.self;
    case "fileappender":
      type = FileAppender.self;
    case "nsloggerappender":
      type = NSLoggerAppender.self;
    case "nslogappender":
      type = NSLogAppender.self;
    case "aslappender":
      type = ASLAppender.self;
    default:
      type = nil;
    }
    return type;
  }

  private func processLoggerDictionary(dictionary: Dictionary<String, AnyObject>, appenders: Array<Appender>) throws -> Logger {
    let identifier = try identifierFromConfigurationDictionary(dictionary);
    let logger = self.getLogger(identifier);
    
    try logger.updateWithDictionary(dictionary, availableAppenders: appenders);
    
    return logger;
  }
  
  private func identifierFromConfigurationDictionary(configurationDictionary: Dictionary<String, AnyObject>) throws -> String {
    let identifier: String;
    if let safeIdentifier = configurationDictionary[DictionaryKey.Identifier.rawValue] as? String {
      if(safeIdentifier.isEmpty) {
        throw InvalidOrMissingParameterException("Empty '\(DictionaryKey.Identifier.rawValue)' parameter in dictionary");
      }
      identifier = safeIdentifier;
    } else {
      throw InvalidOrMissingParameterException("Missing '\(DictionaryKey.Identifier.rawValue)' parameter in dictionary");
    }
    
    return identifier
  }
}