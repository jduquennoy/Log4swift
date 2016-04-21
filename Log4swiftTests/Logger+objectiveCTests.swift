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
    
    logger.logEntering([])
    logger.logExiting([])
    
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
  
  func testLoggerObjectiveCLogEnteringArgOutputLevelOff() {
    let appender = MemoryAppender()
    appender.thresholdLevel = .Trace
    let formatter = try! PatternFormatter(identifier:"testFormatter", pattern: "%m")
    appender.formatter = formatter
    let logger = Logger(identifier: "test.logger", level: LogLevel.Trace, argOutputLevel: .Off, appenders: [appender])
    
    let testString: String = "Somestring"
    let testInt: Int = 54
    let testClass = TestClass(withName: "Somename", andAge: 62)
    
    // Execute
    logger.logEntering([])
    logger.logEntering([testString])
    logger.logEntering([testString, testInt, testClass])
    
    logger.logEnteringBloc() { [] }
    logger.logEnteringBloc() { [testString] }
    logger.logEnteringBloc() { [testString, testInt, testClass] }
    logger.logEnteringBloc({ [testString, testInt, testClass] })
    
    // Validate
    XCTAssertEqual(appender.logMessages[0].message, "ENTERING - without parameters")
    XCTAssertEqual(appender.logMessages[1].message, "ENTERING - with 1 parameter")
    XCTAssertEqual(appender.logMessages[2].message, "ENTERING - with 3 parameters")
    
    XCTAssertEqual(appender.logMessages[3].message, "ENTERING - without parameters")
    XCTAssertEqual(appender.logMessages[4].message, "ENTERING - with 1 parameter")
    XCTAssertEqual(appender.logMessages[5].message, "ENTERING - with 3 parameters")
    XCTAssertEqual(appender.logMessages[6].message, "ENTERING - with 3 parameters")
  }
  
  func testLoggerObjectiveCLogEnteringArgOutputLevelArgsOnly() {
    let appender = MemoryAppender()
    appender.thresholdLevel = .Trace
    let formatter = try! PatternFormatter(identifier:"testFormatter", pattern: "%m")
    appender.formatter = formatter
    let logger = Logger(identifier: "test.logger", level: LogLevel.Trace, argOutputLevel: .ValueOnly, appenders: [appender])
    
    let testString: String = "Somestring"
    let testInt: Int = 54
    let testClass = TestClass(withName: "Somename", andAge: 62)
    
    // Execute
    logger.logEntering([])
    logger.logEntering([testString])
    logger.logEntering([testString, testInt, testClass])
    
    logger.logEnteringBloc() { [] }
    logger.logEnteringBloc() { [testString] }
    logger.logEnteringBloc() { [testString, testInt, testClass] }
    logger.logEnteringBloc({ [testString, testInt, testClass] })
    
    // Validate
    XCTAssertEqual(appender.logMessages[0].message, "ENTERING - without parameters")
    XCTAssertEqual(appender.logMessages[1].message, "ENTERING - with 1 parameter: Somestring")
    XCTAssertEqual(appender.logMessages[2].message, "ENTERING - with 3 parameters: Somestring, 54, { name: \"Somename\", age: 62 }")
    
    XCTAssertEqual(appender.logMessages[3].message, "ENTERING - without parameters")
    XCTAssertEqual(appender.logMessages[4].message, "ENTERING - with 1 parameter: Somestring")
    XCTAssertEqual(appender.logMessages[5].message, "ENTERING - with 3 parameters: Somestring, 54, { name: \"Somename\", age: 62 }")
    XCTAssertEqual(appender.logMessages[6].message, "ENTERING - with 3 parameters: Somestring, 54, { name: \"Somename\", age: 62 }")
  }
  
  func testLoggerObjectiveCLogEnteringArgOutputLevelArgsWithTypeInfo() {
    let appender = MemoryAppender()
    appender.thresholdLevel = .Trace
    let formatter = try! PatternFormatter(identifier:"testFormatter", pattern: "%m")
    appender.formatter = formatter
    let logger = Logger(identifier: "test.logger", level: LogLevel.Trace, argOutputLevel: .ValueWithType, appenders: [appender])
    
    let testString: String = "Somestring"
    let testInt: Int = 54
    let testClass = TestClass(withName: "Somename", andAge: 62)
    
    // Execute
    logger.logEntering([])
    logger.logEntering([testString])
    logger.logEntering([testString, testInt, testClass])
    
    logger.logEnteringBloc() { [] }
    logger.logEnteringBloc() { [testString] }
    logger.logEnteringBloc() { [testString, testInt, testClass] }
    logger.logEnteringBloc({ [testString, testInt, testClass] })
    
    // Validate
    XCTAssertEqual(appender.logMessages[0].message, "ENTERING - without parameters")
    XCTAssertEqual(appender.logMessages[1].message, "ENTERING - with 1 parameter: _NSContiguousString: Somestring")
    XCTAssertEqual(appender.logMessages[2].message, "ENTERING - with 3 parameters: _NSContiguousString: Somestring, __NSCFNumber: 54, TestClass: { name: \"Somename\", age: 62 }")
    
    XCTAssertEqual(appender.logMessages[3].message, "ENTERING - without parameters")
    XCTAssertEqual(appender.logMessages[4].message, "ENTERING - with 1 parameter: _NSContiguousString: Somestring")
    XCTAssertEqual(appender.logMessages[5].message, "ENTERING - with 3 parameters: _NSContiguousString: Somestring, __NSCFNumber: 54, TestClass: { name: \"Somename\", age: 62 }")
    XCTAssertEqual(appender.logMessages[6].message, "ENTERING - with 3 parameters: _NSContiguousString: Somestring, __NSCFNumber: 54, TestClass: { name: \"Somename\", age: 62 }")
  }
  
  func testLoggerObjectiveCLogEnteringArgOutputLevelArgsWithTypeInfoWithFileLineAndFunction() {
    let appender = MemoryAppender()
    appender.thresholdLevel = .Trace
    let formatter = try! PatternFormatter(identifier:"testFormatter", pattern: "[%F]:[%L]:[%M] %m")
    appender.formatter = formatter
    let logger = Logger(identifier: "test.logger", level: LogLevel.Trace, argOutputLevel: .ValueWithType, appenders: [appender])
    
    let testString: String = "Somestring"
    let testInt: Int = 54
    let testClass = TestClass(withName: "Somename", andAge: 62)
    
    // Execute
    logger.logEntering([], file: "filename", line: 42, function: "function")
    logger.logEntering([testString], file: "filename", line: 42, function: "function")
    logger.logEntering([testString, testInt, testClass], file: "filename", line: 42, function: "function")
    
    logger.logEnteringBloc({ [] }, file: "filename", line: 42, function: "function")
    logger.logEnteringBloc({ [testString] }, file: "filename", line: 42, function: "function")
    logger.logEnteringBloc({ [testString, testInt, testClass] }, file: "filename", line: 42, function: "function")
    
    // Validate
    XCTAssertEqual(appender.logMessages[0].message, "[filename]:[42]:[function] ENTERING - without parameters")
    XCTAssertEqual(appender.logMessages[1].message, "[filename]:[42]:[function] ENTERING - with 1 parameter: _NSContiguousString: Somestring")
    XCTAssertEqual(appender.logMessages[2].message, "[filename]:[42]:[function] ENTERING - with 3 parameters: _NSContiguousString: Somestring, __NSCFNumber: 54, TestClass: { name: \"Somename\", age: 62 }")
    
    XCTAssertEqual(appender.logMessages[3].message, "[filename]:[42]:[function] ENTERING - without parameters")
    XCTAssertEqual(appender.logMessages[4].message, "[filename]:[42]:[function] ENTERING - with 1 parameter: _NSContiguousString: Somestring")
    XCTAssertEqual(appender.logMessages[5].message, "[filename]:[42]:[function] ENTERING - with 3 parameters: _NSContiguousString: Somestring, __NSCFNumber: 54, TestClass: { name: \"Somename\", age: 62 }")
  }
  
  func testLoggerObjectiveCLogExitingArgOutputLevelOff() {
    let appender = MemoryAppender()
    appender.thresholdLevel = .Trace
    let formatter = try! PatternFormatter(identifier:"testFormatter", pattern: "%m")
    appender.formatter = formatter
    let logger = Logger(identifier: "test.logger", level: LogLevel.Trace, argOutputLevel: .Off, appenders: [appender])
    
    let testString: String = "Somestring"
    let testInt: Int = 54
    let testClass = TestClass(withName: "Somename", andAge: 62)
    
    // Execute
    logger.logExiting([])
    logger.logExiting([testString])
    logger.logExiting([testString, testInt, testClass])
    
    logger.logExitingBloc() { [] }
    logger.logExitingBloc() { [testString] }
    logger.logExitingBloc() { [testString, testInt, testClass] }
    logger.logExitingBloc({ [testString, testInt, testClass] })
    
    // Validate
    XCTAssertEqual(appender.logMessages[0].message, "EXITING - without return value")
    XCTAssertEqual(appender.logMessages[1].message, "EXITING - with 1 return value")
    XCTAssertEqual(appender.logMessages[2].message, "EXITING - with 3 return values")
    
    XCTAssertEqual(appender.logMessages[3].message, "EXITING - without return value")
    XCTAssertEqual(appender.logMessages[4].message, "EXITING - with 1 return value")
    XCTAssertEqual(appender.logMessages[5].message, "EXITING - with 3 return values")
    XCTAssertEqual(appender.logMessages[6].message, "EXITING - with 3 return values")
  }
  
  func testLoggerObjectiveCLogExitingArgOutputLevelArgsOnly() {
    let appender = MemoryAppender()
    appender.thresholdLevel = .Trace
    let formatter = try! PatternFormatter(identifier:"testFormatter", pattern: "%m")
    appender.formatter = formatter
    let logger = Logger(identifier: "test.logger", level: LogLevel.Trace, argOutputLevel: .ValueOnly, appenders: [appender])
    
    let testString: String = "Somestring"
    let testInt: Int = 54
    let testClass = TestClass(withName: "Somename", andAge: 62)
    
    // Execute
    logger.logExiting([])
    logger.logExiting([testString])
    logger.logExiting([testString, testInt, testClass])
    
    logger.logExitingBloc() { [] }
    logger.logExitingBloc() { [testString] }
    logger.logExitingBloc() { [testString, testInt, testClass] }
    logger.logExitingBloc({ [testString, testInt, testClass] })
    
    // Validate
    XCTAssertEqual(appender.logMessages[0].message, "EXITING - without return value")
    XCTAssertEqual(appender.logMessages[1].message, "EXITING - with 1 return value: Somestring")
    XCTAssertEqual(appender.logMessages[2].message, "EXITING - with 3 return values: Somestring, 54, { name: \"Somename\", age: 62 }")
    
    XCTAssertEqual(appender.logMessages[3].message, "EXITING - without return value")
    XCTAssertEqual(appender.logMessages[4].message, "EXITING - with 1 return value: Somestring")
    XCTAssertEqual(appender.logMessages[5].message, "EXITING - with 3 return values: Somestring, 54, { name: \"Somename\", age: 62 }")
    XCTAssertEqual(appender.logMessages[6].message, "EXITING - with 3 return values: Somestring, 54, { name: \"Somename\", age: 62 }")
  }
  
  func testLoggerObjectiveCLogExitingArgOutputLevelArgsWithTypeInfo() {
    let appender = MemoryAppender()
    appender.thresholdLevel = .Trace
    let formatter = try! PatternFormatter(identifier:"testFormatter", pattern: "%m")
    appender.formatter = formatter
    let logger = Logger(identifier: "test.logger", level: LogLevel.Trace, argOutputLevel: .ValueWithType, appenders: [appender])
    
    let testString: String = "Somestring"
    let testInt: Int = 54
    let testClass = TestClass(withName: "Somename", andAge: 62)
    
    // Execute
    logger.logExiting([])
    logger.logExiting([testString])
    logger.logExiting([testString, testInt, testClass])
    
    logger.logExitingBloc() { [] }
    logger.logExitingBloc() { [testString] }
    logger.logExitingBloc() { [testString, testInt, testClass] }
    logger.logExitingBloc({ [testString, testInt, testClass] })
    
    // Validate
    XCTAssertEqual(appender.logMessages[0].message, "EXITING - without return value")
    XCTAssertEqual(appender.logMessages[1].message, "EXITING - with 1 return value: _NSContiguousString: Somestring")
    XCTAssertEqual(appender.logMessages[2].message, "EXITING - with 3 return values: _NSContiguousString: Somestring, __NSCFNumber: 54, TestClass: { name: \"Somename\", age: 62 }")
    
    XCTAssertEqual(appender.logMessages[3].message, "EXITING - without return value")
    XCTAssertEqual(appender.logMessages[4].message, "EXITING - with 1 return value: _NSContiguousString: Somestring")
    XCTAssertEqual(appender.logMessages[5].message, "EXITING - with 3 return values: _NSContiguousString: Somestring, __NSCFNumber: 54, TestClass: { name: \"Somename\", age: 62 }")
    XCTAssertEqual(appender.logMessages[6].message, "EXITING - with 3 return values: _NSContiguousString: Somestring, __NSCFNumber: 54, TestClass: { name: \"Somename\", age: 62 }")
  }
  
  func testLoggerObjectiveCLogExitingArgOutputLevelArgsWithTypeInfoWithFileLineAndFunction() {
    let appender = MemoryAppender()
    appender.thresholdLevel = .Trace
    let formatter = try! PatternFormatter(identifier:"testFormatter", pattern: "[%F]:[%L]:[%M] %m")
    appender.formatter = formatter
    let logger = Logger(identifier: "test.logger", level: LogLevel.Trace, argOutputLevel: .ValueWithType, appenders: [appender])
    
    let testString: String = "Somestring"
    let testInt: Int = 54
    let testClass = TestClass(withName: "Somename", andAge: 62)
    
    // Execute
    logger.logExiting([], file: "filename", line: 42, function: "function")
    logger.logExiting([testString], file: "filename", line: 42, function: "function")
    logger.logExiting([testString, testInt, testClass], file: "filename", line: 42, function: "function")
    
    logger.logExitingBloc({ [] }, file: "filename", line: 42, function: "function")
    logger.logExitingBloc({ [testString] }, file: "filename", line: 42, function: "function")
    logger.logExitingBloc({ [testString, testInt, testClass] }, file: "filename", line: 42, function: "function")
    
    // Validate
    XCTAssertEqual(appender.logMessages[0].message, "[filename]:[42]:[function] EXITING - without return value")
    XCTAssertEqual(appender.logMessages[1].message, "[filename]:[42]:[function] EXITING - with 1 return value: _NSContiguousString: Somestring")
    XCTAssertEqual(appender.logMessages[2].message, "[filename]:[42]:[function] EXITING - with 3 return values: _NSContiguousString: Somestring, __NSCFNumber: 54, TestClass: { name: \"Somename\", age: 62 }")
    
    XCTAssertEqual(appender.logMessages[3].message, "[filename]:[42]:[function] EXITING - without return value")
    XCTAssertEqual(appender.logMessages[4].message, "[filename]:[42]:[function] EXITING - with 1 return value: _NSContiguousString: Somestring")
    XCTAssertEqual(appender.logMessages[5].message, "[filename]:[42]:[function] EXITING - with 3 return values: _NSContiguousString: Somestring, __NSCFNumber: 54, TestClass: { name: \"Somename\", age: 62 }")
  }
  
  func testLoggerObjectiveCLogValuesArgOutputLevelOff() {
    let appender = MemoryAppender()
    appender.thresholdLevel = .Trace
    let formatter = try! PatternFormatter(identifier:"testFormatter", pattern: "%m")
    appender.formatter = formatter
    let logger = Logger(identifier: "test.logger", level: LogLevel.Trace, argOutputLevel: .Off, appenders: [appender])
    
    let testString: String = "Somestring"
    let testInt: Int = 54
    let testClass = TestClass(withName: "Somename", andAge: 62)
    
    // Execute
    logger.logValues("Testmessage 1", args: [])
    logger.logValues("Testmessage 2", args: [testString])
    logger.logValues("Testmessage 3", args: [testString, testInt, testClass])
    
    logger.logValuesBloc("Testmessage 4") { [] }
    logger.logValuesBloc("Testmessage 5") { [testString] }
    logger.logValuesBloc("Testmessage 6") { [testString, testInt, testClass] }
    logger.logValuesBloc("Testmessage 7", closure: { [testString, testInt, testClass] })
    
    // Validate
    XCTAssertEqual(appender.logMessages[0].message, "Testmessage 1")
    XCTAssertEqual(appender.logMessages[1].message, "Testmessage 2")
    XCTAssertEqual(appender.logMessages[2].message, "Testmessage 3")
    
    XCTAssertEqual(appender.logMessages[3].message, "Testmessage 4")
    XCTAssertEqual(appender.logMessages[4].message, "Testmessage 5")
    XCTAssertEqual(appender.logMessages[5].message, "Testmessage 6")
    XCTAssertEqual(appender.logMessages[6].message, "Testmessage 7")
  }
  
  func testLoggerObjectiveCLogValuesArgOutputLevelArgsOnly() {
    let appender = MemoryAppender()
    appender.thresholdLevel = .Trace
    let formatter = try! PatternFormatter(identifier:"testFormatter", pattern: "%m")
    appender.formatter = formatter
    let logger = Logger(identifier: "test.logger", level: LogLevel.Trace, argOutputLevel: .ValueOnly, appenders: [appender])
    
    let testString: String = "Somestring"
    let testInt: Int = 54
    let testClass = TestClass(withName: "Somename", andAge: 62)
    
    // Execute
    logger.logValues("Testmessage 1", args: [])
    logger.logValues("Testmessage 2", args: [testString])
    logger.logValues("Testmessage 3", args: [testString, testInt, testClass])
    
    logger.logValuesBloc("Testmessage 4") { [] }
    logger.logValuesBloc("Testmessage 5") { [testString] }
    logger.logValuesBloc("Testmessage 6") { [testString, testInt, testClass] }
    logger.logValuesBloc("Testmessage 7", closure: { [testString, testInt, testClass] })
    
    // Validate
    XCTAssertEqual(appender.logMessages[0].message, "Testmessage 1")
    XCTAssertEqual(appender.logMessages[1].message, "Testmessage 2: Somestring")
    XCTAssertEqual(appender.logMessages[2].message, "Testmessage 3: Somestring, 54, { name: \"Somename\", age: 62 }")
    
    XCTAssertEqual(appender.logMessages[3].message, "Testmessage 4")
    XCTAssertEqual(appender.logMessages[4].message, "Testmessage 5: Somestring")
    XCTAssertEqual(appender.logMessages[5].message, "Testmessage 6: Somestring, 54, { name: \"Somename\", age: 62 }")
    XCTAssertEqual(appender.logMessages[6].message, "Testmessage 7: Somestring, 54, { name: \"Somename\", age: 62 }")
  }
  
  func testLoggerObjectiveCLogValuesArgOutputLevelArgsWithTypeInfo() {
    let appender = MemoryAppender()
    appender.thresholdLevel = .Trace
    let formatter = try! PatternFormatter(identifier:"testFormatter", pattern: "%m")
    appender.formatter = formatter
    let logger = Logger(identifier: "test.logger", level: LogLevel.Trace, argOutputLevel: .ValueWithType, appenders: [appender])
    
    let testString: String = "Somestring"
    let testInt: Int = 54
    let testClass = TestClass(withName: "Somename", andAge: 62)
    
    // Execute
    logger.logValues("Testmessage 1", args: [])
    logger.logValues("Testmessage 2", args: [testString])
    logger.logValues("Testmessage 3", args: [testString, testInt, testClass])
    
    logger.logValuesBloc("Testmessage 4") { [] }
    logger.logValuesBloc("Testmessage 5") { [testString] }
    logger.logValuesBloc("Testmessage 6") { [testString, testInt, testClass] }
    logger.logValuesBloc("Testmessage 7", closure: { [testString, testInt, testClass] })
    
    // Validate
    XCTAssertEqual(appender.logMessages[0].message, "Testmessage 1")
    XCTAssertEqual(appender.logMessages[1].message, "Testmessage 2: _NSContiguousString: Somestring")
    XCTAssertEqual(appender.logMessages[2].message, "Testmessage 3: _NSContiguousString: Somestring, __NSCFNumber: 54, TestClass: { name: \"Somename\", age: 62 }")
    
    XCTAssertEqual(appender.logMessages[3].message, "Testmessage 4")
    XCTAssertEqual(appender.logMessages[4].message, "Testmessage 5: _NSContiguousString: Somestring")
    XCTAssertEqual(appender.logMessages[5].message, "Testmessage 6: _NSContiguousString: Somestring, __NSCFNumber: 54, TestClass: { name: \"Somename\", age: 62 }")
    XCTAssertEqual(appender.logMessages[6].message, "Testmessage 7: _NSContiguousString: Somestring, __NSCFNumber: 54, TestClass: { name: \"Somename\", age: 62 }")
  }
  
  func testLoggerObjectiveCLogValuesArgOutputLevelArgsWithTypeInfoWithFileLineAndFunction() {
    let appender = MemoryAppender()
    appender.thresholdLevel = .Trace
    let formatter = try! PatternFormatter(identifier:"testFormatter", pattern: "[%F]:[%L]:[%M] %m")
    appender.formatter = formatter
    let logger = Logger(identifier: "test.logger", level: LogLevel.Trace, argOutputLevel: .ValueWithType, appenders: [appender])
    
    let testString: String = "Somestring"
    let testInt: Int = 54
    let testClass = TestClass(withName: "Somename", andAge: 62)
    
    // Execute
    logger.logValues("Testmessage 1", args: [], file: "filename", line: 42, function: "function")
    logger.logValues("Testmessage 2", args: [testString], file: "filename", line: 42, function: "function")
    logger.logValues("Testmessage 3", args: [testString, testInt, testClass], file: "filename", line: 42, function: "function")
    
    logger.logValuesBloc("Testmessage 4", closure: { [] }, file: "filename", line: 42, function: "function")
    logger.logValuesBloc("Testmessage 5", closure: { [testString] }, file: "filename", line: 42, function: "function")
    logger.logValuesBloc("Testmessage 6", closure: { [testString, testInt, testClass] }, file: "filename", line: 42, function: "function")
    
    // Validate
    XCTAssertEqual(appender.logMessages[0].message, "[filename]:[42]:[function] Testmessage 1")
    XCTAssertEqual(appender.logMessages[1].message, "[filename]:[42]:[function] Testmessage 2: _NSContiguousString: Somestring")
    XCTAssertEqual(appender.logMessages[2].message, "[filename]:[42]:[function] Testmessage 3: _NSContiguousString: Somestring, __NSCFNumber: 54, TestClass: { name: \"Somename\", age: 62 }")
    
    XCTAssertEqual(appender.logMessages[3].message, "[filename]:[42]:[function] Testmessage 4")
    XCTAssertEqual(appender.logMessages[4].message, "[filename]:[42]:[function] Testmessage 5: _NSContiguousString: Somestring")
    XCTAssertEqual(appender.logMessages[5].message, "[filename]:[42]:[function] Testmessage 6: _NSContiguousString: Somestring, __NSCFNumber: 54, TestClass: { name: \"Somename\", age: 62 }")
  }
}
