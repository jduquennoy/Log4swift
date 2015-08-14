//
//  PatternFormatterTests.swift
//  Log4swift
//
//  Created by Jérôme Duquennoy on 19/06/2015.
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

class PatternFormatterTests: XCTestCase {
  
  override func setUp() {
    super.setUp()
    // Put setup code here. This method is called before the invocation of each test method in the class.
  }
  
  override func tearDown() {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    super.tearDown()
  }
  
  func testCreateFormatterWithNonClosedParametersThrowsError() {
    XCTAssertThrows { try PatternFormatter(identifier:"testFormatter", pattern: "%d{ blablabla") };
  }
  
  func testFormatterAppliesLogLevelMarker() {
    let formatter = try! PatternFormatter(identifier:"testFormatter", pattern: "%l");

    // Execute
    let formattedMessage = formatter.format("", info: [LogInfoKeys.LogLevel: LogLevel.Error]);
    
    // validate
    XCTAssertEqual(formattedMessage, LogLevel.Error.description);
  }
  
  func testFormatterAppliesLoggerNameMarker() {
    let formatter = try! PatternFormatter(identifier:"testFormatter", pattern: "%n");
    let info: LogInfoDictionary = [LogInfoKeys.LoggerName: "loggername"];
    
    // Execute
    let formattedMessage = formatter.format("", info: info);

    // Validate
    XCTAssertEqual(formattedMessage, "loggername");
  }
  
  func testFormatterAppliesDateMarker() {
    let formatter = try! PatternFormatter(identifier:"testFormatter", pattern: "%d");
    let info = LogInfoDictionary();
    
    // Execute
    let formattedMessage = formatter.format("", info: info);
    
    // Validate
    // TODO: the validation of this test is pretty weak.
    let validationRegexp = try! NSRegularExpression(pattern: "^[\\d+-: ]{5,}$", options: NSRegularExpressionOptions());
    let matches = validationRegexp.matchesInString(formattedMessage, options: NSMatchingOptions(), range: NSMakeRange(0, formattedMessage.lengthOfBytesUsingEncoding(NSUTF8StringEncoding)));
    XCTAssert(matches.count > 0, "Formatted date '\(formattedMessage)' is not valid");
  }
  
  func testFormatterAppliesDateMarkerWithFormat() {
    let formatter = try! PatternFormatter(identifier:"testFormatter", pattern: "%d{%D %R}");
    let info = LogInfoDictionary();
    
    // Execute
    let formattedMessage = formatter.format("", info: info);
    
    // Validate
    // TODO: the validation of this test is pretty weak.
    let validationRegexp = try! NSRegularExpression(pattern: "^\\d{2}/\\d{2}/\\d{2} \\d{2}:\\d{2}$", options: NSRegularExpressionOptions());
    let matches = validationRegexp.matchesInString(formattedMessage, options: NSMatchingOptions(), range: NSMakeRange(0, formattedMessage.lengthOfBytesUsingEncoding(NSUTF8StringEncoding)));
    XCTAssert(matches.count > 0, "Formatted date '\(formattedMessage)' is not valid");
  }  

  func testMarkerParametersAreInterpreted() {
    let formatter = try! PatternFormatter(identifier:"testFormatter", pattern: "test %l{param}");
    let info: LogInfoDictionary = [LogInfoKeys.LogLevel: LogLevel.Debug];
    
    // Execute
    let formattedMessage = formatter.format("", info: info);
    
    // Validate
    XCTAssertEqual(formattedMessage, "test \(LogLevel.Debug)");
  }
  
  func testFormatterAppliesPercentageMarker() {
    let formatter = try! PatternFormatter(identifier:"testFormatter", pattern: "test %%");
    let info = LogInfoDictionary();
    
    // Execute
    let formattedMessage = formatter.format("", info: info);
    
    // Validate
    XCTAssertEqual(formattedMessage, "test %");
  }
  
  func testFormatterDoesNotReplaceUnknownMarkers() {
    let formatter = try! PatternFormatter(identifier:"testFormatter", pattern: "%x %y %z are unknown markers");
    let info = LogInfoDictionary();
    
    // Execute
    let formattedMessage = formatter.format("", info: info);
    
    // Validate
    XCTAssertEqual(formattedMessage, "%x %y %z are unknown markers");
  }
  
  func testFormatterWithComplexFormatting() {
    let formatter = try! PatternFormatter(identifier:"testFormatter", pattern: "[%l][%n] %m");
    let info: LogInfoDictionary = [
      LogInfoKeys.LoggerName: "nameOfTheLogger",
      LogInfoKeys.LogLevel: LogLevel.Warning
    ];
    
    // Execute
    let formattedMessage = formatter.format("Log message", info: info);
    
    // Validate
    XCTAssertEqual(formattedMessage, "[\(LogLevel.Warning)][nameOfTheLogger] Log message");
  }
  
  func testFormatterReturnsDashIfDataUnavailableForMarkers() {
    let formatter = try! PatternFormatter(identifier: "testFormatter", pattern: "[%l][%n] %m");
    let info = LogInfoDictionary();
    
    // Execute
    let formattedMessage = formatter.format("Log message", info: info);
    
    // Validate
    XCTAssertEqual(formattedMessage, "[-][-] Log message");
  }
  
  func testUpdatingFormatterFromDictionaryWithNoPatternThrowsError() {
    let dictionary = Dictionary<String, AnyObject>();
    let formatter = PatternFormatter("testFormatter");
    
    XCTAssertThrows { try formatter.updateWithDictionary(dictionary) };
  }

  func testUpdatingFormatterFromDictionaryWithInvalidPatternThrowsError() {
    let dictionary = [PatternFormatter.DictionaryKey.Pattern.rawValue: "%x{"];
    let formatter = PatternFormatter("testFormatter");
    
    XCTAssertThrows { try formatter.updateWithDictionary(dictionary) };
  }
  
  func testUpdatingFormatterFromDictionaryWithValidParametersCreatesFormatter() {
    let dictionary = [PatternFormatter.DictionaryKey.Pattern.rawValue: "static test pattern"];
    let formatter = PatternFormatter("testFormatter");

    XCTAssertNoThrow { try formatter.updateWithDictionary(dictionary); };

    let formattedMessage = formatter.format("", info: LogInfoDictionary());
    XCTAssertEqual(formattedMessage, dictionary[PatternFormatter.DictionaryKey.Pattern.rawValue]!);
  }
  
  func testFormatterPerformance() {
    let formatter = try! PatternFormatter(identifier:"testFormatter", pattern: "[%l][%n][%d] %m");
    let info: LogInfoDictionary = [
      LogInfoKeys.LoggerName: "nameOfTheLogger",
      LogInfoKeys.LogLevel: LogLevel.Info
    ];
    
    self.measureBlock() {
      for _ in 1...1000 {
        formatter.format("Log message", info: info);
      }
    }
  }
}
