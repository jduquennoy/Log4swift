//
//  FunctionalTests.swift
//  Log4swift
//
//  Created by jduquennoy on 19/06/2015.
//  Copyright © 2015 jerome. All rights reserved.
//

import XCTest
@testable import Log4swift

class FunctionalTests: XCTestCase {

  func testLogToLoggerWithFormatterAndMultipleAppenders() {
    let formatter1 = try! PatternFormatter(pattern: "[%l][%n] %m");
    let formatter2 = try! PatternFormatter(pattern: "[%n][%l] %m");
    let appender1 = MemoryAppender();
    let appender2 = MemoryAppender();
    let logger = Logger(identifier: "test.identifier", level: .Info, appenders: [appender1, appender2]);

    appender1.thresholdLevel = .Warning;
    appender1.formatter = formatter1;

    appender2.thresholdLevel = .Error;
    appender2.formatter = formatter2;
    
    // Execute
    logger.debug("This log should not be printed");
    logger.warn{ return "This log should be printed to appender1 only"}
    logger.error("this log should be printed to both appenders");
    
    // Validate
    XCTAssertEqual(appender1.logMessages.count, 2, "Appender1 should have received two messages");
    XCTAssertEqual(appender2.logMessages.count, 1, "Appender2 should have received one messages");
    
    XCTAssertEqual(appender1.logMessages[0], "[\(LogLevel.Warning)][test.identifier] This log should be printed to appender1 only");
    XCTAssertEqual(appender1.logMessages[1], "[\(LogLevel.Error)][test.identifier] this log should be printed to both appenders");
    XCTAssertEqual(appender2.logMessages[0], "[test.identifier][\(LogLevel.Error)] this log should be printed to both appenders");
  }

}
