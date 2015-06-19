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
  
  func testFactoryProvidesRootLoggerByDefault() {
    // Execute
    let logger = self.factory.getLogger("undefined.identifer");
    
    // Validate
    XCTAssert(logger === self.factory.rootLogger, "Root logger should be returned for unknown identifier.");
  }

  func testFactoryProvidesLoggerThatExactlyMatchesTheRequestedIdentifier() {
    let logger = Logger(identifier: "test.logger.identifier", level: .Info, appenders: [ConsoleAppender(identifier: "test.appender")]);
    let logger2 = Logger(identifier: "test.logger.anotherIdentifier", level: .Info, appenders: [ConsoleAppender(identifier: "test.appender")]);
    
    self.factory.registerLogger(logger);
    self.factory.registerLogger(logger2);
    
    // Execute
    let foundLogger = self.factory.getLogger("test.logger.identifier");
    
    // Validate
    XCTAssert(foundLogger === logger, "Factory should return registered logger that exactly matches the requested identifier");
  }
  
  func testFactoryProvidesLoggerThatMatchesTheRequestedIdentifierTheBest() {
    let logger1 = Logger(identifier: "test.logger", level:.Info, appenders: [ConsoleAppender(identifier: "test.appender")]);
    let logger2 = Logger(identifier: "test.logger.identifier", level: .Info, appenders: [ConsoleAppender(identifier: "test.appender")]);
    
    self.factory.registerLogger(logger1);
    self.factory.registerLogger(logger2);
    
    // Execute
    let foundLogger = self.factory.getLogger("test.logger.identifier.plus.some.more");
    
    // Validate
    XCTAssert(foundLogger === logger2, "Factory should return closest matching logger");
  }
  
  func testFactoryDoesNotProvidesLoggerWithMorePreciseIdentifiers() {
    let logger = Logger(identifier: "test.logger.identifier.plsu.some.more", level: .Info, appenders: [ConsoleAppender(identifier: "test.appender")]);
    
    self.factory.registerLogger(logger);
    
    // Execute
    let foundLogger = self.factory.getLogger("test.logger.identifier.plus.some.more");
    
    // Validate
    XCTAssert(foundLogger === self.factory.rootLogger, "Factory should not return a logger with a more detailed identifier");
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
      self.factory.registerLogger(Logger(identifier: "test.identifier.\(index)", level: .Info, appenders: [ConsoleAppender(identifier: "test.appender")]));
    }
    
    self.measureBlock() {
      for _ in 1...10000 {
        self.factory.getLogger("test.identifier");
      }
    }
  }
  
  func testGetLoggerForDifferentIdentifierPerformance() {
    for index in 1...10 {
      self.factory.registerLogger(Logger(identifier: "test.identifier.\(index * 100)", level: .Info, appenders: [ConsoleAppender(identifier: "test.appender")]));
    }
    
    self.measureBlock() {
      for index in 1...10000 {
        self.factory.getLogger("test.identifier.\(index)");
      }
    }
  }
  
}
