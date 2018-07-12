//
//  SystemLoggerAppenderTests.swift
//  log4swiftTests
//
//  Created by Jérôme Duquennoy on 24/10/2017.
//  Copyright © 2017 jerome. All rights reserved.
//

import XCTest
import Foundation
@testable import Log4swift

@available(iOS 10.0, macOS 10.12, *)
class AppleUnifiedLoggerAppenderTests: XCTestCase {
  let testLoggerName = "Log4swift.tests.systemLoggerAppender"

  func testLogWithOffLevelDoesNotLog() {
    let infoDictionary = [LogInfoKeys.LoggerName: testLoggerName]
    let appender = AppleUnifiedLoggerAppender("testAppender")
    let logMessage = "Test info message " + UUID().uuidString
    appender.thresholdLevel = .Trace
    
    // Execute
    appender.log(logMessage, level: LogLevel.Off, info: infoDictionary)
    
    let foundMessages = try! self.findLogMessage(logMessage)
    XCTAssertEqual(foundMessages.count, 0)
  }

  func testLoggingTwiceWithTheSameLoggerNameLogsMessagesCorrectly() {
    let infoDictionary = [LogInfoKeys.LoggerName: testLoggerName]
    let appender = AppleUnifiedLoggerAppender("testAppender")
    let logMessage = "Test info message " + UUID().uuidString
    
    // Execute
    appender.log(logMessage, level: LogLevel.Info, info: infoDictionary)
    appender.log(logMessage, level: LogLevel.Info, info: infoDictionary)

    let foundMessages = try! self.findLogMessage(logMessage)
    XCTAssertEqual(foundMessages.count, 2)
  }

  func testCategoryIsDashIfNoLoggerNameIsProvided() {
    let appender = AppleUnifiedLoggerAppender("testAppender")
    let logMessage = "Test info message " + UUID().uuidString
    
    // Execute
    appender.log(logMessage, level: LogLevel.Info, info: LogInfoDictionary())
    
    let foundMessages = try! self.findLogMessage(logMessage)
    XCTAssertEqual(foundMessages.count, 1)
    if foundMessages.count > 0 {
      XCTAssertEqual(foundMessages[0].category, "-")
    }
  }
  
  func testLogDebugMessageAsDebug() {
    let infoDictionary = [LogInfoKeys.LoggerName: testLoggerName]
    let appender = AppleUnifiedLoggerAppender("testAppender")
    let logMessage = "Test info message " + UUID().uuidString
    
    // Execute
    appender.log(logMessage, level: LogLevel.Debug, info: infoDictionary)
    
    let foundMessages = try! self.findLogMessage(logMessage)
    XCTAssertEqual(foundMessages.count, 1)
    if foundMessages.count > 0 {
      XCTAssertEqual(foundMessages[0].messageType, "Debug")
      XCTAssertEqual(foundMessages[0].category, infoDictionary[LogInfoKeys.LoggerName])
    }
  }

  func testLogInfoMessageAsInfo() {
    let infoDictionary = [LogInfoKeys.LoggerName: testLoggerName]
    let appender = AppleUnifiedLoggerAppender("testAppender")
    let logMessage = "Test info message " + UUID().uuidString
    
    // Execute
    appender.log(logMessage, level: LogLevel.Info, info: infoDictionary)
    
    let foundMessages = try! self.findLogMessage(logMessage)
    XCTAssertEqual(foundMessages.count, 1)
    if foundMessages.count > 0 {
      XCTAssertEqual(foundMessages[0].messageType, "Info")
      XCTAssertEqual(foundMessages[0].category, infoDictionary[LogInfoKeys.LoggerName])
    }
  }
  
  func testLogWarningMessageAsDefault() {
    let infoDictionary = [LogInfoKeys.LoggerName: testLoggerName]
    let appender = AppleUnifiedLoggerAppender("testAppender")
    let logMessage = "Test info message " + UUID().uuidString
    
    // Execute
    appender.log(logMessage, level: LogLevel.Warning, info: infoDictionary)
    
    let foundMessages = try! self.findLogMessage(logMessage)
    XCTAssertEqual(foundMessages.count, 1)
    if foundMessages.count > 0 {
      XCTAssertEqual(foundMessages[0].messageType, "Default")
      XCTAssertEqual(foundMessages[0].category, infoDictionary[LogInfoKeys.LoggerName])
    }
  }
  
  func testLogErrorMessageAsError() {
    let infoDictionary = [LogInfoKeys.LoggerName: testLoggerName]
    let appender = AppleUnifiedLoggerAppender("testAppender")
    let logMessage = "Test info message " + UUID().uuidString
    
    // Execute
    appender.log(logMessage, level: LogLevel.Error, info: infoDictionary)
    
    let foundMessages = try! self.findLogMessage(logMessage)
    XCTAssertEqual(foundMessages.count, 1)
    if foundMessages.count > 0 {
      XCTAssertEqual(foundMessages[0].messageType, "Error")
      XCTAssertEqual(foundMessages[0].category, infoDictionary[LogInfoKeys.LoggerName])
    }
  }
  
  func testLogFatalMessageAsFault() {
    let infoDictionary = [LogInfoKeys.LoggerName: testLoggerName]
    let appender = AppleUnifiedLoggerAppender("testAppender")
    let logMessage = "Test fatal message " + UUID().uuidString
    
    // Execute
    appender.log(logMessage, level: LogLevel.Fatal, info: infoDictionary)
    
    let foundMessages = try! self.findLogMessage(logMessage)
    XCTAssertEqual(foundMessages.count, 1)
    if foundMessages.count > 0 {
      XCTAssertEqual(foundMessages[0].messageType, "Fault")
      XCTAssertEqual(foundMessages[0].category, infoDictionary[LogInfoKeys.LoggerName])
    }
  }
  
  private func findLogMessage(_ text: String) throws -> [SystemLogMessage] {
    // The log system is async, so the log might appear after a small delay.
    // We loop with a small wait to work that around.
    // So this method can take several seconds to run, in the worst case (no log message found)
    var triesLeft = 10
    var foundMessages = [SystemLogMessage]()
    
    repeat {
      // log show --predicate "eventMessage = 'message'" --last "1m" --style json --info --debug
      // escape ' with \
      let protectedMessage = text.replacingOccurrences(of: "'", with: "\\'")
      let jsonData = self.execCommand(command: "log", args: ["show", "--predicate", "eventMessage = '\(protectedMessage)'", "--last", "1m", "--style", "json", "--info", "--debug"])
      let jsonDecoder = JSONDecoder()
      foundMessages = try jsonDecoder.decode(Array<SystemLogMessage>.self, from: jsonData)

      if foundMessages.count == 0 {
        RunLoop.current.run(until: Date(timeIntervalSinceNow: 0.1))
      }
      triesLeft -= 1
    } while(triesLeft > 0 && foundMessages.isEmpty)
    
    return foundMessages
  }

  private func execCommand(command: String, args: [String]) -> Data {
    if !command.hasPrefix("/") {
      let commandFullPathData = execCommand(command: "/usr/bin/which", args: [command])
      let commandFullPath = String(data: commandFullPathData, encoding: String.Encoding.utf8)!.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
      return execCommand(command: commandFullPath, args: args)
    }
    let proc = Process()
    proc.launchPath = command
    proc.arguments = args
    let pipe = Pipe()
    proc.standardOutput = pipe
    proc.launch()
    let data = pipe.fileHandleForReading.readDataToEndOfFile()
    return data
  }
}

struct SystemLogMessage: Decodable {
  let category: String
  let processImageUUID: String
  let processUniqueID: UInt? // depending on the OS version, the process uniqueID might not appear (it does not on 10.13)
  let threadID: UInt
  let timestamp: String
  let traceID: Int
  let messageType: String
  let activityID: UInt64?
  let processID: UInt
  let machTimestamp: UInt64
  let timezoneName: String
  let subsystem: String
  let senderProgramCounter: UInt
  let eventMessage: String
  let senderImageUUID: String
  let processImagePath: String
  let senderImagePath: String
}
