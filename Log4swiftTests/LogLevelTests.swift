//
//  LogLevelTests.swift
//  Log4swift
//
//  Created by jduquennoy on 26/06/2015.
//  Copyright © 2015 jerome. All rights reserved.
//

import XCTest
import Log4swift

class LogLevelTests: XCTestCase {

  func testLogLevelFromStringConvertsInvalidValuesToNil() {
    let parsedLevel = LogLevel("value that does not exist");
    
    XCTAssertTrue(parsedLevel == nil);
  }
  
  func testLogLevelFromStringIsCaseInsensitive() {
    let parsedLevel1 = LogLevel("debug");
    let parsedLevel2 = LogLevel("DEBUg");
    
    XCTAssertEqual(parsedLevel1!, LogLevel.Debug);
    XCTAssertEqual(parsedLevel2!, LogLevel.Debug);
  }
  
  func testLogLevelFromStringCanConvertAllLogLevels() {
    let parsedDebug = LogLevel("debug");
    let parsedInfo = LogLevel("info");
    let parsedWarning = LogLevel("warning");
    let parsedError = LogLevel("error");
    let parsedFatal = LogLevel("fatal");
    
    XCTAssertEqual(parsedDebug!, LogLevel.Debug);
    XCTAssertEqual(parsedInfo!, LogLevel.Info);
    XCTAssertEqual(parsedWarning!, LogLevel.Warning);
    XCTAssertEqual(parsedError!, LogLevel.Error);
    XCTAssertEqual(parsedFatal!, LogLevel.Fatal);
  }
  
}
