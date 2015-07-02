//
//  LoggerTests.swift
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

import XCTest
@testable import Log4swift

class LoggerTests: XCTestCase {

  override func setUp() {
    super.setUp()
  }
  
  override func tearDown() {
    super.tearDown()
  }

  func testLoggerDefaultLevelIsDebug() {
    let logger = Logger();
    
    XCTAssertEqual(logger.thresholdLevel , LogLevel.Debug, "Default log level for loggers should be Debug");
  }

  func testLogWithClosureWillNotCallClosureIfLoggerThresholdsPreventsLogging() {
    var closureCalled = false;
    let logger = Logger();
    
    logger.thresholdLevel = .Info;
    
    // Execute
    logger.debug({
      closureCalled = true;
      return "";
    });
    
    // Validate
    XCTAssertFalse(closureCalled, "Closure should not be call if logger threshold is not reached")
  }

  func testLogWithClosureWillNotCallClosureIfAppendersThresholdsPreventsLogging() {
    var closureCalled = false;
    let logger = Logger();
    let appender1 = MemoryAppender();
    let appender2 = MemoryAppender();
    
    appender1.thresholdLevel = .Info
    appender2.thresholdLevel = .Info
    logger.appenders = [appender1, appender2];
    
    // Execute
    logger.debug({
      closureCalled = true;
      return "";
    });
    
    // Validate
    XCTAssertFalse(closureCalled, "Closure should not be call if no appender threshold is reached")
  }
  
  func testLogWithClosureWillCallClosureIfLogWillBeIssuedByAtLeastOneAppender() {
    var closureCalled = false;
    let logger = Logger();
    let appender1 = MemoryAppender();
    let appender2 = MemoryAppender();
    
    appender1.thresholdLevel = .Info
    appender2.thresholdLevel = .Debug
    logger.appenders = [appender1, appender2];
    
    // Execute
    logger.debug({
      closureCalled = true;
      return "";
    });
    
    // Validate
    XCTAssertTrue(closureCalled, "Closure should  have been called")
  }
  
  func testStaticLogDebugMessageMethodsLogToRootLogger() {
    let memoryAppender = MemoryAppender();
    LoggerFactory.sharedInstance.rootLogger.appenders.removeAll();
    LoggerFactory.sharedInstance.rootLogger.appenders.append(memoryAppender);
    
    //Execute
    Logger.debug("ping");
    
    // Validate
    XCTAssertEqual(memoryAppender.logMessages.count, 1);
    XCTAssertEqual(memoryAppender.logMessages[0].level, .Debug);
  }
  
  func testStaticLogInfoMessageMethodsLogToRootLogger() {
    let memoryAppender = MemoryAppender();
    LoggerFactory.sharedInstance.rootLogger.appenders.removeAll();
    LoggerFactory.sharedInstance.rootLogger.appenders.append(memoryAppender);
    
    //Execute
    Logger.info("ping");
    
    // Validate
    XCTAssertEqual(memoryAppender.logMessages.count, 1);
    XCTAssertEqual(memoryAppender.logMessages[0].level, .Info);
  }
  
  func testStaticLogWarningMessageMethodsLogToRootLogger() {
    let memoryAppender = MemoryAppender();
    LoggerFactory.sharedInstance.rootLogger.appenders.removeAll();
    LoggerFactory.sharedInstance.rootLogger.appenders.append(memoryAppender);
    
    //Execute
    Logger.warn("ping");
    
    // Validate
    XCTAssertEqual(memoryAppender.logMessages.count, 1);
    XCTAssertEqual(memoryAppender.logMessages[0].level, .Warning);
  }
  
  func testStaticLogErrorMessageMethodsLogToRootLogger() {
    let memoryAppender = MemoryAppender();
    LoggerFactory.sharedInstance.rootLogger.appenders.removeAll();
    LoggerFactory.sharedInstance.rootLogger.appenders.append(memoryAppender);
    
    //Execute
    Logger.error("ping");
    
    // Validate
    XCTAssertEqual(memoryAppender.logMessages.count, 1);
    XCTAssertEqual(memoryAppender.logMessages[0].level, .Error);
  }
  
  func testStaticLogFatalMessageMethodsLogToRootLogger() {
    let memoryAppender = MemoryAppender();
    LoggerFactory.sharedInstance.rootLogger.appenders.removeAll();
    LoggerFactory.sharedInstance.rootLogger.appenders.append(memoryAppender);
    
    //Execute
    Logger.fatal("ping");
    
    // Validate
    XCTAssertEqual(memoryAppender.logMessages.count, 1);
    XCTAssertEqual(memoryAppender.logMessages[0].level, .Fatal);
  }
  
  func testStaticLogDebugClosureMethodsLogToRootLogger() {
    let memoryAppender = MemoryAppender();
    LoggerFactory.sharedInstance.rootLogger.appenders.removeAll();
    LoggerFactory.sharedInstance.rootLogger.appenders.append(memoryAppender);
    
    //Execute
    Logger.debug{ return "ping"; };
    
    // Validate
    XCTAssertEqual(memoryAppender.logMessages.count, 1);
    XCTAssertEqual(memoryAppender.logMessages[0].level, .Debug);
  }
  
  func testStaticLogInfoClosureMethodsLogToRootLogger() {
    let memoryAppender = MemoryAppender();
    LoggerFactory.sharedInstance.rootLogger.appenders.removeAll();
    LoggerFactory.sharedInstance.rootLogger.appenders.append(memoryAppender);
    
    //Execute
    Logger.info{ return "ping"; };
    
    // Validate
    XCTAssertEqual(memoryAppender.logMessages.count, 1);
    XCTAssertEqual(memoryAppender.logMessages[0].level, .Info);
  }
  
  func testStaticLogWarningClosureMethodsLogToRootLogger() {
    let memoryAppender = MemoryAppender();
    LoggerFactory.sharedInstance.rootLogger.appenders.removeAll();
    LoggerFactory.sharedInstance.rootLogger.appenders.append(memoryAppender);
    
    //Execute
    Logger.warn{ return "ping"; };
    
    // Validate
    XCTAssertEqual(memoryAppender.logMessages.count, 1);
    XCTAssertEqual(memoryAppender.logMessages[0].level, .Warning);
  }
  
  func testStaticLogErrorClosureMethodsLogToRootLogger() {
    let memoryAppender = MemoryAppender();
    LoggerFactory.sharedInstance.rootLogger.appenders.removeAll();
    LoggerFactory.sharedInstance.rootLogger.appenders.append(memoryAppender);
    
    //Execute
    Logger.error{ return "ping"; };
    
    // Validate
    XCTAssertEqual(memoryAppender.logMessages.count, 1);
    XCTAssertEqual(memoryAppender.logMessages[0].level, .Error);
  }
  
  func testStaticLogFatalClosureMethodsLogToRootLogger() {
    let memoryAppender = MemoryAppender();
    LoggerFactory.sharedInstance.rootLogger.appenders.removeAll();
    LoggerFactory.sharedInstance.rootLogger.appenders.append(memoryAppender);
    
    //Execute
    Logger.fatal{ return "ping"; };
    
    // Validate
    XCTAssertEqual(memoryAppender.logMessages.count, 1);
    XCTAssertEqual(memoryAppender.logMessages[0].level, .Fatal);
  }
  
  func testCreateLoggerFromDictionaryWithNoIdentifierThrowsError() {
    let dictionary = Dictionary<String, AnyObject>();
    
    XCTAssertThrows { try Logger(dictionary, availableAppenders: Array<Appender>()) };
  }
  
  func testCreateLoggerFromDictionaryWithEmptyIdentifierThrowsError() {
    let dictionary: Dictionary<String, AnyObject> = [Logger.DictionaryKey.Identifier.rawValue: ""];
    
    XCTAssertThrows { try Logger(dictionary, availableAppenders: Array<Appender>()) };
  }
  
  func testCreateLoggerFromDictionaryUsesProvidedIdentifier() {
    let dictionary: Dictionary<String, AnyObject> = [Logger.DictionaryKey.Identifier.rawValue: "test.logger"];    
    
    // Execute
    let logger = try! Logger(dictionary, availableAppenders: Array<Appender>());
    
    // Validate
    XCTAssertEqual(logger.identifier, "test.logger");
  }
  
  func testCreateLoggerFromDictionaryWithoutLevelUsesDebugAsDefaultValue() {
    let dictionary: Dictionary<String, AnyObject> = [Logger.DictionaryKey.Identifier.rawValue: "test.logger"];    
    
    // Execute
    let logger = try! Logger(dictionary, availableAppenders: Array<Appender>());
    
    // Validate
    XCTAssertEqual(logger.thresholdLevel, LogLevel.Debug);
  }
  
  func testCreateLoggerFromDictionaryWithInvalidLevelThrowsError() {
    let dictionary: Dictionary<String, AnyObject> = [Logger.DictionaryKey.Identifier.rawValue: "test.logger",
      Logger.DictionaryKey.Level.rawValue: "invalidLevel"];
    
    // Execute & Validate
    XCTAssertThrows { try Logger(dictionary, availableAppenders: Array<Appender>()) };
  }
  
  func testCreateLoggerFromDictionaryWithValidLevelUsesProvidedValue() {
    let dictionary: Dictionary<String, AnyObject> = [Logger.DictionaryKey.Identifier.rawValue: "test.logger",
      Logger.DictionaryKey.Level.rawValue: "info"];    
    
    // Execute
    let logger = try! Logger(dictionary, availableAppenders: Array<Appender>());
    
    // Validate
    XCTAssertEqual(logger.thresholdLevel, LogLevel.Info);
  }

  func testCreateLoggerFromDictionaryWithoutAppenderUsesOneDefaultAppender() {
    let dictionary: Dictionary<String, AnyObject> = [Logger.DictionaryKey.Identifier.rawValue: "test.logger",
      Logger.DictionaryKey.Level.rawValue: "info"];
    
    // Execute
    let logger = try! Logger(dictionary, availableAppenders: Array<Appender>());
    
    // Validate
    XCTAssertEqual(logger.appenders.count, 1);
    
  }
  
  func testCreateLoggerWithNotAvailableAppenderIdThrowsError() {
  let dictionary: Dictionary<String, AnyObject> = [Logger.DictionaryKey.Identifier.rawValue: "test.logger",
    Logger.DictionaryKey.AppenderIds.rawValue: ["id1", "id2"]];
  
    // Execute
    XCTAssertThrows { try Logger(dictionary, availableAppenders: Array<Appender>()) };
  }
  
  func testCreateLoggerWithExistingAppenderIdUsesThem() {
    let appender1 = ConsoleAppender("id1");
    let appender2 = ConsoleAppender("id2");
    
    let dictionary: Dictionary<String, AnyObject> = [Logger.DictionaryKey.Identifier.rawValue: "test.logger",
    Logger.DictionaryKey.AppenderIds.rawValue: ["id1", "id2"]];
    
    // Execute
    let logger = try! Logger(dictionary, availableAppenders: [appender1, appender2]);
  
    // Validate
    XCTAssertEqual(logger.appenders.count, 2);
    XCTAssertTrue(logger.appenders[0] === appender1);
    XCTAssertTrue(logger.appenders[1] === appender2);
  }
  
  func testCopyInitializerCreatesIdenticalLoggerWithNewIdentifier() {
    let appender1 = ConsoleAppender("id1");
    let logger1 = Logger(identifier: "test.logger", level: LogLevel.Info, appenders: [appender1]);
    
    // Execute
    let logger2 = Logger(loggerToCopy: logger1, newIdentifier: "test.logger2");
    
    // Validate
    XCTAssertEqual(logger2.identifier, "test.logger2");
    XCTAssertEqual(logger2.thresholdLevel, logger1.thresholdLevel);
    XCTAssertEqual(logger2.appenders.count, logger1.appenders.count);
    XCTAssertTrue(logger2.appenders[0] === logger1.appenders[0]);
  }

  func testCopyInitializerCreatesIndependentLoggers() {
    let appender1 = ConsoleAppender("id1");
    let appender2 = ConsoleAppender("id2");
    let logger1 = Logger(identifier: "test.logger", level: LogLevel.Info, appenders: [appender1]);
    
    // Execute
    let logger2 = Logger(loggerToCopy: logger1, newIdentifier: "test.logger2");
    
    // Validate
    logger2.appenders.removeAll();
    logger2.appenders.append(appender2);
    XCTAssertTrue(logger1.appenders[0] === appender1);
    XCTAssertTrue(logger2.appenders[0] === appender2);
  }
}
