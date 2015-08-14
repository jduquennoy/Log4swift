//
//  Logger+objeciveCTests.swift
//  Log4swift
//
//  Created by Jérôme Duquennoy on 29/07/15.
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
