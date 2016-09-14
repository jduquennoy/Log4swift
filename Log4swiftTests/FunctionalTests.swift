//
//  FunctionalTests.swift
//  Log4swift
//
//  Created by Jérôme Duquennoy on 19/06/2015.
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

class FunctionalTests: XCTestCase {

  override func setUp() {
    super.setUp()
    LoggerFactory.sharedInstance.resetConfiguration()
  }
  
  func testLogToLoggerWithFormatterAndMultipleAppenders() {
    let formatter1 = try! PatternFormatter(identifier:"testFormatter1", pattern: "[%l][%n] %m")
    let formatter2 = try! PatternFormatter(identifier:"testFormatter2", pattern: "[%n][%l] %m")
    let appender1 = MemoryAppender()
    let appender2 = MemoryAppender()
    let logger = Logger(identifier: "test.identifier", level: .Info, appenders: [appender1, appender2])
    let factory = LoggerFactory.sharedInstance

    appender1.thresholdLevel = .Warning
    appender1.formatter = formatter1

    appender2.thresholdLevel = .Error
    appender2.formatter = formatter2
    
    try! factory.registerLogger(logger)
    
    // Execute
    Logger.getLogger("test.identifier").debug("This log to \(LogLevel.Debug) should not be printed")
    Logger.getLogger("test.identifier").warning{ return "This log should be printed to appender1 only"}
    Logger.getLogger("test.identifier").fatal("this log should be printed to both appenders")
    Logger.getLogger("test.identifier.sublogger").warning("this log should be printed to appender1 too")
    
    // Validate
    XCTAssertEqual(appender1.logMessages.count, 3, "Appender1 should have received two messages")
    XCTAssertEqual(appender2.logMessages.count, 1, "Appender2 should have received one messages")
    
    XCTAssertEqual(appender1.logMessages[0].message, "[\(LogLevel.Warning)][test.identifier] This log should be printed to appender1 only")
    XCTAssertEqual(appender1.logMessages[1].message, "[\(LogLevel.Fatal)][test.identifier] this log should be printed to both appenders")
    XCTAssertEqual(appender1.logMessages[2].message, "[\(LogLevel.Warning)][test.identifier.sublogger] this log should be printed to appender1 too")

    XCTAssertEqual(appender2.logMessages[0].message, "[test.identifier][\(LogLevel.Fatal)] this log should be printed to both appenders")
  }
  
  func testCurrentFileNameAndLineAndFunctionIsSentWhenLoggingString() {
    let formatter = try! PatternFormatter(identifier:"testFormatter", pattern: "[%F]:[%L]:[%M] %m")
    let appender = MemoryAppender()
    appender.thresholdLevel = .Debug
    appender.formatter = formatter
    let logger = Logger(identifier: "test.identifier", level: .Debug, appenders: [appender])
    let file = #file
    let function = #function
    let previousLine: Int
    
    // Execute
    previousLine = #line
    logger.debug("This is a debug message")
    
    // Validate
    XCTAssertEqual(appender.logMessages[0].message, "[\(file)]:[\(previousLine + 1)]:[\(function)] This is a debug message")
  }
  
  func testCurrentFileNameAndLineAndFunctionIsSentWhenLoggingStringWithFormat() {
    let formatter = try! PatternFormatter(identifier:"testFormatter", pattern: "[%F]:[%L]:[%M] %m")
    let appender = MemoryAppender()
    appender.thresholdLevel = .Debug
    appender.formatter = formatter
    let logger = Logger(identifier: "test.identifier", level: .Debug, appenders: [appender])
    let file = #file
    let function = #function
    let previousLine: Int
		
    // Execute
    previousLine = #line
		logger.debug("This is a %@ message", LogLevel.Debug.description)
    
    // Validate
    XCTAssertEqual(appender.logMessages[0].message, "[\(file)]:[\(previousLine + 1)]:[\(function)] This is a \(LogLevel.Debug.description) message")
  }
  
  func testCurrentFileNameAndLineAndFunctionIsSentWhenLoggingClosure() {
    let formatter = try! PatternFormatter(identifier:"testFormatter", pattern: "[%F]:[%L]:[%M] %m")
    let appender = MemoryAppender()
    appender.thresholdLevel = .Debug
    appender.formatter = formatter
    let logger = Logger(identifier: "test.identifier", level: .Debug, appenders: [appender])
    let file = #file
    let function = #function
    let previousLine: Int
    
    // Execute
    previousLine = #line
    logger.debug {"This is a debug message"}
    
    // Validate
    XCTAssertEqual(appender.logMessages[0].message, "[\(file)]:[\(previousLine + 1)]:[\(function)] This is a debug message")
  }
}
