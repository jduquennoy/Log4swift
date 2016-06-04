//
//  LoggerFactoryTests.swift
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

import XCTest
@testable import Log4swift

class LoggerFactoryTests: XCTestCase {
  var factory = LoggerFactory()
  
  override func setUp() {
    super.setUp()
    
    LoggerFactory.sharedInstance.resetConfiguration()
    factory = LoggerFactory()
  }
  
  override func tearDown() {
    super.tearDown()
  }

  func testSharedFactoryAlwaysReturnsTheSameObject() {
    // Execute
    let sharedFactory1 = LoggerFactory.sharedInstance
    let sharedFactory2 = LoggerFactory.sharedInstance
    NSLog("ping")
    // Validate
    XCTAssert(sharedFactory1 === sharedFactory2, "Shared factory should always be the same object")
  }
  
  func testClassMethodToGetLoggerReturnsSameLoggerAsSharedInstance() {
    let logger1 = LoggerFactory.getLogger("test.logger")
    let logger2 = LoggerFactory.sharedInstance.getLogger("test.logger")
    
    XCTAssert(logger1 === logger2, "class method to get logger should return the same logger as shared instance")
  }
  
  func testFactoryThrowsErrorWhenTryingToRegisterALoggerWithEmptyIdentifier() {
    do {
      let logger = Logger(identifier: "", level: .Info, appenders: [])

      // Execute
      try self.factory.registerLogger(logger)
      
      // Validate (we should not reach that point
      XCTFail("Registering a logger with empty identifier should raise an error")
    } catch {
      // nothing, this is expected
    }
  }
  
  func testFactoryProvidesCopyOfRootLoggerByDefault() {
    // Execute
    let foundLogger = self.factory.getLogger("undefined.identifer")
    
    // Validate
    let rootLogger = self.factory.rootLogger
    XCTAssertEqual(foundLogger.thresholdLevel, rootLogger.thresholdLevel, "The obtained logger should have the same threshold as the root logger")
    XCTAssertTrue(foundLogger.appenders.elementsEqual(rootLogger.appenders, isEquivalent: {$0 === $1}), "The created logger should have the same appenders as the closest one")
    XCTAssertEqual(foundLogger.identifier, "undefined.identifer", "The created logger should have the requested identifier")
  }

  func testFactoryProvidesLoggerThatExactlyMatchesTheRequestedIdentifier() {
    let logger = Logger(identifier: "test.logger.identifier", level: .Info, appenders: [StdOutAppender("test.appender")])
    let logger2 = Logger(identifier: "test.logger.anotherIdentifier", level: .Info, appenders: [StdOutAppender("test.appender")])
    
    try! self.factory.registerLogger(logger)
    try! self.factory.registerLogger(logger2)
    
    // Execute
    let foundLogger = self.factory.getLogger("test.logger.identifier")
    
    // Validate
    XCTAssert(foundLogger === logger, "Factory should return registered logger that exactly matches the requested identifier")
  }
  
  func testFactoryCreatesLoggerBasedOnTheClosestOneIfNoExactMatch() {
    let logger1 = Logger(identifier: "test.logger", level:.Info, appenders: [StdOutAppender("test.appender")])
    let logger2 = Logger(identifier: "test.logger.identifier", level: .Info, appenders: [StdOutAppender("test.appender")])
    
    try! self.factory.registerLogger(logger1)
    try! self.factory.registerLogger(logger2)
    
    // Execute
    let foundLogger = self.factory.getLogger("test.logger.identifier.plus.some.more")
    
    // Validate
    XCTAssertFalse(foundLogger === logger2, "The factory should have created a new logger")
    XCTAssertEqual(foundLogger.identifier, "test.logger.identifier.plus.some.more", "The created logger should have the requested identifier")
    XCTAssertEqual(foundLogger.thresholdLevel, logger2.thresholdLevel, "The created logger should have the same threshold as the closest one")
    XCTAssertTrue(foundLogger.appenders.elementsEqual(logger2.appenders, isEquivalent: {$0 === $1}), "The created logger should have the same appenders as the closest one")
  }

  func testRequestingTwiceTheSameNonDefinedLoggerShouldReturnTheSameObject() {
    let logger1 = Logger(identifier: "test.logger", level:.Info, appenders: [StdOutAppender("test.appender")])
    let logger2 = Logger(identifier: "test.logger.identifier", level: .Info, appenders: [StdOutAppender("test.appender")])
    
    try! self.factory.registerLogger(logger1)
    try! self.factory.registerLogger(logger2)
    
    // Execute
    let foundLogger1 = self.factory.getLogger("test.logger.identifier.plus.some.more")
    let foundLogger2 = self.factory.getLogger("test.logger.identifier.plus.some.more")
    
    // Validate
    XCTAssertTrue(foundLogger1 === foundLogger2, "The two found loggers should be the same object")
  }

  func testFactoryDoesNotProvidesLoggerWithMorePreciseIdentifiers() {
    let logger = Logger(identifier: "test.logger.identifier.plus.some.more", level: .Info, appenders: [StdOutAppender("test.appender")])
    
    try! self.factory.registerLogger(logger)
    
    // Execute
    let foundLogger = self.factory.getLogger("test.logger.identifier")
    
    // Validate
    let rootLogger = self.factory.rootLogger
    XCTAssertEqual(foundLogger.thresholdLevel, rootLogger.thresholdLevel, "The obtained logger should have the same threshold as the root logger")
    XCTAssertTrue(foundLogger.appenders.elementsEqual(rootLogger.appenders, isEquivalent: {$0 === $1}), "The created logger should have the same appenders as the closest one")
    XCTAssertEqual(foundLogger.identifier, "test.logger.identifier", "The created logger should have the requested identifier")
  }
  
  func testGeneratedLoggersAreDeletedWhenRegisteringANewLogger() {
    let registeredLogger1 = Logger(identifier: "test.logger", level: .Info, appenders: [StdOutAppender("test.appender")])
    let registeredLogger2 = Logger(identifier: "test.logger2", level: .Info, appenders: [StdOutAppender("test.appender")])
    try! self.factory.registerLogger(registeredLogger1)
    
    let generatedLogger = self.factory.getLogger("test.logger.generated")
    
    // Execute
    try! self.factory.registerLogger(registeredLogger2)
    
    // Validate
    XCTAssertNil(self.factory.loggers["test.logger.generated"])
    XCTAssertFalse(generatedLogger === self.factory.getLogger("test.logger.generated"))
  }
  
  func testRegisteredLoggersAreNotDeletedWhenRegisteringANewLogger() {
    let registeredLogger1 = Logger(identifier: "test.logger", level: .Info, appenders: [StdOutAppender("test.appender")])
    let registeredLogger2 = Logger(identifier: "test.logger2", level: .Info, appenders: [StdOutAppender("test.appender")])
    try! self.factory.registerLogger(registeredLogger1)
    
    // Execute
    try! self.factory.registerLogger(registeredLogger2)
    
    // Validate
    XCTAssertTrue(registeredLogger1 === self.factory.getLogger("test.logger"))
  }
  
  // MARK: - Convenience config methods
  
  func testConfigureForXCodeReplacesCurrentConfiguration() {
    self.factory.rootLogger.appenders = [MemoryAppender(), MemoryAppender()]
    try! self.factory.registerLogger(Logger(identifier: "test.logger"))
    
    // Execute
    self.factory.configureForXcodeConsole()
    
    // Validate
    XCTAssertEqual(self.factory.rootLogger.appenders.count, 1)
    XCTAssertEqual(self.factory.rootLogger.appenders[0].className, StdOutAppender.className())
    XCTAssertEqual(self.factory.loggers.count, 0)
  }
  
  func testConfigureForXCodeConsoleSetsColorsForAllLevels() {
    // Execute
    self.factory.configureForXcodeConsole()
    
    // Validate
    if let xcodeAppender = self.factory.rootLogger.appenders[0] as? StdOutAppender {
      XCTAssertEqual(xcodeAppender.textColors.count, 6)
    }
  }
  
  func testConfigureForXCodeConsoleSetsPattern() {
    // Execute
    self.factory.configureForXcodeConsole()
    
    // Validate
    XCTAssertNotNil(self.factory.rootLogger.appenders[0].formatter, "Formatter was not set on the appender")
  }
  
  func testConfigureForSystemConsoleReplacesCurrentConfiguration() {
    self.factory.rootLogger.appenders = [MemoryAppender(), MemoryAppender()]
    try! self.factory.registerLogger(Logger(identifier: "test.logger"))
    
    // Execute
    self.factory.configureForSystemConsole()
    
    // Validate
    XCTAssertEqual(self.factory.rootLogger.appenders.count, 1)
    XCTAssertEqual(self.factory.rootLogger.appenders[0].className, ASLAppender.className())
    XCTAssertEqual(self.factory.loggers.count, 0)
  }
  
  func testConfigureForNSLoggerReplacesCurrentConfiguration() {
    self.factory.rootLogger.appenders = [MemoryAppender(), MemoryAppender()]
    try! self.factory.registerLogger(Logger(identifier: "test.logger"))
    
    // Execute
    self.factory.configureForNSLogger()
    
    // Validate
    XCTAssertEqual(self.factory.rootLogger.appenders.count, 1)
    XCTAssertEqual(self.factory.rootLogger.appenders[0].className, NSLoggerAppender.className())
    XCTAssertEqual(self.factory.loggers.count, 0)
  }
  
}
