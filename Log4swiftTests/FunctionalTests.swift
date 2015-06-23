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
    let factory = LoggerFactory.sharedInstance;

    appender1.thresholdLevel = .Warning;
    appender1.formatter = formatter1;

    appender2.thresholdLevel = .Error;
    appender2.formatter = formatter2;
    
    try! factory.registerLogger(logger);
    
    // Execute
    Logger.getLogger("test.identifier").debug("This log should not be printed");
    Logger.getLogger("test.identifier").warn{ return "This log should be printed to appender1 only"}
    Logger.getLogger("test.identifier").error("this log should be printed to both appenders");
    Logger.getLogger("test.identifier.sublogger").warn("this log should be printed to appender1 too");
    
    // Validate
    XCTAssertEqual(appender1.logMessages.count, 3, "Appender1 should have received two messages");
    XCTAssertEqual(appender2.logMessages.count, 1, "Appender2 should have received one messages");
    
    XCTAssertEqual(appender1.logMessages[0].message, "[\(LogLevel.Warning)][test.identifier] This log should be printed to appender1 only");
    XCTAssertEqual(appender1.logMessages[1].message, "[\(LogLevel.Error)][test.identifier] this log should be printed to both appenders");
    XCTAssertEqual(appender1.logMessages[2].message, "[\(LogLevel.Warning)][test.identifier.sublogger] this log should be printed to appender1 too");

    XCTAssertEqual(appender2.logMessages[0].message, "[test.identifier][\(LogLevel.Error)] this log should be printed to both appenders");
  }

}
