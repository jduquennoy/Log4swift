//
//  LogLevelTests.swift
//  Log4swift
//
//  Created by jduquennoy on 26/06/2015.
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
    let parsedTrace = LogLevel("trace");
    let parsedDebug = LogLevel("debug");
    let parsedInfo = LogLevel("info");
    let parsedWarning = LogLevel("warning");
    let parsedError = LogLevel("error");
    let parsedFatal = LogLevel("fatal");

    XCTAssertEqual(parsedTrace!, LogLevel.Trace);
    XCTAssertEqual(parsedDebug!, LogLevel.Debug);
    XCTAssertEqual(parsedInfo!, LogLevel.Info);
    XCTAssertEqual(parsedWarning!, LogLevel.Warning);
    XCTAssertEqual(parsedError!, LogLevel.Error);
    XCTAssertEqual(parsedFatal!, LogLevel.Fatal);
  }
  
}
