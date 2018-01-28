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

extension LoggerFactory : FileObserverDelegate {
  public enum DictionaryKey: String {
    case ClassName = "Class"
    case Formatters = "Formatters"
    case Appenders = "Appenders"
    case Loggers = "Loggers"
    case RootLogger = "RootLogger"
    case Identifier = "Identifier"
  }
  
  /// Load configuration file in plist format.
  /// - parameter filePath: the path to the file to load
  /// - parameter autoReload: true if the configuration file should be reloaded automatically when modified. If file does not exist, it will be loaded when created. Only one file can be auto-reloaded at a time. If a second file is marked as such, the first one will no longer be.
  public func readConfiguration(fromPlistFile filePath: String, autoReload: Bool = false, reloadInterval: TimeInterval = 5.0) throws {
    let expandedFilePath = (filePath as NSString).expandingTildeInPath
    let configurationNSDictionary = NSDictionary(contentsOfFile: expandedFilePath)
    if let configurationDictionary = configurationNSDictionary as? Dictionary<String, Any> {
			try self.readConfiguration(fromDictionary: configurationDictionary)
    }
    if autoReload {
      self.configurationFileObserver = FileObserver(filePath: expandedFilePath, poolInterval: reloadInterval)
      self.configurationFileObserver?.delegate = self
    }
  }
  
  /// Reads a whole configuration from the given dictionary.
  public func readConfiguration(fromDictionary configurationDictionary: Dictionary<String, Any>) throws {
    _ = try self.readConfigurationToTupple(fromDictionary: configurationDictionary)
  }
  
  // This internal method returns all created objects in a tupple, to make testing easier.
  // The public version does not return a tupple, an thus is compatible with Objective-C.
  internal func readConfigurationToTupple(fromDictionary configurationDictionary: Dictionary<String, Any>) throws -> (Array<Formatter>, Array<Appender>, Array<Logger>) {
    var formatters = Array<Formatter>()
    var appenders = Array<Appender>()
    var loggers = Array<Logger>()
    
    // Formatters
    if let formattersArray = configurationDictionary[DictionaryKey.Formatters.rawValue] as? Array<Dictionary<String, Any>> {
      for currentFormatterDefinition in formattersArray {
        let formatter = try processFormatterDictionary(currentFormatterDefinition)
        formatters.append(formatter)
      }
    }
    
    // Appenders
    if let appendersArray = configurationDictionary[DictionaryKey.Appenders.rawValue] as? Array<Dictionary<String, Any>> {
      for currentAppenderDefinition in appendersArray {
        let appender = try processAppenderDictionary(currentAppenderDefinition, formatters: formatters)
        appenders.append(appender)
      }
    }
    
    // Root logger
    if let rootLoggerDictionary = configurationDictionary[DictionaryKey.RootLogger.rawValue] as? Dictionary<String, Any> {
			try self.rootLogger.update(withDictionary: rootLoggerDictionary, availableAppenders: appenders)
    } else if configurationDictionary[DictionaryKey.RootLogger.rawValue] != nil {
			throw NSError.Log4swiftError(description: "The '\(DictionaryKey.RootLogger.rawValue)' parameter should be a dictionary")
    }
    
    // Loggers
    if let loggersArray = configurationDictionary[DictionaryKey.Loggers.rawValue] as? Array<Dictionary<String, Any>> {
      let sortedLoggersArray = loggersArray.sorted(by: { (a, b) -> Bool in
        do {
          let identifierA: String = try self.identifierFromConfigurationDictionary(a)
          let identifierB: String = try self.identifierFromConfigurationDictionary(b)
          return identifierA.count < identifierB.count
        } catch {
          return false
        }
      })
      
      for currentLoggerDefinition in sortedLoggersArray {
        let logger = try processLoggerDictionary(currentLoggerDefinition, appenders: appenders)
        loggers.append(logger)
        try registerLogger(logger)
      }
    }
    
    return (formatters, appenders, loggers)
  }
  
  private func processFormatterDictionary(_ dictionary: Dictionary<String, Any>) throws -> Formatter {
    let identifier = try identifierFromConfigurationDictionary(dictionary)
    let formatter: Formatter
    if let className = dictionary[DictionaryKey.ClassName.rawValue] as? String {
      if let formatterType = formatterForClassName(className) {
        formatter = formatterType.init(identifier)
				try formatter.update(withDictionary: dictionary)
      } else {
				throw NSError.Log4swiftError(description: "Unknown formatter class '\(className)' for formatter '\(identifier)'")
      }
    } else {
      throw NSError.Log4swiftError(description: "Missing '\(DictionaryKey.ClassName.rawValue) parameter for formatter '\(identifier)'")
    }
    
    return formatter
  }
  
  private func formatterForClassName(_ className: String) -> Formatter.Type? {
    let type: Formatter.Type?
    switch(className) {
    case "PatternFormatter":
      type = PatternFormatter.self
    default:
      type = nil
    }
    return type
  }

  private func processAppenderDictionary(_ dictionary: Dictionary<String, Any>, formatters: Array<Formatter>) throws -> Appender {
    let identifier = try identifierFromConfigurationDictionary(dictionary)
    let appender: Appender
    if let className = dictionary[DictionaryKey.ClassName.rawValue] as? String {
      if let appenderType = appenderForClassName(className) {
        appender = appenderType.init(identifier)
				try appender.update(withDictionary: dictionary, availableFormatters: formatters)
      } else {
				throw NSError.Log4swiftError(description: "Unknown appender class '\(className)' for appender '\(identifier)'")
      }
    } else {
      throw NSError.Log4swiftError(description: "Missing '\(DictionaryKey.ClassName.rawValue) parameter for appender '\(identifier)'")
    }
    
    return appender
  }
  
  private func appenderForClassName(_ className: String) -> Appender.Type? {
    let classNameLowercased = className.lowercased()
    
    for appenderType in Appender.availableAppenderTypes {
      if String(describing: appenderType).lowercased() == classNameLowercased  {
        return appenderType
      }
    }
    
    return nil
  }

  private func processLoggerDictionary(_ dictionary: Dictionary<String, Any>, appenders: Array<Appender>) throws -> Logger {
    let identifier = try identifierFromConfigurationDictionary(dictionary)
    let logger = self.getLogger(identifier)
    
		try logger.update(withDictionary: dictionary, availableAppenders: appenders)
    
    return logger
  }
  
  private func identifierFromConfigurationDictionary(_ configurationDictionary: Dictionary<String, Any>) throws -> String {
    let identifier: String
    if let safeIdentifier = configurationDictionary[DictionaryKey.Identifier.rawValue] as? String {
      if(safeIdentifier.isEmpty) {
				throw NSError.Log4swiftError(description: "Empty '\(DictionaryKey.Identifier.rawValue)' parameter in dictionary")
      }
      identifier = safeIdentifier
    } else {
      throw NSError.Log4swiftError(description: "Missing '\(DictionaryKey.Identifier.rawValue)' parameter in dictionary")
    }
    
    return identifier
  }
  
  public func fileChanged(atPath: String) {
    do {
      NSLog("file \(atPath) changed, reloadging")
			try self.readConfiguration(fromPlistFile: atPath)
    } catch (let error){
      // We dont't want to throw here, as it might be a temporary error until next edit.
      // So We just print out the error to the console, with description.
      NSLog("Failed to reload file \(atPath) : \(error)")
    }
  }
}
