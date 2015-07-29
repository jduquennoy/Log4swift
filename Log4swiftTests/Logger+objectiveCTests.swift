//
//  Logger+objeciveCTests.swift
//  Log4swift
//
//  Created by Jérôme Duquennoy on 29/07/15.
//  Copyright © 2015 jerome. All rights reserved.
//

import XCTest
@testable import Log4swift

class LoggerObjectiveCTests: XCTestCase {
  
  func testLoggerObjectiveCLogStringMethodsLogsAtExpectedLevel() {
    let appender = MemoryAppender();
    let logger = Logger(identifier: "test.logger", level: LogLevel.Debug, appenders: [appender]);
    
    // Execute
    logger.logDebug("debug");
    logger.logInfo("info");
    logger.logWarning("warning");
    logger.logError("error");
    logger.logFatal("fatal");
    
    // Validate
    XCTAssertEqual(appender.logMessages[0].level, LogLevel.Debug);
    XCTAssertEqual(appender.logMessages[1].level, LogLevel.Info);
    XCTAssertEqual(appender.logMessages[2].level, LogLevel.Warning);
    XCTAssertEqual(appender.logMessages[3].level, LogLevel.Error);
    XCTAssertEqual(appender.logMessages[4].level, LogLevel.Fatal);
  }
  
  func testLoggerObjectiveCLogBlocMethodsLogsAtExpectedLevel() {
    let appender = MemoryAppender();
    let logger = Logger(identifier: "test.logger", level: LogLevel.Debug, appenders: [appender]);
    
    // Execute
    logger.logDebugBloc({"Debug"});
    logger.logInfoBloc({"info"});
    logger.logWarningBloc({"warning"});
    logger.logErrorBloc({"error"});
    logger.logFatalBloc({"fatal"});
    
    // Validate
    XCTAssertEqual(appender.logMessages[0].level, LogLevel.Debug);
    XCTAssertEqual(appender.logMessages[1].level, LogLevel.Info);
    XCTAssertEqual(appender.logMessages[2].level, LogLevel.Warning);
    XCTAssertEqual(appender.logMessages[3].level, LogLevel.Error);
    XCTAssertEqual(appender.logMessages[4].level, LogLevel.Fatal);
  }
  
}
