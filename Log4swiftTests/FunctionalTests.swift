//
//  FunctionalTests.swift
//  Log4swift
//
//  Created by Jérôme Duquennoy on 19/06/2015.
//  Copyright © 2015 jerome. All rights reserved.
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

class FunctionalTests: XCTestCase {

  override func setUp() {
    super.setUp()
    LoggerFactory.sharedInstance.resetConfiguration();
  }
  
  func testLogToLoggerWithFormatterAndMultipleAppenders() {
    let formatter1 = try! PatternFormatter(identifier:"testFormatter1", pattern: "[%l][%n] %m");
    let formatter2 = try! PatternFormatter(identifier:"testFormatter2", pattern: "[%n][%l] %m");
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
    Logger.getLogger("test.identifier").debug("This log to \(LogLevel.Debug) should not be printed");
    Logger.getLogger("test.identifier").warn{ return "This log should be printed to appender1 only"}
    Logger.getLogger("test.identifier").fatal("this log should be printed to both appenders");
    Logger.getLogger("test.identifier.sublogger").warn("this log should be printed to appender1 too");
    
    // Validate
    XCTAssertEqual(appender1.logMessages.count, 3, "Appender1 should have received two messages");
    XCTAssertEqual(appender2.logMessages.count, 1, "Appender2 should have received one messages");
    
    XCTAssertEqual(appender1.logMessages[0].message, "[\(LogLevel.Warning)][test.identifier] This log should be printed to appender1 only");
    XCTAssertEqual(appender1.logMessages[1].message, "[\(LogLevel.Fatal)][test.identifier] this log should be printed to both appenders");
    XCTAssertEqual(appender1.logMessages[2].message, "[\(LogLevel.Warning)][test.identifier.sublogger] this log should be printed to appender1 too");

    XCTAssertEqual(appender2.logMessages[0].message, "[test.identifier][\(LogLevel.Fatal)] this log should be printed to both appenders");
  }

}
