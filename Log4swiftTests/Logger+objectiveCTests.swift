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
    let appender = MemoryAppender()
    appender.thresholdLevel = .Trace
    let logger = Logger(identifier: "test.logger", level: LogLevel.Trace, appenders: [appender])
    
    // Execute
    logger.logTrace("trace")
    logger.logDebug("debug")
    logger.logInfo("info")
    logger.logWarning("warning")
    logger.logError("error")
    logger.logFatal("fatal")
    
    logger.logEntering(args: [])
    logger.logExiting(args: [])
    
    // Validate
    XCTAssertEqual(appender.logMessages[0].level, LogLevel.Trace)
    XCTAssertEqual(appender.logMessages[1].level, LogLevel.Debug)
    XCTAssertEqual(appender.logMessages[2].level, LogLevel.Info)
    XCTAssertEqual(appender.logMessages[3].level, LogLevel.Warning)
    XCTAssertEqual(appender.logMessages[4].level, LogLevel.Error)
    XCTAssertEqual(appender.logMessages[5].level, LogLevel.Fatal)
    
    XCTAssertEqual(appender.logMessages[6].level, LogLevel.Trace)
    XCTAssertEqual(appender.logMessages[7].level, LogLevel.Trace)
  }
  
  func testLoggerObjectiveCLogBlocMethodsLogsAtExpectedLevel() {
    let appender = MemoryAppender()
    appender.thresholdLevel = .Trace
    let logger = Logger(identifier: "test.logger", level: LogLevel.Trace, appenders: [appender])
    
    // Execute
    logger.logTraceBloc({"Trace"})
    logger.logDebugBloc({"Debug"})
    logger.logInfoBloc({"info"})
    logger.logWarningBloc({"warning"})
    logger.logErrorBloc({"error"})
    logger.logFatalBloc({"fatal"})
    
    logger.logEnteringBloc({ [] })
    logger.logExitingBloc({ [] })
    
    // Validate
    XCTAssertEqual(appender.logMessages[0].level, LogLevel.Trace)
    XCTAssertEqual(appender.logMessages[1].level, LogLevel.Debug)
    XCTAssertEqual(appender.logMessages[2].level, LogLevel.Info)
    XCTAssertEqual(appender.logMessages[3].level, LogLevel.Warning)
    XCTAssertEqual(appender.logMessages[4].level, LogLevel.Error)
    XCTAssertEqual(appender.logMessages[5].level, LogLevel.Fatal)
    
    XCTAssertEqual(appender.logMessages[6].level, LogLevel.Trace)
    XCTAssertEqual(appender.logMessages[7].level, LogLevel.Trace)
  }
  
  func testLoggerObjectiveCLogBlocWithFileAndLineMethodsLogsWithFileAndLine() {
    let appender = MemoryAppender()
    appender.thresholdLevel = .Trace
    let formatter = try! PatternFormatter(identifier:"testFormatter", pattern: "[%F]:[%L]:[%M] %m")
    appender.formatter = formatter
    let logger = Logger(identifier: "test.logger", level: LogLevel.Trace, appenders: [appender])
    
    // Execute
    logger.logTraceBloc({"message"}, file: "filename", line: 42, function: "function")
    logger.logDebugBloc({"message"}, file: "filename", line: 42, function: "function")
    logger.logInfoBloc({"message"}, file: "filename", line: 42, function: "function")
    logger.logWarningBloc({"message"}, file: "filename", line: 42, function: "function")
    logger.logErrorBloc({"message"}, file: "filename", line: 42, function: "function")
    logger.logFatalBloc({"message"}, file: "filename", line: 42, function: "function")
    
    // Validate
    XCTAssertEqual(appender.logMessages[0].message, "[filename]:[42]:[function] message")
    XCTAssertEqual(appender.logMessages[1].message, "[filename]:[42]:[function] message")
    XCTAssertEqual(appender.logMessages[2].message, "[filename]:[42]:[function] message")
    XCTAssertEqual(appender.logMessages[3].message, "[filename]:[42]:[function] message")
    XCTAssertEqual(appender.logMessages[4].message, "[filename]:[42]:[function] message")
    XCTAssertEqual(appender.logMessages[5].message, "[filename]:[42]:[function] message")
  }
  
  
  func testLoggerObjectiveCLogMessageWithFileAndLineMethodsLogsWithFileAndLine() {
    let appender = MemoryAppender()
    appender.thresholdLevel = .Trace
    let formatter = try! PatternFormatter(identifier:"testFormatter", pattern: "[%F]:[%L]:[%M] %m")
    appender.formatter = formatter
    let logger = Logger(identifier: "test.logger", level: LogLevel.Trace, appenders: [appender])
    
    // Execute
    logger.logTrace("message", file: "filename", line: 42, function: "function")
    logger.logDebug("message", file: "filename", line: 42, function: "function")
    logger.logInfo("message", file: "filename", line: 42, function: "function")
    logger.logWarning("message", file: "filename", line: 42, function: "function")
    logger.logError("message", file: "filename", line: 42, function: "function")
    logger.logFatal("message", file: "filename", line: 42, function: "function")
    
    // Validate
    XCTAssertEqual(appender.logMessages[0].message, "[filename]:[42]:[function] message")
    XCTAssertEqual(appender.logMessages[1].message, "[filename]:[42]:[function] message")
    XCTAssertEqual(appender.logMessages[2].message, "[filename]:[42]:[function] message")
    XCTAssertEqual(appender.logMessages[3].message, "[filename]:[42]:[function] message")
    XCTAssertEqual(appender.logMessages[4].message, "[filename]:[42]:[function] message")
    XCTAssertEqual(appender.logMessages[5].message, "[filename]:[42]:[function] message")
  }
  
  internal class TestClass: CustomStringConvertible {
    var name: String = ""
    var age: Int = 0
    
    init(withName name: String, andAge: Int)
    {
      self.name = name
      self.age = andAge
    }
    
    var description: String {
      return "{ name: \"\(name)\", age: \(age) }"
    }
  }
  
  func testLoggerObjectiveCLogEnteringVariants() {
    let appender = MemoryAppender()
    appender.thresholdLevel = .Trace
    let formatter = try! PatternFormatter(identifier:"testFormatter", pattern: "%m")
    appender.formatter = formatter
    let logger = Logger(identifier: "test.logger", level: LogLevel.Trace, appenders: [appender])
    
    let testString: String = "Somestring"
    let testInt: Int = 54
    let testClass = TestClass(withName: "Somename", andAge: 62)
    
    // Execute
    logger.logEntering(dumpArgs: false, withTypeInfo: false, args: [])
    logger.logEntering(dumpArgs: false, withTypeInfo: false, args: [testString])
    logger.logEntering(dumpArgs: false, withTypeInfo: false, args: [testString, testInt, testClass])
    logger.logEntering(dumpArgs: true, withTypeInfo: false, args: [testString, testInt, testClass])
    logger.logEntering(dumpArgs: true, withTypeInfo: true, args: [testString, testInt, testClass])
    
    logger.logEnteringBloc(dumpArgs: false, withTypeInfo: false) { [] }
    logger.logEnteringBloc(dumpArgs: false, withTypeInfo: false) { [testString] }
    logger.logEnteringBloc(dumpArgs: false, withTypeInfo: false) { [testString, testInt, testClass] }
    logger.logEnteringBloc(dumpArgs: true, withTypeInfo: false) { [testString, testInt, testClass] }
    logger.logEnteringBloc(dumpArgs: true, withTypeInfo: true, { [testString, testInt, testClass] })
    
    // Validate
    XCTAssertEqual(appender.logMessages[0].message, "ENTERING - without parameters")
    XCTAssertEqual(appender.logMessages[1].message, "ENTERING - with 1 parameter")
    XCTAssertEqual(appender.logMessages[2].message, "ENTERING - with 3 parameters")
    XCTAssertEqual(appender.logMessages[3].message, "ENTERING - with 3 parameters: Somestring, 54, { name: \"Somename\", age: 62 }")
    XCTAssertEqual(appender.logMessages[4].message, "ENTERING - with 3 parameters: _NSContiguousString: Somestring, __NSCFNumber: 54, TestClass: { name: \"Somename\", age: 62 }")
    
    XCTAssertEqual(appender.logMessages[5].message, "ENTERING - without parameters")
    XCTAssertEqual(appender.logMessages[6].message, "ENTERING - with 1 parameter")
    XCTAssertEqual(appender.logMessages[7].message, "ENTERING - with 3 parameters")
    XCTAssertEqual(appender.logMessages[8].message, "ENTERING - with 3 parameters: Somestring, 54, { name: \"Somename\", age: 62 }")
    XCTAssertEqual(appender.logMessages[9].message, "ENTERING - with 3 parameters: _NSContiguousString: Somestring, __NSCFNumber: 54, TestClass: { name: \"Somename\", age: 62 }")
  }
  
  func testLoggerObjectiveCLogEnteringVariantsWithFileLineAndFunction() {
    let appender = MemoryAppender()
    appender.thresholdLevel = .Trace
    let formatter = try! PatternFormatter(identifier:"testFormatter", pattern: "[%F]:[%L]:[%M] %m")
    appender.formatter = formatter
    let logger = Logger(identifier: "test.logger", level: LogLevel.Trace, appenders: [appender])
    
    let testString: String = "Somestring"
    let testInt: Int = 54
    let testClass = TestClass(withName: "Somename", andAge: 62)
    
    // Execute
    logger.logEntering(dumpArgs: false, withTypeInfo: false, args: [], file: "filename", line: 42, function: "function")
    logger.logEntering(dumpArgs: false, withTypeInfo: false, args: [testString], file: "filename", line: 42, function: "function")
    logger.logEntering(dumpArgs: false, withTypeInfo: false, args: [testString, testInt, testClass], file: "filename", line: 42, function: "function")
    logger.logEntering(dumpArgs: true, withTypeInfo: false, args: [testString, testInt, testClass], file: "filename", line: 42, function: "function")
    logger.logEntering(dumpArgs: true, withTypeInfo: true, args: [testString, testInt, testClass], file: "filename", line: 42, function: "function")
    
    logger.logEnteringBloc(dumpArgs: false, withTypeInfo: false, file: "filename", line: 42, function: "function") { [] }
    logger.logEnteringBloc(dumpArgs: false, withTypeInfo: false, file: "filename", line: 42, function: "function") { [testString] }
    logger.logEnteringBloc(dumpArgs: false, withTypeInfo: false, file: "filename", line: 42, function: "function") { [testString, testInt, testClass] }
    logger.logEnteringBloc(dumpArgs: true, withTypeInfo: false, file: "filename", line: 42, function: "function") { [testString, testInt, testClass] }
    logger.logEnteringBloc(dumpArgs: true, withTypeInfo: true, file: "filename", line: 42, function: "function", { [testString, testInt, testClass] })
    
    // Validate
    XCTAssertEqual(appender.logMessages[0].message, "[filename]:[42]:[function] ENTERING - without parameters")
    XCTAssertEqual(appender.logMessages[1].message, "[filename]:[42]:[function] ENTERING - with 1 parameter")
    XCTAssertEqual(appender.logMessages[2].message, "[filename]:[42]:[function] ENTERING - with 3 parameters")
    XCTAssertEqual(appender.logMessages[3].message, "[filename]:[42]:[function] ENTERING - with 3 parameters: Somestring, 54, { name: \"Somename\", age: 62 }")
    XCTAssertEqual(appender.logMessages[4].message, "[filename]:[42]:[function] ENTERING - with 3 parameters: _NSContiguousString: Somestring, __NSCFNumber: 54, TestClass: { name: \"Somename\", age: 62 }")
    
    XCTAssertEqual(appender.logMessages[5].message, "[filename]:[42]:[function] ENTERING - without parameters")
    XCTAssertEqual(appender.logMessages[6].message, "[filename]:[42]:[function] ENTERING - with 1 parameter")
    XCTAssertEqual(appender.logMessages[7].message, "[filename]:[42]:[function] ENTERING - with 3 parameters")
    XCTAssertEqual(appender.logMessages[8].message, "[filename]:[42]:[function] ENTERING - with 3 parameters: Somestring, 54, { name: \"Somename\", age: 62 }")
    XCTAssertEqual(appender.logMessages[9].message, "[filename]:[42]:[function] ENTERING - with 3 parameters: _NSContiguousString: Somestring, __NSCFNumber: 54, TestClass: { name: \"Somename\", age: 62 }")
  }
  
  func testLoggerObjectiveCLogExitingVariants() {
    let appender = MemoryAppender()
    appender.thresholdLevel = .Trace
    let formatter = try! PatternFormatter(identifier:"testFormatter", pattern: "%m")
    appender.formatter = formatter
    let logger = Logger(identifier: "test.logger", level: LogLevel.Trace, appenders: [appender])
    
    let testString: String = "Somestring"
    let testInt: Int = 54
    let testClass = TestClass(withName: "Somename", andAge: 62)
    
    // Execute
    logger.logExiting(dumpArgs: false, withTypeInfo: false, args: [])
    logger.logExiting(dumpArgs: false, withTypeInfo: false, args: [testString])
    logger.logExiting(dumpArgs: false, withTypeInfo: false, args: [testString, testInt, testClass])
    logger.logExiting(dumpArgs: true, withTypeInfo: false, args: [testString, testInt, testClass])
    logger.logExiting(dumpArgs: true, withTypeInfo: true, args: [testString, testInt, testClass])
    
    logger.logExitingBloc(dumpArgs: false, withTypeInfo: false) { [] }
    logger.logExitingBloc(dumpArgs: false, withTypeInfo: false) { [testString] }
    logger.logExitingBloc(dumpArgs: false, withTypeInfo: false) { [testString, testInt, testClass] }
    logger.logExitingBloc(dumpArgs: true, withTypeInfo: false) { [testString, testInt, testClass] }
    logger.logExitingBloc(dumpArgs: true, withTypeInfo: true, { [testString, testInt, testClass] })
    
    // Validate
    XCTAssertEqual(appender.logMessages[0].message, "EXITING - without return value")
    XCTAssertEqual(appender.logMessages[1].message, "EXITING - with 1 return value")
    XCTAssertEqual(appender.logMessages[2].message, "EXITING - with 3 return values")
    XCTAssertEqual(appender.logMessages[3].message, "EXITING - with 3 return values: Somestring, 54, { name: \"Somename\", age: 62 }")
    XCTAssertEqual(appender.logMessages[4].message, "EXITING - with 3 return values: _NSContiguousString: Somestring, __NSCFNumber: 54, TestClass: { name: \"Somename\", age: 62 }")
    
    XCTAssertEqual(appender.logMessages[5].message, "EXITING - without return value")
    XCTAssertEqual(appender.logMessages[6].message, "EXITING - with 1 return value")
    XCTAssertEqual(appender.logMessages[7].message, "EXITING - with 3 return values")
    XCTAssertEqual(appender.logMessages[8].message, "EXITING - with 3 return values: Somestring, 54, { name: \"Somename\", age: 62 }")
    XCTAssertEqual(appender.logMessages[9].message, "EXITING - with 3 return values: _NSContiguousString: Somestring, __NSCFNumber: 54, TestClass: { name: \"Somename\", age: 62 }")
  }
  
  func testLoggerObjectiveCLogExitingVariantsWithFileLineAndFunction() {
    let appender = MemoryAppender()
    appender.thresholdLevel = .Trace
    let formatter = try! PatternFormatter(identifier:"testFormatter", pattern: "[%F]:[%L]:[%M] %m")
    appender.formatter = formatter
    let logger = Logger(identifier: "test.logger", level: LogLevel.Trace, appenders: [appender])
    
    let testString: String = "Somestring"
    let testInt: Int = 54
    let testClass = TestClass(withName: "Somename", andAge: 62)
    
    // Execute
    logger.logExiting(dumpArgs: false, withTypeInfo: false, args: [], file: "filename", line: 42, function: "function")
    logger.logExiting(dumpArgs: false, withTypeInfo: false, args: [testString], file: "filename", line: 42, function: "function")
    logger.logExiting(dumpArgs: false, withTypeInfo: false, args: [testString, testInt, testClass], file: "filename", line: 42, function: "function")
    logger.logExiting(dumpArgs: true, withTypeInfo: false, args: [testString, testInt, testClass], file: "filename", line: 42, function: "function")
    logger.logExiting(dumpArgs: true, withTypeInfo: true, args: [testString, testInt, testClass], file: "filename", line: 42, function: "function")
    
    logger.logExitingBloc(dumpArgs: false, withTypeInfo: false, file: "filename", line: 42, function: "function") { [] }
    logger.logExitingBloc(dumpArgs: false, withTypeInfo: false, file: "filename", line: 42, function: "function") { [testString] }
    logger.logExitingBloc(dumpArgs: false, withTypeInfo: false, file: "filename", line: 42, function: "function") { [testString, testInt, testClass] }
    logger.logExitingBloc(dumpArgs: true, withTypeInfo: false, file: "filename", line: 42, function: "function") { [testString, testInt, testClass] }
    logger.logExitingBloc(dumpArgs: true, withTypeInfo: true, file: "filename", line: 42, function: "function", { [testString, testInt, testClass] })
    
    // Validate
    XCTAssertEqual(appender.logMessages[0].message, "[filename]:[42]:[function] EXITING - without return value")
    XCTAssertEqual(appender.logMessages[1].message, "[filename]:[42]:[function] EXITING - with 1 return value")
    XCTAssertEqual(appender.logMessages[2].message, "[filename]:[42]:[function] EXITING - with 3 return values")
    XCTAssertEqual(appender.logMessages[3].message, "[filename]:[42]:[function] EXITING - with 3 return values: Somestring, 54, { name: \"Somename\", age: 62 }")
    XCTAssertEqual(appender.logMessages[4].message, "[filename]:[42]:[function] EXITING - with 3 return values: _NSContiguousString: Somestring, __NSCFNumber: 54, TestClass: { name: \"Somename\", age: 62 }")
    
    XCTAssertEqual(appender.logMessages[5].message, "[filename]:[42]:[function] EXITING - without return value")
    XCTAssertEqual(appender.logMessages[6].message, "[filename]:[42]:[function] EXITING - with 1 return value")
    XCTAssertEqual(appender.logMessages[7].message, "[filename]:[42]:[function] EXITING - with 3 return values")
    XCTAssertEqual(appender.logMessages[8].message, "[filename]:[42]:[function] EXITING - with 3 return values: Somestring, 54, { name: \"Somename\", age: 62 }")
    XCTAssertEqual(appender.logMessages[9].message, "[filename]:[42]:[function] EXITING - with 3 return values: _NSContiguousString: Somestring, __NSCFNumber: 54, TestClass: { name: \"Somename\", age: 62 }")
  }
}
