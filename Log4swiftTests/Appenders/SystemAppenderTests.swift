//
//  SystemAppenderTests.swift
//  log4swiftTests
//
//  Created by Jérôme Duquennoy on 24/10/2017.
//  Copyright © 2017 jerome. All rights reserved.
//

import XCTest
@testable import Log4swift

class TestAppender: Appender {
  var didPerformLog = false
  override func performLog(_ log: String, level: LogLevel, info: LogInfoDictionary) {
    self.didPerformLog = true
  }
}

class SystemAppenderTests: XCTestCase {

  func testBackendFormatterIsNotNil() {
    // Execute
    let appender = SystemAppender("testAppender")

    XCTAssertNotNil(appender.backendAppender)
  }
  
  func testSetFormatterIsForwardedToBackendAppender() {
    let appender = SystemAppender("testAppender")
    let formatter = PatternFormatter("appender")
    
    // Execute
    appender.formatter = formatter
    
    if let backendFormatter = appender.backendAppender?.formatter as? PatternFormatter {
      XCTAssert(backendFormatter === formatter)
    } else {
      XCTFail("Formatter was not forwarded to backend appender")
    }
  }
  
  func testGetFormatterIsForwardedToBackendAppender() {
    let appender = SystemAppender("testAppender")
    let formatter = PatternFormatter("appender")
    
    appender.backendAppender?.formatter = formatter
    
    // Execute
    let readFormatter = appender.formatter
    
    if let readFormatter = readFormatter as? PatternFormatter {
      XCTAssert(readFormatter === formatter)
    } else {
      XCTFail("Formatter was not forwarded to backend appender")
    }
  }
  
  func testSetThresholdIsForwardedToBackendAppender() {
    let appender = SystemAppender("testAppender")
    
    // Execute
    appender.thresholdLevel = .Error
    
    if let backendThreshold = appender.backendAppender?.thresholdLevel {
      XCTAssertEqual(backendThreshold, .Error)
    } else {
      XCTFail("No threshold level found for backend appender")
    }
  }
  
  func testGetThresholdIsForwardedToBackendAppender() {
    let appender = SystemAppender("testAppender")
    
    appender.backendAppender?.thresholdLevel = .Error
    
    // execute
    let readThresholdLevel = appender.thresholdLevel
    
    XCTAssertEqual(readThresholdLevel, .Error)
  }

  func testGetThresholdReturnsNilIfBackendAppenderIsNil() {
    let appender = SystemAppender("testAppender", withBackendAppender: nil)
    
    // execute
    let readThresholdLevel = appender.thresholdLevel
    
    XCTAssertEqual(readThresholdLevel, .Off)
  }

  func testUpdateWithDictionaryIsForwardedToBackendAppender() throws {
    let appender = SystemAppender("testAppender")
    let updateDictionary = [Appender.DictionaryKey.ThresholdLevel.rawValue: String(describing: LogLevel.Error)]
    
    // Execute
    try appender.update(withDictionary: updateDictionary, availableFormatters: [])
    
    let readThresholdLevel = appender.thresholdLevel
    XCTAssertEqual(readThresholdLevel, .Error)
  }

  func testPerformLogIsForwardedToBackendAppender() {
    let backendAppender = TestAppender("backend")
    let appender = SystemAppender("testAppender", withBackendAppender: backendAppender)
    
    // Execute
    appender.performLog("test log", level: .Error, info: LogInfoDictionary())
    
    XCTAssertTrue(backendAppender.didPerformLog)
  }
}
