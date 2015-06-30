//
//  LoggerFactoryTests.swift
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

class LoggerFactoryTests: XCTestCase {
  var factory = LoggerFactory();
  
  override func setUp() {
    super.setUp()
    
    factory = LoggerFactory()
  }
  
  override func tearDown() {
    super.tearDown()
  }

  func testSharedFactoryAlwaysReturnsTheSameObject() {
    // Execute
    let sharedFactory1 = LoggerFactory.sharedInstance;
    let sharedFactory2 = LoggerFactory.sharedInstance;
    
    // Validate
    XCTAssert(sharedFactory1 === sharedFactory2, "Shared factory should always be the same object");
  }
  
  func testFactoryThrowsErrorWhenTryingToRegisterALoggerWithEmptyIdentifier() {
    do {
      let logger = Logger(identifier: "", level: .Info, appenders: []);

      // Execute
      try self.factory.registerLogger(logger);
      
      // Validate (we should not reach that point
      XCTFail("Registering a logger with empty identifier should raise an error");
    } catch {
      // nothing, this is expected
    }
  }
  
  func testFactoryProvidesCopyOfRootLoggerByDefault() {
    // Execute
    let foundLogger = self.factory.getLogger("undefined.identifer");
    
    // Validate
    let rootLogger = self.factory.rootLogger;
    XCTAssertEqual(foundLogger.thresholdLevel, rootLogger.thresholdLevel, "The obtained logger should have the same threshold as the root logger");
    XCTAssertTrue(foundLogger.appenders.elementsEqual(rootLogger.appenders, isEquivalent: {$0 === $1}), "The created logger should have the same appenders as the closest one");
    XCTAssertEqual(foundLogger.identifier, "undefined.identifer", "The created logger should have the requested identifier");
  }

  func testFactoryProvidesLoggerThatExactlyMatchesTheRequestedIdentifier() {
    let logger = Logger(identifier: "test.logger.identifier", level: .Info, appenders: [ConsoleAppender("test.appender")]);
    let logger2 = Logger(identifier: "test.logger.anotherIdentifier", level: .Info, appenders: [ConsoleAppender("test.appender")]);
    
    try! self.factory.registerLogger(logger);
    try! self.factory.registerLogger(logger2);
    
    // Execute
    let foundLogger = self.factory.getLogger("test.logger.identifier");
    
    // Validate
    XCTAssert(foundLogger === logger, "Factory should return registered logger that exactly matches the requested identifier");
  }
  
  func testFactoryCreatesLoggerBasedOnTheClosestOneIfNoExactMatch() {
    let logger1 = Logger(identifier: "test.logger", level:.Info, appenders: [ConsoleAppender("test.appender")]);
    let logger2 = Logger(identifier: "test.logger.identifier", level: .Info, appenders: [ConsoleAppender("test.appender")]);
    
    try! self.factory.registerLogger(logger1);
    try! self.factory.registerLogger(logger2);
    
    // Execute
    let foundLogger = self.factory.getLogger("test.logger.identifier.plus.some.more");
    
    // Validate
    XCTAssertFalse(foundLogger === logger2, "The factory should have created a new logger");
    XCTAssertEqual(foundLogger.identifier, "test.logger.identifier.plus.some.more", "The created logger should have the requested identifier");
    XCTAssertEqual(foundLogger.thresholdLevel, logger2.thresholdLevel, "The created logger should have the same threshold as the closest one");
    XCTAssertTrue(foundLogger.appenders.elementsEqual(logger2.appenders, isEquivalent: {$0 === $1}), "The created logger should have the same appenders as the closest one");
  }

  func testRequestingTwiceTheSameNonDefinedLoggerShouldReturnTheSameObject() {
    let logger1 = Logger(identifier: "test.logger", level:.Info, appenders: [ConsoleAppender("test.appender")]);
    let logger2 = Logger(identifier: "test.logger.identifier", level: .Info, appenders: [ConsoleAppender("test.appender")]);
    
    try! self.factory.registerLogger(logger1);
    try! self.factory.registerLogger(logger2);
    
    // Execute
    let foundLogger1 = self.factory.getLogger("test.logger.identifier.plus.some.more");
    let foundLogger2 = self.factory.getLogger("test.logger.identifier.plus.some.more");
    
    // Validate
    XCTAssertTrue(foundLogger1 === foundLogger2, "The two found loggers should be the same object");
  }

  func testFactoryDoesNotProvidesLoggerWithMorePreciseIdentifiers() {
    let logger = Logger(identifier: "test.logger.identifier.plsu.some.more", level: .Info, appenders: [ConsoleAppender("test.appender")]);
    
    try! self.factory.registerLogger(logger);
    
    // Execute
    let foundLogger = self.factory.getLogger("test.logger.identifier.plus.some.more");
    
    // Validate
    let rootLogger = self.factory.rootLogger;
    XCTAssertEqual(foundLogger.thresholdLevel, rootLogger.thresholdLevel, "The obtained logger should have the same threshold as the root logger");
    XCTAssertTrue(foundLogger.appenders.elementsEqual(rootLogger.appenders, isEquivalent: {$0 === $1}), "The created logger should have the same appenders as the closest one");
    XCTAssertEqual(foundLogger.identifier, "test.logger.identifier.plus.some.more", "The created logger should have the requested identifier");
  }
  
  func testLoggerSendsLogToAllAppenders() {
    let appender1 = MemoryAppender();
    let appender2 = MemoryAppender();
    let logger = Logger(identifier: "test.logger", level: LogLevel.Debug, appenders: [appender1, appender2]);
    
    // Execute
    logger.info("ping");
    
    // Validate
    XCTAssertEqual(appender1.logMessages.count, 1, "Appender 1 should have received one message");
    XCTAssertEqual(appender2.logMessages.count, 1, "Appender 2 should have received one message");
  }

  func testLoggerDoNotSendMessagesToAppendersIfLevelIsEqualToThreshold() {
    let appender = MemoryAppender();
    let logger = Logger(identifier: "test.logger", level: LogLevel.Warning, appenders: [appender]);
    
    // Execute
    logger.warn("Info message");
    
    // Validate
    XCTAssertEqual(appender.logMessages.count, 1, "The message should have been sent to the appender");
  }

  func testLoggerDoNotSendMessagesToAppendersIfThresholdLevelIsNotReached() {
    let appender = MemoryAppender();
    let logger = Logger(identifier: "test.logger", level: LogLevel.Warning, appenders: [appender]);
    
    // Execute
    logger.info("Info message");
    
    // Validate
    XCTAssertEqual(appender.logMessages.count, 0, "The message should not have been sent to the appender");
  }
  
  // MARK: Performance tests
  
  func testGetLoggerForSamedIdentifierPerformance() {
    for index in 1...10 {
      try! self.factory.registerLogger(Logger(identifier: "test.identifier.\(index)", level: .Info, appenders: [ConsoleAppender("test.appender")]));
    }
    
    self.measureBlock() {
      for _ in 1...10000 {
        self.factory.getLogger("test.identifier");
      }
    }
  }
  
  func testGetLoggerForDifferentIdentifierPerformance() {
    for index in 1...10 {
      try! self.factory.registerLogger(Logger(identifier: "test.identifier.\(index * 100)", level: .Info, appenders: [ConsoleAppender("test.appender")]));
    }
    
    self.measureBlock() {
      for index in 1...10000 {
        self.factory.getLogger("test.identifier.\(index)");
      }
    }
  }
  
}
