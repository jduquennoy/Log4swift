//
//  ASLAppenderTests.swift
//  Log4swift
//
//  Created by Jérôme Duquennoy on 31/07/15.
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

class ASLAppenderTests: XCTestCase {
  
  func testASLAppenderLogsFatalMessagesWithErrorLevel() {
    let appender = ASLAppender("testAppender")
    let logMessage = "Test fatal message " + NSUUID().UUIDString
    
    // Execute
    appender.log(logMessage, level: LogLevel.Fatal, info: LogInfoDictionary())
    
    sleep(1)
    
    // Validate
    let levelOfMessageInAsl = appender.aslClient.getLevelOfMessageMatchingText(logMessage)
    XCTAssertEqual(levelOfMessageInAsl, Int32(LogLevel.Fatal.rawValue))
  }
  
  func testASLAppenderLogsErrorMessagesWithErrorLevel() {
    let appender = ASLAppender("testAppender")
    let logMessage = "Test error message " + NSUUID().UUIDString
    
    // Execute
    appender.log(logMessage, level: LogLevel.Error, info: LogInfoDictionary())
    
    // Validate
    let levelOfMessageInAsl = appender.aslClient.getLevelOfMessageMatchingText(logMessage)
    XCTAssertEqual(levelOfMessageInAsl, Int32(LogLevel.Error.rawValue))
  }
  
  func testASLAppenderLogsWarningMessagesWithWarningLevel() {
    let appender = ASLAppender("testAppender")
    let logMessage = "Test warning message " + NSUUID().UUIDString
    
    // Execute
    appender.log(logMessage, level: LogLevel.Warning, info: LogInfoDictionary())
    
    // Validate
    let levelOfMessageInAsl = appender.aslClient.getLevelOfMessageMatchingText(logMessage)
    XCTAssertEqual(levelOfMessageInAsl, Int32(LogLevel.Warning.rawValue))
  }
  
  func testASLAppenderLogsWarningMessagesWithInfoLevel() {
    let appender = ASLAppender("testAppender")
    let logMessage = "Test info message " + NSUUID().UUIDString
    
    // Execute
    appender.log(logMessage, level: LogLevel.Info, info: LogInfoDictionary())
    
    // Validate
    let levelOfMessageInAsl = appender.aslClient.getLevelOfMessageMatchingText(logMessage)
    XCTAssertEqual(levelOfMessageInAsl, Int32(LogLevel.Info.rawValue))
  }
  
  func testASLAppenderLogsWarningMessagesWithDebugLevel() {
    let appender = ASLAppender("testAppender")
    let logMessage = "Test debug message " + NSUUID().UUIDString
    
    // Execute
    appender.log(logMessage, level: LogLevel.Debug, info: LogInfoDictionary())
    
    // Validate
    let levelOfMessageInAsl = appender.aslClient.getLevelOfMessageMatchingText(logMessage)
    XCTAssertEqual(levelOfMessageInAsl, Int32(LogLevel.Debug.rawValue))
  }

  func testASLAppenderUsesLoggerNameAsCategoryIfProvided() {
    let appender = ASLAppender("testAppender")
    let logMessage = "Test message with facility " + NSUUID().UUIDString
    let info: LogInfoDictionary = [LogInfoKeys.LoggerName: "That is a nice logger name"]
    
    // Execute
    appender.log(logMessage, level: LogLevel.Debug, info: info)
    
    // Validate
    let messageFacility = appender.aslClient.getFacilityOfMessageMatchingText(logMessage)
    if let messageFacility = messageFacility {
      XCTAssertEqual(messageFacility, info[LogInfoKeys.LoggerName]!.description)
    } else {
      XCTFail("Message not logged")
    }
  }

  func testASLAppenderLogMessagesWithoutTryingToInterpretFormatMarkers() {
    let appender = ASLAppender("testAppender")
    let logMessage = "Test message with uninterpretted formatting markers : %f (id=" + NSUUID().UUIDString + ")"
    let info: LogInfoDictionary = [LogInfoKeys.LoggerName: "That is a nice logger name"]
    
    // Execute
    appender.log(logMessage, level: LogLevel.Error, info: info)
    
    // Validate
    let messageFacility = appender.aslClient.getFacilityOfMessageMatchingText(logMessage)
    XCTAssertTrue(messageFacility != nil, "Logged message not found in ASL")
  }
}
