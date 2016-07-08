//
//  LoggerFactory+loadFromFileTests.swift
//  Log4swift
//
//  Created by Jérôme Duquennoy on 03/07/2015.
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

import XCTest
@testable import Log4swift

class LoggerFactoryLoadFromFileTests: XCTestCase {
  var factory = LoggerFactory()
  
  override func setUp() {
    factory = LoggerFactory()
  }
  
  // MARK: Formatters tests
  
  func testLoadDictionaryWithNoFormatterClassThrowsError() {
    let formattersDictionary = [LoggerFactory.DictionaryKey.Identifier.rawValue: "testIdentifier"]
    let dictionary = [LoggerFactory.DictionaryKey.Formatters.rawValue: [formattersDictionary]]
    
    // Execute & validate
		XCTAssertThrows { try self.factory.readConfiguration(fromDictionary: dictionary) }
  }
  
  func testLoadDictionaryWithUnknownFormatterClassThrowsError() {
    let formattersDictionary = [LoggerFactory.DictionaryKey.Identifier.rawValue: "testIdentifier",
      LoggerFactory.DictionaryKey.ClassName.rawValue: "UnknownFormatterClass"]
    let dictionary = [LoggerFactory.DictionaryKey.Formatters.rawValue: [formattersDictionary]]
    
    // Execute & validate
    XCTAssertThrows { try self.factory.readConfiguration(fromDictionary: dictionary) }
  }
  
  func testLoadDictionaryWithNoFormatterIdentifierThrowsError() {
    let formattersDictionary = [LoggerFactory.DictionaryKey.ClassName.rawValue: "PatternFormatter"]
    let dictionary = [LoggerFactory.DictionaryKey.Formatters.rawValue: [formattersDictionary]]
    
    // Execute & validate
    XCTAssertThrows { try self.factory.readConfiguration(fromDictionary: dictionary) }
  }
  
  func testLoadDictionaryWithEmptyFormatterFormatterIdentifierThrowsError() {
    let formattersDictionary = [LoggerFactory.DictionaryKey.Identifier.rawValue: "",
      LoggerFactory.DictionaryKey.ClassName.rawValue: "PatternFormatter",
      PatternFormatter.DictionaryKey.Pattern.rawValue: "test pattern"]
    let dictionary = [LoggerFactory.DictionaryKey.Formatters.rawValue: [formattersDictionary]]
    
    // Execute & validate
    XCTAssertThrows { try self.factory.readConfiguration(fromDictionary: dictionary) }
  }
  
  func testLoadDictionaryWithPatternFormatterClassCreatesRequestedFormatter() {
    let formattersDictionary = [LoggerFactory.DictionaryKey.ClassName.rawValue: "PatternFormatter",
      LoggerFactory.DictionaryKey.Identifier.rawValue: "patternIdentifier",
      PatternFormatter.DictionaryKey.Pattern.rawValue: "test pattern"]
    
    let dictionary = [LoggerFactory.DictionaryKey.Formatters.rawValue: [formattersDictionary]]
    
    // Execute
		let (formatters, _, _) = try! factory.readConfigurationToTupple(fromDictionary: dictionary)
    
    // validate
    XCTAssertEqual(formatters.count, 1)
    XCTAssertEqual(classNameAsString(formatters[0]), "PatternFormatter")
    XCTAssertEqual(formatters[0].identifier, "patternIdentifier")
    
  }
  
  func testLoadDictionaryWithMultipleFormattersCreatesRequestedFormatters() {
    let formattersDictionary1 = [LoggerFactory.DictionaryKey.ClassName.rawValue: "PatternFormatter",
      LoggerFactory.DictionaryKey.Identifier.rawValue: "test pattern formatter 1",
      PatternFormatter.DictionaryKey.Pattern.rawValue: "test pattern"]
    let formattersDictionary2 = [LoggerFactory.DictionaryKey.ClassName.rawValue: "PatternFormatter",
      LoggerFactory.DictionaryKey.Identifier.rawValue: "test pattern formatter 2",
      PatternFormatter.DictionaryKey.Pattern.rawValue: "test pattern"]
    
    let dictionary = [LoggerFactory.DictionaryKey.Formatters.rawValue: [formattersDictionary1, formattersDictionary2]]
    
    // Execute
		let (formatters, _, _) = try! factory.readConfigurationToTupple(fromDictionary: dictionary)
    
    // validate
    XCTAssertEqual(formatters.count, 2)
    XCTAssertEqual(formatters[0].identifier, "test pattern formatter 1")
    XCTAssertEqual(formatters[1].identifier, "test pattern formatter 2")
  }
  
  // MARK: Appenders tests
  
  func testLoadDictionaryWithNoAppenderClassThrowsError() {
    let appenderDictionary = [LoggerFactory.DictionaryKey.Identifier.rawValue: "test pattern formatter 2"]
    
    let dictionary = [LoggerFactory.DictionaryKey.Appenders.rawValue: [appenderDictionary]]
    
    // Execute
    XCTAssertThrows { _ = try self.factory.readConfigurationToTupple(fromDictionary: dictionary) }
  }
  
  func testLoadDictionaryWithUnknownAppenderClassThrowsError() {
    let appenderDictionary = [LoggerFactory.DictionaryKey.Identifier.rawValue: "test appender",
      LoggerFactory.DictionaryKey.ClassName.rawValue: "UnknownAppenderClass"]
    
    let dictionary = [LoggerFactory.DictionaryKey.Appenders.rawValue: [appenderDictionary]]
    
    // Execute
    XCTAssertThrows { _ = try self.factory.readConfigurationToTupple(fromDictionary: dictionary) }
  }
  
  func testLoadDictionaryWithNoAppenderIdentifierThrowsError() {
    let appenderDictionary = [LoggerFactory.DictionaryKey.ClassName.rawValue: "StdOutAppender",]
    
    let dictionary = [LoggerFactory.DictionaryKey.Appenders.rawValue: [appenderDictionary]]
    
    // Execute
    XCTAssertThrows { _ = try self.factory.readConfigurationToTupple(fromDictionary: dictionary) }
  }
  
  func testLoadDictionaryWithEmptyAppenderIdentifierThrowsError() {
    let appenderDictionary = [LoggerFactory.DictionaryKey.Identifier.rawValue: "",
      LoggerFactory.DictionaryKey.ClassName.rawValue: "StdOutAppender"]
    
    let dictionary = [LoggerFactory.DictionaryKey.Appenders.rawValue: [appenderDictionary]]
    
    // Execute
    XCTAssertThrows { _ = try self.factory.readConfigurationToTupple(fromDictionary: dictionary) }
  }
  
  func testLoadDictionaryWithStdOutAppenderAndFormatCreatesRequestedAppender() {
    let formattersDictionary = [LoggerFactory.DictionaryKey.ClassName.rawValue: "PatternFormatter",
      LoggerFactory.DictionaryKey.Identifier.rawValue: "patternFormatterId",
      PatternFormatter.DictionaryKey.Pattern.rawValue: "test pattern"]
    let appenderDictionary = [LoggerFactory.DictionaryKey.ClassName.rawValue: "StdOutAppender",
      LoggerFactory.DictionaryKey.Identifier.rawValue: "test appender",
      Appender.DictionaryKey.FormatterId.rawValue: "patternFormatterId"]
    
    let dictionary = [LoggerFactory.DictionaryKey.Formatters.rawValue: [formattersDictionary],
      LoggerFactory.DictionaryKey.Appenders.rawValue: [appenderDictionary]]
    
    // Execute
    let (formatters, appenders, _) = try! factory.readConfigurationToTupple(fromDictionary: dictionary)
    
    // Validate
    XCTAssertEqual(appenders.count, 1)
    XCTAssertEqual(formatters.count, 1)
    XCTAssertEqual(appenders[0].identifier, "test appender")
    XCTAssertEqual(appenders[0].formatter!.identifier, formatters[0].identifier)
  }
  
  func testLoadDictionaryWithMultipleAppendersAndFormatCreatesRequestedAppender() {
    let formattersDictionary1 = [LoggerFactory.DictionaryKey.ClassName.rawValue: "PatternFormatter",
      LoggerFactory.DictionaryKey.Identifier.rawValue: "formatter1",
      PatternFormatter.DictionaryKey.Pattern.rawValue: "test pattern"]
    let formattersDictionary2 = [LoggerFactory.DictionaryKey.ClassName.rawValue: "PatternFormatter",
      LoggerFactory.DictionaryKey.Identifier.rawValue: "formatter2",
      PatternFormatter.DictionaryKey.Pattern.rawValue: "test pattern"]
    let appenderDictionary1 = [LoggerFactory.DictionaryKey.ClassName.rawValue: "FileAppender",
      LoggerFactory.DictionaryKey.Identifier.rawValue: "appender1",
      Appender.DictionaryKey.FormatterId.rawValue: "formatter2",
      FileAppender.DictionaryKey.FilePath.rawValue: "/test/path"]
    let appenderDictionary2 = [LoggerFactory.DictionaryKey.ClassName.rawValue: "NSLoggerAppender",
      LoggerFactory.DictionaryKey.Identifier.rawValue: "appender2",
      Appender.DictionaryKey.FormatterId.rawValue: "formatter1",
      NSLoggerAppender.DictionaryKey.RemoteHost.rawValue: "remoteHost"]
    
    let dictionary = [LoggerFactory.DictionaryKey.Formatters.rawValue: [formattersDictionary1, formattersDictionary2],
      LoggerFactory.DictionaryKey.Appenders.rawValue: [appenderDictionary1, appenderDictionary2]]
    
    // Execute
    let (formatters, appenders, _) = try! factory.readConfigurationToTupple(fromDictionary: dictionary)
    
    // Validate
    XCTAssertEqual(appenders.count, 2)
    XCTAssertEqual(formatters.count, 2)
    XCTAssertEqual(appenders[0].identifier, "appender1")
    XCTAssertEqual(appenders[0].formatter!.identifier, "formatter2")
    XCTAssertEqual(appenders[1].identifier, "appender2")
    XCTAssertEqual(appenders[1].formatter!.identifier, "formatter1")
  }
  
  func testAppendersClassesGeneratesCorrectObjects() {
    let fileAppenderDictionary = [LoggerFactory.DictionaryKey.ClassName.rawValue: "FileAppender",
      LoggerFactory.DictionaryKey.Identifier.rawValue: "FileAppender",
      FileAppender.DictionaryKey.FilePath.rawValue: "/test/path"]
    let nsloggerAppenderDictionary = [LoggerFactory.DictionaryKey.ClassName.rawValue: "NSLoggerAppender",
      LoggerFactory.DictionaryKey.Identifier.rawValue: "NSLoggerAppender",
      NSLoggerAppender.DictionaryKey.RemoteHost.rawValue: "remoteHost"]
    let stdoutAppenderDictionary = [LoggerFactory.DictionaryKey.ClassName.rawValue: "StdOutAppender",
      LoggerFactory.DictionaryKey.Identifier.rawValue: "StdOutAppender"]
    let nslogAppenderDictionary = [LoggerFactory.DictionaryKey.ClassName.rawValue: "NSLogAppender",
      LoggerFactory.DictionaryKey.Identifier.rawValue: "NSLogAppender"]
    let aslAppenderDictionary = [LoggerFactory.DictionaryKey.ClassName.rawValue: "ASLAppender",
      LoggerFactory.DictionaryKey.Identifier.rawValue: "ASLAppender"]
    
    let dictionary = [LoggerFactory.DictionaryKey.Appenders.rawValue: [fileAppenderDictionary, nsloggerAppenderDictionary, stdoutAppenderDictionary, nslogAppenderDictionary, aslAppenderDictionary]]
    
    // Execute
    let (_, appenders, _) = try! factory.readConfigurationToTupple(fromDictionary: dictionary)
    
    XCTAssertEqual(appenders.count, 5)
    for currentAppender in appenders {
			XCTAssertEqual(currentAppender.identifier, currentAppender.className.components(separatedBy: ".").last!)
    }
  }
  
  func testAppendersClassesAreCaseInsensitive() {
    let fileAppenderDictionary = [LoggerFactory.DictionaryKey.ClassName.rawValue: "FileAPPender",
      LoggerFactory.DictionaryKey.Identifier.rawValue: "FileAppender",
      FileAppender.DictionaryKey.FilePath.rawValue: "/test/path"]
    let nsloggerAppenderDictionary = [LoggerFactory.DictionaryKey.ClassName.rawValue: "NSLogGerAppender",
      LoggerFactory.DictionaryKey.Identifier.rawValue: "NSLoggerAppender",
      NSLoggerAppender.DictionaryKey.RemoteHost.rawValue: "remoteHost"]
    let stdoutAppenderDictionary = [LoggerFactory.DictionaryKey.ClassName.rawValue: "StdouTappender",
      LoggerFactory.DictionaryKey.Identifier.rawValue: "StdOutAppender"]
    let nslogAppenderDictionary = [LoggerFactory.DictionaryKey.ClassName.rawValue: "NSLogappENder",
      LoggerFactory.DictionaryKey.Identifier.rawValue: "NSLogAppender"]
    let aslAppenderDictionary = [LoggerFactory.DictionaryKey.ClassName.rawValue: "ASLAppenDEr",
      LoggerFactory.DictionaryKey.Identifier.rawValue: "ASLAppender"]
    
    let dictionary = [LoggerFactory.DictionaryKey.Appenders.rawValue: [fileAppenderDictionary, nsloggerAppenderDictionary, stdoutAppenderDictionary, nslogAppenderDictionary, aslAppenderDictionary]]
    
    // Execute
    let (_, appenders, _) = try! factory.readConfigurationToTupple(fromDictionary: dictionary)
    
    XCTAssertEqual(appenders.count, 5)
    for currentAppender in appenders {
      XCTAssertEqual(currentAppender.identifier, currentAppender.className.components(separatedBy: ".").last!)
    }
  }
  
  // MARK: Logger tests
  
  func testReadConfigurationWithNewLoggerAddsItToLoggersPool() {
    let appenderDictionary = [LoggerFactory.DictionaryKey.ClassName.rawValue: "StdOutAppender",
      LoggerFactory.DictionaryKey.Identifier.rawValue: "test appender"]
    let loggerDictionary = [LoggerFactory.DictionaryKey.Identifier.rawValue: "test.logger",
      Logger.DictionaryKey.AppenderIds.rawValue: ["test appender"],
      Logger.DictionaryKey.ThresholdLevel.rawValue: "info"]
    
    let dictionary = [LoggerFactory.DictionaryKey.Appenders.rawValue: [appenderDictionary],
      LoggerFactory.DictionaryKey.Loggers.rawValue: [loggerDictionary]]
    
    // Execute
    try! factory.readConfiguration(fromDictionary: dictionary)
    
    // Validate
    let logger = factory.getLogger("test.logger")
    XCTAssertEqual(logger.thresholdLevel, LogLevel.Info)
    XCTAssertEqual(logger.appenders.count, 1)
    if(logger.appenders.count > 0) { 
      XCTAssertEqual(logger.appenders[0].identifier, "test appender")
    }
  }
  
  func testReadConfigurationWithExistingLoggerUpdatesIt() {
    let appenderDictionary = [LoggerFactory.DictionaryKey.ClassName.rawValue: "StdOutAppender",
      LoggerFactory.DictionaryKey.Identifier.rawValue: "test appender"]
    let loggerDictionary = [LoggerFactory.DictionaryKey.Identifier.rawValue: "test.logger",
      Logger.DictionaryKey.AppenderIds.rawValue: ["test appender"],
      Logger.DictionaryKey.ThresholdLevel.rawValue: "info"]
    
    let existingLogger = Logger(identifier: "test.logger", level: .Error, appenders: [MemoryAppender("MemoryAppender")])
    try! factory.registerLogger(existingLogger)
    
    let dictionary = [LoggerFactory.DictionaryKey.Appenders.rawValue: [appenderDictionary],
      LoggerFactory.DictionaryKey.Loggers.rawValue: [loggerDictionary]]
    
    // Execute
    try! factory.readConfiguration(fromDictionary: dictionary)
    
    // Validate
    let logger = factory.getLogger("test.logger")
    XCTAssertTrue(logger === existingLogger)
    XCTAssertEqual(logger.thresholdLevel, LogLevel.Info)
    XCTAssertEqual(logger.appenders.count, 1)
    if(logger.appenders.count > 0) {
      XCTAssertEqual(logger.appenders[0].identifier, "test appender")
    }
  }
  
  func testLoggerFromConfigurationDictionaryInheritsLevelFromParentIfNotSpecified() {
    let appender1Dictionary = [LoggerFactory.DictionaryKey.ClassName.rawValue: "StdOutAppender",
      LoggerFactory.DictionaryKey.Identifier.rawValue: "first appender"]
    let appender2Dictionary = [LoggerFactory.DictionaryKey.ClassName.rawValue: "StdOutAppender",
      LoggerFactory.DictionaryKey.Identifier.rawValue: "second appender"]
    let logger1Dictionary = [LoggerFactory.DictionaryKey.Identifier.rawValue: "test.parentLogger",
      Logger.DictionaryKey.AppenderIds.rawValue: ["first appender"],
      Logger.DictionaryKey.ThresholdLevel.rawValue: "info"]
    let logger2Dictionary = [LoggerFactory.DictionaryKey.Identifier.rawValue: "test.parentLogger.sonLogger",
      Logger.DictionaryKey.AppenderIds.rawValue: ["second appender"]]
    
    let dictionary = [LoggerFactory.DictionaryKey.Appenders.rawValue: [appender1Dictionary, appender2Dictionary],
      LoggerFactory.DictionaryKey.Loggers.rawValue: [logger1Dictionary, logger2Dictionary]]
    
    // Execute
    try! factory.readConfiguration(fromDictionary: dictionary)
    
    // Validate
    let sonLogger = factory.getLogger("test.parentLogger.sonLogger")
    XCTAssertNil(sonLogger.parent)
    XCTAssertEqual(sonLogger.thresholdLevel, LogLevel.Info)
    XCTAssertEqual(sonLogger.appenders.count, 1)
    if(sonLogger.appenders.count > 0) {
      XCTAssertEqual(sonLogger.appenders[0].identifier, "second appender")
    }
  }
  
  func testLoggerFromConfigurationDictionaryInheritsAppendersFromParentIfNotSpecified() {
    let appender1Dictionary = [LoggerFactory.DictionaryKey.ClassName.rawValue: "StdOutAppender",
      LoggerFactory.DictionaryKey.Identifier.rawValue: "first appender"]
    let logger1Dictionary = [LoggerFactory.DictionaryKey.Identifier.rawValue: "test.parentLogger",
      Logger.DictionaryKey.AppenderIds.rawValue: ["first appender"],
      Logger.DictionaryKey.ThresholdLevel.rawValue: "info"]
    let logger2Dictionary = [LoggerFactory.DictionaryKey.Identifier.rawValue: "test.parentLogger.sonLogger",
      Logger.DictionaryKey.ThresholdLevel.rawValue: "warning"]
    
    let dictionary = [LoggerFactory.DictionaryKey.Appenders.rawValue: [appender1Dictionary],
      LoggerFactory.DictionaryKey.Loggers.rawValue: [logger1Dictionary, logger2Dictionary]]
    
    // Execute
    try! factory.readConfiguration(fromDictionary: dictionary)
    
    // Validate
    let sonLogger = factory.getLogger("test.parentLogger.sonLogger")
    XCTAssertNil(sonLogger.parent)
    XCTAssertEqual(sonLogger.thresholdLevel, LogLevel.Warning)
    XCTAssertEqual(sonLogger.appenders.count, 1)
    if(sonLogger.appenders.count > 0) {
      XCTAssertEqual(sonLogger.appenders[0].identifier, "first appender")
    }
  }
  
  func testLoggersInheritFromParentEvenIfOutOfOrder() {
    let appender1Dictionary = [LoggerFactory.DictionaryKey.ClassName.rawValue: "StdOutAppender",
      LoggerFactory.DictionaryKey.Identifier.rawValue: "first appender"]
    let logger1Dictionary = [LoggerFactory.DictionaryKey.Identifier.rawValue: "test.parentLogger",
      Logger.DictionaryKey.AppenderIds.rawValue: ["first appender"],
      Logger.DictionaryKey.ThresholdLevel.rawValue: "info"]
    let logger2Dictionary = [LoggerFactory.DictionaryKey.Identifier.rawValue: "test.parentLogger.sonLogger"]
    
    let dictionary = [LoggerFactory.DictionaryKey.Appenders.rawValue: [appender1Dictionary],
      LoggerFactory.DictionaryKey.Loggers.rawValue: [logger2Dictionary, logger1Dictionary]]
    
    // Execute
    try! factory.readConfiguration(fromDictionary: dictionary)
    
    // Validate
    let sonLogger = factory.getLogger("test.parentLogger.sonLogger")
    XCTAssertNil(sonLogger.parent)
    XCTAssertEqual(sonLogger.thresholdLevel, LogLevel.Info)
    XCTAssertEqual(sonLogger.appenders.count, 1)
    if(sonLogger.appenders.count > 0) {
      XCTAssertEqual(sonLogger.appenders[0].identifier, "first appender")
    }
  }
  
  func testLoggerConfiguredAsAsynchronousIsAsynchronous() {
    let loggersDictionary = [[
      LoggerFactory.DictionaryKey.Identifier.rawValue: "test.asyncLogger",
      Logger.DictionaryKey.Asynchronous.rawValue: true]]
    let dictionary = [
      LoggerFactory.DictionaryKey.Loggers.rawValue: loggersDictionary
    ]
    // Execute
    try! factory.readConfiguration(fromDictionary: dictionary)

    // Validate
    let asyncCreatedLogger = factory.getLogger("test.asyncLogger")
    XCTAssertTrue(asyncCreatedLogger.asynchronous)
  }

  // MARK: Root logger tests

  func testReadConfigurationWithRootLoggerUpdatesIt() {
    let appenderDictionary = [LoggerFactory.DictionaryKey.ClassName.rawValue: "StdOutAppender",
      LoggerFactory.DictionaryKey.Identifier.rawValue: "test appender"]
    let rootLoggerDictionary = [Logger.DictionaryKey.AppenderIds.rawValue: ["test appender"],
      Logger.DictionaryKey.ThresholdLevel.rawValue: "info"]
    
    factory.rootLogger.thresholdLevel = LogLevel.Error
    factory.rootLogger.appenders = [MemoryAppender("MemoryAppender")]
    
    let dictionary: Dictionary<String, AnyObject> = [LoggerFactory.DictionaryKey.Appenders.rawValue: [appenderDictionary],
      LoggerFactory.DictionaryKey.RootLogger.rawValue: rootLoggerDictionary]
    
    // Execute
    try! factory.readConfiguration(fromDictionary: dictionary)
    
    // Validate
    XCTAssertEqual(factory.rootLogger.thresholdLevel, LogLevel.Info)
    XCTAssertEqual(factory.rootLogger.appenders.count, 1)
    if(factory.rootLogger.appenders.count > 0) { 
      XCTAssertEqual(factory.rootLogger.appenders[0].identifier, "test appender")
    }
  }
  
  func testReadConfigurationWithNonDictionaryRootLoggerThrowsError() {
    // Execute & validate
    XCTAssertThrows { try self.factory.readConfiguration(fromDictionary: ["RootLogger": "string value"]); }
  }
  
  // Mark: Load from file tests
  func testLoadValidCompletePlistFile() {
    let filePath = Bundle(for: self.dynamicType).pathForResource("ValidCompleteConfiguration", ofType: "plist")
    
    // Execute
		_ = XCTAssertNoThrow  { try self.factory.readConfiguration(fromPlistFile: filePath!); }
    
    // Validate loggers
    XCTAssertEqual(self.factory.rootLogger.thresholdLevel, LogLevel.Info)
    XCTAssertEqual(self.factory.loggers.count, 2)
    let logger1 = self.factory.getLogger("project.feature.logger1")
    let logger2 = self.factory.getLogger("project.feature.logger2")
    XCTAssertNil(logger1.parent)
    XCTAssertNil(logger2.parent)
    XCTAssertEqual(logger1.thresholdLevel, LogLevel.Error)
    XCTAssertEqual(logger2.thresholdLevel, LogLevel.Fatal)
    
    // Validate appenders
    let logger1Appender1 = logger1.appenders[0]
    let logger2Appender1 = logger1.appenders[0]
    XCTAssertTrue(logger1Appender1 === logger2Appender1)
  }
  
  // Mark: Configuration file observing
  func testLoadedConfigFileIsReloadedWhenModifiedIfRequested() {
    let configurationFilePath = try! self.createTemporaryFilePath(fileExtension: "plist")
    let loggerDictionary = [
      LoggerFactory.DictionaryKey.Identifier.rawValue: "test.logger"]
    let configuration: NSDictionary = [LoggerFactory.DictionaryKey.Loggers.rawValue: [loggerDictionary]]
		NSDictionary().write(toFile: configurationFilePath, atomically: true)
		try! self.factory.readConfiguration(fromPlistFile: configurationFilePath, autoReload: true, reloadInterval: 0.5)

		RunLoop.current.run(until: Date(timeIntervalSinceNow: 1.0))
    
    // Execute
		configuration.write(toFile: configurationFilePath, atomically: true)

    RunLoop.current.run(until: Date(timeIntervalSinceNow: 1.0))
    

    // Validate
    XCTAssertEqual(self.factory.loggers.count, 1)
    XCTAssertNotNil(self.factory.loggers["test.logger"])
  }
  
  // MARK: Utility methods
  
  private func classNameAsString(_ obj: Any) -> String {
    return String(obj.dynamicType)
  }
}
