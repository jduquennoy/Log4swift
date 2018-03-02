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
  
  func testDefaultPatternForFormatterReturnsTheUnmodifiedMessage() {
    // Execute
    let formatter = PatternFormatter("identifier")
    
    let message = "test message"
    XCTAssertEqual(formatter.format(message: message, info: LogInfoDictionary()), message)
  }
  
  func testCreateFormatterWithNonClosedParametersThrowsError() {
    XCTAssertThrows { let _ = try PatternFormatter(identifier:"testFormatter", pattern: "%d{ blablabla") }
  }
  
  func testFormatterAppliesLogLevelMarker() {
    let formatter = try! PatternFormatter(identifier:"testFormatter", pattern: "%l")

    // Execute
    let formattedMessage = formatter.format(message: "", info: [LogInfoKeys.LogLevel: LogLevel.Error])
    
    // validate
    XCTAssertEqual(formattedMessage, LogLevel.Error.description)
  }

  func testFormatterAppliesLogLevelMarkerWithPadding() {
	let formatter = try! PatternFormatter(identifier:"testFormatter", pattern: "[%l{\"padding\":\"10\"}][%n] %m")
	let info: LogInfoDictionary = [
		LogInfoKeys.LoggerName: "nameOfTheLogger",
		LogInfoKeys.LogLevel: LogLevel.Warning
	]
	
	// Execute
	let formattedMessage = formatter.format(message: "Log message", info: info)
	
	// Validate
	XCTAssertEqual(formattedMessage, "[\(LogLevel.Warning)   ][nameOfTheLogger] Log message")
  }
  
  func testFormatterAppliesLogLevelMarkerWithNegativePadding() {
	  let formatter = try! PatternFormatter(identifier:"testFormatter", pattern: "[%l{\"padding\":\"-10\"}][%n] %m")
	  let info: LogInfoDictionary = [
		  LogInfoKeys.LoggerName: "nameOfTheLogger",
		  LogInfoKeys.LogLevel: LogLevel.Warning
	  ]
	  
	  // Execute
	  let formattedMessage = formatter.format(message: "Log message", info: info)
	  
	  // Validate
	  XCTAssertEqual(formattedMessage, "[   \(LogLevel.Warning)][nameOfTheLogger] Log message")
  }

  func testFormatterAppliesLogLevelMarkerWithZeroPadding() {
	let formatter = try! PatternFormatter(identifier:"testFormatter", pattern: "[%l{\"padding\":\"0\"}][%n] %m")
	let info: LogInfoDictionary = [
		LogInfoKeys.LoggerName: "nameOfTheLogger",
		LogInfoKeys.LogLevel: LogLevel.Warning
	]
	
	// Execute
	let formattedMessage = formatter.format(message: "Log message", info: info)
	
	// Validate
	XCTAssertEqual(formattedMessage, "[\(LogLevel.Warning)][nameOfTheLogger] Log message")
  }
	
  func testFormatterAppliesLoggerNameMarker() {
    let formatter = try! PatternFormatter(identifier:"testFormatter", pattern: "%n")
    let info: LogInfoDictionary = [LogInfoKeys.LoggerName: "loggername"]
    
    // Execute
    let formattedMessage = formatter.format(message: "", info: info)

    // Validate
    XCTAssertEqual(formattedMessage, "loggername")
  }
  
  func testFormatterAppliesLoggerNameWithPadding() {
	let formatter = try! PatternFormatter(identifier:"testFormatter", pattern: "[%l][%n{\"padding\":\"10\"}] %m")
	let info: LogInfoDictionary = [
		LogInfoKeys.LoggerName: "name",
		LogInfoKeys.LogLevel: LogLevel.Warning
	]
	
	// Execute
	let formattedMessage = formatter.format(message: "Log message", info: info)
	
	// Validate
	XCTAssertEqual(formattedMessage, "[\(LogLevel.Warning)][name      ] Log message")
  }
  
  func testFormatterAppliesLoggerNameWithNegativePadding() {
	let formatter = try! PatternFormatter(identifier:"testFormatter", pattern: "[%l][%n{\"padding\":\"-10\"}] %m")
	let info: LogInfoDictionary = [
		LogInfoKeys.LoggerName: "name",
		LogInfoKeys.LogLevel: LogLevel.Warning
	]
	
	// Execute
	let formattedMessage = formatter.format(message: "Log message", info: info)
	
	// Validate
	XCTAssertEqual(formattedMessage, "[\(LogLevel.Warning)][      name] Log message")
  }
  
  func testFormatterAppliesLoggerNameWithZeroPadding() {
	let formatter = try! PatternFormatter(identifier:"testFormatter", pattern: "[%l][%n{\"padding\":\"0\"}] %m")
	let info: LogInfoDictionary = [
		LogInfoKeys.LoggerName: "name",
		LogInfoKeys.LogLevel: LogLevel.Warning
	]
	
	// Execute
	let formattedMessage = formatter.format(message: "Log message", info: info)
	
	// Validate
	XCTAssertEqual(formattedMessage, "[\(LogLevel.Warning)][name] Log message")
  }

  func testFormatterAppliesDateMarkerWithDefaultFormatIfNoneIsSpecified() {
    let formatter = try! PatternFormatter(identifier:"testFormatter", pattern: "%d")
    let info: LogInfoDictionary = [.Timestamp: 123456789.0]
    
    // Execute
    let formattedMessage = formatter.format(message: "", info: info)
    
    // Validate (regex used to avoid problems with time shift)
    let validationRegexp = try! NSRegularExpression(pattern: "^1973-11-(29|30) [0-2][0-9]:(03|33|18):09$", options: NSRegularExpression.Options())
		let matches = validationRegexp.matches(in: formattedMessage, options: NSRegularExpression.MatchingOptions(), range: NSMakeRange(0, formattedMessage.lengthOfBytes(using: String.Encoding.utf8)))
    XCTAssert(matches.count > 0, "Formatted date '\(formattedMessage)' is not valid")
  }
  
  func testFormatterAppliesDateMarkerWithFormat() {
    let formatter = try! PatternFormatter(identifier:"testFormatter", pattern: "%d{\"format\":\"%D %T\"}")
    let info: LogInfoDictionary = [.Timestamp: 123456789.0]
    
    // Execute
    let formattedMessage = formatter.format(message: "", info: info)
    
    // Validate (regex used to avoid problems with time shift)
    let validationRegexp = try! NSRegularExpression(pattern: "^11/(29|30)/73 [0-2][0-9]:(03|33|18):09$", options: NSRegularExpression.Options())
    let matches = validationRegexp.matches(in: formattedMessage, options: NSRegularExpression.MatchingOptions(), range: NSMakeRange(0, formattedMessage.lengthOfBytes(using: String.Encoding.utf8)))
    XCTAssert(matches.count > 0, "Formatted date '\(formattedMessage)' is not valid")
  }

  func testFormatterAppliesDateMarkerWithFormatAndCommonParametersPadding() {
    let formatter = try! PatternFormatter(identifier:"testFormatter", pattern: "%d{'padding':'19', 'format':'%D %T'}")
    let info: LogInfoDictionary = [.Timestamp: 123456789.0]
    
    // Execute
    let formattedMessage = formatter.format(message: "", info: info)
    
    // Validate (regex used to avoid problems with time shift)
    let validationRegexp = try! NSRegularExpression(pattern: "^11/(29|30)/73 [0-2][0-9]:(03|33|18):09  $", options: NSRegularExpression.Options())
    let matches = validationRegexp.matches(in: formattedMessage, options: NSRegularExpression.MatchingOptions(), range: NSMakeRange(0, formattedMessage.lengthOfBytes(using: String.Encoding.utf8)))
    XCTAssert(matches.count > 0, "Formatted date '\(formattedMessage)' is not valid")
  }

  func testFormatterAppliesDateMarkerWithFormatAndCommonParametersNegativePadding() {
    let formatter = try! PatternFormatter(identifier:"testFormatter", pattern: "%d{'padding':'-19', 'format':'%D %R'}")
    let info: LogInfoDictionary = [.Timestamp: 123456789.0]
    
    // Execute
    let formattedMessage = formatter.format(message: "", info: info)
    
    // Validate (regex used to avoid problems with time shift)
    let validationRegexp = try! NSRegularExpression(pattern: "^     11/(29|30)/73 [0-2][0-9]:(03|33|18)$", options: NSRegularExpression.Options())
    let matches = validationRegexp.matches(in: formattedMessage, options: NSRegularExpression.MatchingOptions(), range: NSMakeRange(0, formattedMessage.lengthOfBytes(using: String.Encoding.utf8)))
    XCTAssert(matches.count > 0, "Formatted date '\(formattedMessage)' is not valid")
  }
  
  func testFormatterAppliesDateMarkerWithFormatAndCommonParametersZeroPadding() {
    let formatter = try! PatternFormatter(identifier:"testFormatter", pattern: "%d{'padding':'0', 'format':'%D %R'}")
    let info: LogInfoDictionary = [.Timestamp: 123456789.0]
    
    // Execute
    let formattedMessage = formatter.format(message: "", info: info)
    
    // Validate (regex used to avoid problems with time shift)
    let validationRegexp = try! NSRegularExpression(pattern: "^11/(29|30)/73 [0-2][0-9]:(03|33|18)$", options: NSRegularExpression.Options())
		let matches = validationRegexp.matches(in: formattedMessage, options: NSRegularExpression.MatchingOptions(), range: NSMakeRange(0, formattedMessage.lengthOfBytes(using: String.Encoding.utf8)))
    XCTAssert(matches.count > 0, "Formatted date '\(formattedMessage)' is not valid")
  }

  
  func testCurrentTimeIsUsedByFormatterIfTimeIsNotAvailableInInfo() {
    let formatter = try! PatternFormatter(identifier:"testFormatter", pattern: "%d{'padding':'0', 'format':'%s'}")
    let info = LogInfoDictionary()
    
    // Execute
    let formattedMessage = formatter.format(message: "", info: info)
    
    // Validate
    let expectedTimestamp = Date().timeIntervalSince1970
    if let loggedMessageTime = TimeInterval(formattedMessage) {
      XCTAssertEqual(loggedMessageTime, expectedTimestamp, accuracy: 1.0)
    } else {
      XCTAssertTrue(false, "Could not read logged time")
    }
  }

  func testMarkerParametersAreInterpreted() {
    let formatter = try! PatternFormatter(identifier:"testFormatter", pattern: "test %l{'padding':'0'}")
    let info: LogInfoDictionary = [LogInfoKeys.LogLevel: LogLevel.Debug]
    
    // Execute
    let formattedMessage = formatter.format(message: "", info: info)
    
    // Validate
    XCTAssertEqual(formattedMessage, "test \(LogLevel.Debug)")
  }
  
  func testFormatterAppliesFileNameMarker() {
    let formatter = try! PatternFormatter(identifier:"testFormatter", pattern: "test %F")
    let info: LogInfoDictionary = [LogInfoKeys.FileName: "testFileName"]
    
    // Execute
    let formattedMessage = formatter.format(message: "", info: info)
    
    // Validate
    XCTAssertEqual(formattedMessage, "test testFileName")
  }
  
  func testFormatterAppliesFileNameMarkerWithCommonParametersPadding() {
    let formatter = try! PatternFormatter(identifier:"testFormatter", pattern: "test %F{'padding':'10'}")
    let info: LogInfoDictionary = [LogInfoKeys.FileName: "12345"]
    
    // Execute
    let formattedMessage = formatter.format(message: "", info: info)
    
    // Validate
    XCTAssertEqual(formattedMessage, "test 12345     ")
  }
  
  func testFormatterAppliesFileNameMarkerWithCommonParametersNegativePadding() {
    let formatter = try! PatternFormatter(identifier:"testFormatter", pattern: "test %F{'padding':'-10'}")
    let info: LogInfoDictionary = [LogInfoKeys.FileName: "12345"]
    
    // Execute
    let formattedMessage = formatter.format(message: "", info: info)
    
    // Validate
    XCTAssertEqual(formattedMessage, "test      12345")
  }
  
  func testFormatterAppliesFileNameMarkerWithCommonParametersZeroPadding() {
    let formatter = try! PatternFormatter(identifier:"testFormatter", pattern: "test %F{'padding':'0'}")
    let info: LogInfoDictionary = [LogInfoKeys.FileName: "12345"]
    
    // Execute
    let formattedMessage = formatter.format(message: "", info: info)
    
    // Validate
    XCTAssertEqual(formattedMessage, "test 12345")
  }
  
  func testFormatterAppliesShortFileNameMarker() {
    let formatter = try! PatternFormatter(identifier:"testFormatter", pattern: "test %f")
    let info: LogInfoDictionary = [LogInfoKeys.FileName: "/test/testFileName.txt"]
    
    // Execute
    let formattedMessage = formatter.format(message: "", info: info)
    
    // Validate
    XCTAssertEqual(formattedMessage, "test testFileName.txt")
  }
  
  func testFormatterAppliesShortFileNameMarkerWithCommonParametersPadding() {
    let formatter = try! PatternFormatter(identifier:"testFormatter", pattern: "test %f{'padding':'10'}")
    let info: LogInfoDictionary = [LogInfoKeys.FileName: "/test/12345"]
    
    // Execute
    let formattedMessage = formatter.format(message: "", info: info)
    
    // Validate
    XCTAssertEqual(formattedMessage, "test 12345     ")
  }
  
  func testFormatterAppliesShortFileNameMarkerWithCommonParametersNegativePadding() {
    let formatter = try! PatternFormatter(identifier:"testFormatter", pattern: "test %f{'padding':'-10'}")
    let info: LogInfoDictionary = [LogInfoKeys.FileName: "/test/12345"]
    
    // Execute
    let formattedMessage = formatter.format(message: "", info: info)
    
    // Validate
    XCTAssertEqual(formattedMessage, "test      12345")
  }
  
  func testFormatterAppliesShortFileNameMarkerWithCommonParametersZeroPadding() {
    let formatter = try! PatternFormatter(identifier:"testFormatter", pattern: "test %f{'padding':'0'}")
    let info: LogInfoDictionary = [LogInfoKeys.FileName: "/test/12345"]
    
    // Execute
    let formattedMessage = formatter.format(message: "", info: info)
    
    // Validate
    XCTAssertEqual(formattedMessage, "test 12345")
  }
  
  func testFormatterAppliesFileLineMarker() {
    let formatter = try! PatternFormatter(identifier:"testFormatter", pattern: "test %L")
    let info: LogInfoDictionary = [LogInfoKeys.FileLine: 42]
    
    // Execute
    let formattedMessage = formatter.format(message: "", info: info)
    
    // Validate
    XCTAssertEqual(formattedMessage, "test 42")
  }
  
  func testFormatterAppliesFileLineMarkerWithCommonParametersPadding() {
    let formatter = try! PatternFormatter(identifier:"testFormatter", pattern: "test %L{'padding':'5'}")
    let info: LogInfoDictionary = [LogInfoKeys.FileLine: 42]
    
    // Execute
    let formattedMessage = formatter.format(message: "", info: info)
    
    // Validate
    XCTAssertEqual(formattedMessage, "test 42   ")
  }
  
  func testFormatterAppliesFileLineMarkerWithCommonParametersNegativePadding() {
    let formatter = try! PatternFormatter(identifier:"testFormatter", pattern: "test %L{'padding':'-5'}")
    let info: LogInfoDictionary = [LogInfoKeys.FileLine: 42]
    
    // Execute
    let formattedMessage = formatter.format(message: "", info: info)
    
    // Validate
    XCTAssertEqual(formattedMessage, "test    42")
  }
  
  func testFormatterAppliesFileLineMarkerWithCommonParametersZeroPadding() {
    let formatter = try! PatternFormatter(identifier:"testFormatter", pattern: "test %L{'padding':'0'}")
    let info: LogInfoDictionary = [LogInfoKeys.FileLine: 42]
    
    // Execute
    let formattedMessage = formatter.format(message: "", info: info)
    
    // Validate
    XCTAssertEqual(formattedMessage, "test 42")
  }

  func testFormatterAppliesFunctionMarker() {
    let formatter = try! PatternFormatter(identifier:"testFormatter", pattern: "test %M")
    let info: LogInfoDictionary = [LogInfoKeys.Function: "testFunction"]

    // Execute
    let formattedMessage = formatter.format(message: "", info: info)

    // Validate
    XCTAssertEqual(formattedMessage, "test testFunction")
  }

  func testFormatterAppliesFunctionMarkerWithCommonParametersPadding() {
    let formatter = try! PatternFormatter(identifier:"testFormatter", pattern: "test %M{'padding':'10'}")
    let info: LogInfoDictionary = [LogInfoKeys.Function: "12345"]

    // Execute
    let formattedMessage = formatter.format(message: "", info: info)

    // Validate
    XCTAssertEqual(formattedMessage, "test 12345     ")
  }

  func testFormatterAppliesFunctionMarkerWithCommonParametersNegativePadding() {
    let formatter = try! PatternFormatter(identifier:"testFormatter", pattern: "test %M{'padding':'-10'}")
    let info: LogInfoDictionary = [LogInfoKeys.Function: "12345"]

    // Execute
    let formattedMessage = formatter.format(message: "", info: info)

    // Validate
    XCTAssertEqual(formattedMessage, "test      12345")
  }

  func testFormatterAppliesFunctionMarkerWithCommonParametersZeroPadding() {
    let formatter = try! PatternFormatter(identifier:"testFormatter", pattern: "test %M{'padding':'0'}")
    let info: LogInfoDictionary = [LogInfoKeys.Function: "12345"]

    // Execute
    let formattedMessage = formatter.format(message: "", info: info)

    // Validate
    XCTAssertEqual(formattedMessage, "test 12345")
  }

  func testFormatterAppliesPercentageMarker() {
    let formatter = try! PatternFormatter(identifier:"testFormatter", pattern: "test %%")
    let info = LogInfoDictionary()
    
    // Execute
    let formattedMessage = formatter.format(message: "", info: info)
    
    // Validate
    XCTAssertEqual(formattedMessage, "test %")
  }
  
  func testFormatterDoesNotReplaceUnknownMarkers() {
    let formatter = try! PatternFormatter(identifier:"testFormatter", pattern: "%x %y %z are unknown markers")
    let info = LogInfoDictionary()
    
    // Execute
    let formattedMessage = formatter.format(message: "", info: info)
    
    // Validate
    XCTAssertEqual(formattedMessage, "%x %y %z are unknown markers")
  }
  
  func testFormatterWithComplexFormatting() {
    let formatter = try! PatternFormatter(identifier:"testFormatter", pattern: "[%l][%n] %m")
    let info: LogInfoDictionary = [
      LogInfoKeys.LoggerName: "nameOfTheLogger",
      LogInfoKeys.LogLevel: LogLevel.Warning
    ]
    
    // Execute
    let formattedMessage = formatter.format(message: "Log message", info: info)
    
    // Validate
    XCTAssertEqual(formattedMessage, "[\(LogLevel.Warning)][nameOfTheLogger] Log message")
  }
  
  func testFormatterReturnsDashIfDataUnavailableForMarkers() {
    let formatter = try! PatternFormatter(identifier: "testFormatter", pattern: "[%l][%n][%F][%f][%L][%M][%t][%T] %m")
    let info = LogInfoDictionary()
    
    // Execute
    let formattedMessage = formatter.format(message: "Log message", info: info)
    
    // Validate
    XCTAssertEqual(formattedMessage, "[-][-][-][-][-][-][-][-] Log message")
  }

  func testUpdatingFormatterFromDictionaryWithNoPatternThrowsError() {
    let dictionary = Dictionary<String, Any>()
    let formatter = PatternFormatter("testFormatter")
    
    XCTAssertThrows { try formatter.update(withDictionary: dictionary) }
  }

  func testUpdatingFormatterFromDictionaryWithInvalidPatternThrowsError() {
    let dictionary = [PatternFormatter.DictionaryKey.Pattern.rawValue: "%x{"]
    let formatter = PatternFormatter("testFormatter")
    
    XCTAssertThrows { try formatter.update(withDictionary: dictionary) }
  }
  
  func testUpdatingFormatterFromDictionaryWithValidParametersCreatesFormatter() {
    let dictionary = [PatternFormatter.DictionaryKey.Pattern.rawValue: "static test pattern"]
    let formatter = PatternFormatter("testFormatter")

    _ = XCTAssertNoThrow { try formatter.update(withDictionary: dictionary); }

    let formattedMessage = formatter.format(message: "", info: LogInfoDictionary())
    XCTAssertEqual(formattedMessage, dictionary[PatternFormatter.DictionaryKey.Pattern.rawValue]!)
  }
  
  func testFormatterAppliesHighResDateMarkerWithDefaultFormatIfNoneIsSpecified() {
    let formatter = try! PatternFormatter(identifier:"testFormatter", pattern: "%D")
    let info: LogInfoDictionary = [.Timestamp: 123456789.876]
    
    // Execute
    let formattedMessage = formatter.format(message: "", info: info)
    
    // Validate (regex used to avoid problems with time shift)
    let validationRegexp = try! NSRegularExpression(pattern: "^1973-11-(29|30) [0-2][0-9]:(03|33|18):09.876$", options: NSRegularExpression.Options())
    let matches = validationRegexp.matches(in: formattedMessage, options: NSRegularExpression.MatchingOptions(), range: NSMakeRange(0, formattedMessage.lengthOfBytes(using: String.Encoding.utf8)))
    XCTAssert(matches.count > 0, "Formatted date '\(formattedMessage)' is not valid")
  }
  
  func testFormatterAppliesCocoaDateMarkerWithFormat() {
    let formatter = try! PatternFormatter(identifier:"testFormatter", pattern: "%D{\"format\":\"dd.MM.yy HH:mm:ss.SSS\"}")
    let info: LogInfoDictionary = [.Timestamp: 123456789.876]
    
    // Execute
    let formattedMessage = formatter.format(message: "", info: info)
    
    // Validate (regex used to avoid problems with time shift)
    let validationRegexp = try! NSRegularExpression(pattern: "^(29|30).11.73 [0-2][0-9]:(03|33|18):09.876$", options: NSRegularExpression.Options())
    let matches = validationRegexp.matches(in: formattedMessage, options: NSRegularExpression.MatchingOptions(), range: NSMakeRange(0, formattedMessage.lengthOfBytes(using: String.Encoding.utf8)))
    XCTAssert(matches.count > 0, "Formatted date '\(formattedMessage)' is not valid")
  }
  
  func testFormatterAppliesCocoaDateMarkerWithFormatAndPadding() {
    let formatter = try! PatternFormatter(identifier:"testFormatter", pattern: "%D{'padding':'23', 'format':'dd.MM.yy HH:mm:ss.SSS'}")
    let info: LogInfoDictionary = [.Timestamp: 123456789.876]
    
    // Execute
    let formattedMessage = formatter.format(message: "", info: info)
    
    // Validate (regex used to avoid problems with time shift)
    let validationRegexp = try! NSRegularExpression(pattern: "^(29|30).11.73 [0-2][0-9]:(03|33|18):09.876  $", options: NSRegularExpression.Options())
    let matches = validationRegexp.matches(in: formattedMessage, options: NSRegularExpression.MatchingOptions(), range: NSMakeRange(0, formattedMessage.lengthOfBytes(using: String.Encoding.utf8)))
    XCTAssert(matches.count > 0, "Formatted date '\(formattedMessage)' is not valid")
  }
  
  func testFormatterAppliesCocoaDateMarkerWithFormatAndNegativePadding() {
    let formatter = try! PatternFormatter(identifier:"testFormatter", pattern: "%D{'padding':'-23', 'format':'dd.MM.yy HH:mm:ss.SSS'}")
    let info: LogInfoDictionary = [.Timestamp: 123456789.876]
    
    // Execute
    let formattedMessage = formatter.format(message: "", info: info)
    
    // Validate (regex used to avoid problems with time shift)
    let validationRegexp = try! NSRegularExpression(pattern: "^  (29|30).11.73 [0-2][0-9]:(03|33|18):09.876$", options: NSRegularExpression.Options())
    let matches = validationRegexp.matches(in: formattedMessage, options: NSRegularExpression.MatchingOptions(), range: NSMakeRange(0, formattedMessage.lengthOfBytes(using: String.Encoding.utf8)))
    XCTAssert(matches.count > 0, "Formatted date '\(formattedMessage)' is not valid")
  }
  
  func testFormatterAppliesCocoaDateMarkerWithFormatAndZeroPadding() {
    let format = "dd.MM.yy HH:mm:ss.SSS"
    let timestamp = 123456789.876
    let formatter = try! PatternFormatter(identifier:"testFormatter", pattern: "%D{'padding':'0', 'format':'\(format)'}")
    let info: LogInfoDictionary = [.Timestamp: timestamp]
    
    // Execute
    let formattedMessage = formatter.format(message: "", info: info)
    
    // Validate
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = format
    let decodedDate = dateFormatter.date(from: formattedMessage)
    XCTAssertEqual(decodedDate?.timeIntervalSince1970 ?? 0.0, timestamp, accuracy: 0.01, "Formatted date '\(formattedMessage)' is not valid")
  }
  
  func testFormatterAppliesCocoaDateMarkerWithCurrentTimestampIfNoneIsProvided() {
    let format = "dd.MM.yy HH:mm:ss.SSS"
    let formatter = try! PatternFormatter(identifier:"testFormatter", pattern: "%D{'format':'\(format)'}")
    
    let expectedDate = Date()
    
    // Execute
    let formattedMessage = formatter.format(message: "", info: [:])
    
    // Validate
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = format
    let decodedDate = dateFormatter.date(from: formattedMessage) ?? Date.distantPast
    XCTAssert(abs(expectedDate.timeIntervalSince(decodedDate)) < 0.01, "Formatted date is not now when no timestamp is provided")
  }
  
  func testFormatterAppliesThreadIdMarker() {
    let formatter = try! PatternFormatter(identifier:"testFormatter", pattern: "test %t")
    let info: LogInfoDictionary = [.ThreadId: UInt64(0x1234567890ABCDEF)]
    
    // Execute
    let formattedMessage = formatter.format(message: "", info: info)
    
    // Validate
    XCTAssertEqual(formattedMessage, "test 1234567890abcdef")
  }
  
  func testFormatterAppliesThreadIdMarkerWithCommonParametersPadding() {
    let formatter = try! PatternFormatter(identifier:"testFormatter", pattern: "test %t{'padding':'20'}")
    let info: LogInfoDictionary = [.ThreadId: UInt64(0x1234567890ABCDEF)]
    
    // Execute
    let formattedMessage = formatter.format(message: "", info: info)
    
    // Validate
    XCTAssertEqual(formattedMessage, "test 1234567890abcdef    ")
  }
  
  func testFormatterAppliesThreadIdMarkerWithCommonParametersNegativePadding() {
    let formatter = try! PatternFormatter(identifier:"testFormatter", pattern: "test %t{'padding':'-20'}")
    let info: LogInfoDictionary = [.ThreadId: UInt64(0x1234567890ABCDEF)]
    
    // Execute
    let formattedMessage = formatter.format(message: "", info: info)
    // Validate
    XCTAssertEqual(formattedMessage, "test     1234567890abcdef")
  }
  
  func testFormatterAppliesThreadIdMarkerWithCommonParametersZeroPadding() {
    let formatter = try! PatternFormatter(identifier:"testFormatter", pattern: "test %t{'padding':'0'}")
    let info: LogInfoDictionary = [.ThreadId: UInt64(0x1234567890ABCDEF)]
    
    // Execute
    let formattedMessage = formatter.format(message: "", info: info)
    
    // Validate
    XCTAssertEqual(formattedMessage, "test 1234567890abcdef")
  }
  
  func testFormatterAppliesThreadNameMarker() {
    let formatter = try! PatternFormatter(identifier:"testFormatter", pattern: "test %T")
    let info: LogInfoDictionary = [.ThreadName: "nameOfThread"]
    
    // Execute
    let formattedMessage = formatter.format(message: "", info: info)
    
    // Validate
    XCTAssertEqual(formattedMessage, "test nameOfThread")
  }
  
  func testFormatterAppliesThreadNameMarkerWithCommonParametersPadding() {
    let formatter = try! PatternFormatter(identifier:"testFormatter", pattern: "test %T{'padding':'15'}")
    let info: LogInfoDictionary = [.ThreadName: "nameOfThread"]
    
    // Execute
    let formattedMessage = formatter.format(message: "", info: info)
    
    // Validate
    XCTAssertEqual(formattedMessage, "test nameOfThread   ")
  }
  
  func testFormatterAppliesThreadNameMarkerWithCommonParametersNegativePadding() {
    let formatter = try! PatternFormatter(identifier:"testFormatter", pattern: "test %T{'padding':'-15'}")
    let info: LogInfoDictionary = [.ThreadName: "nameOfThread"]
    
    // Execute
    let formattedMessage = formatter.format(message: "", info: info)
    
    // Validate
    XCTAssertEqual(formattedMessage, "test    nameOfThread")
  }
  
  func testFormatterAppliesThreadNameMarkerWithCommonParametersZeroPadding() {
    let formatter = try! PatternFormatter(identifier:"testFormatter", pattern: "test %T{'padding':'0'}")
    let info: LogInfoDictionary = [.ThreadName: "nameOfThread"]
    
    // Execute
    let formattedMessage = formatter.format(message: "", info: info)
    
    // Validate
    XCTAssertEqual(formattedMessage, "test nameOfThread")
  }

  // MARK: Tests for process identifier marker

  func testFormatterAppliesProcessIdMarker() {

    let expectedProcessId = String(ProcessInfo.processInfo.processIdentifier, radix: 16, uppercase: false)
    let formatter = try! PatternFormatter(identifier:"testFormatter", pattern: "test %p")

    // Execute
    let formattedMessage = formatter.format(message: "", info: [:])

    // Validate
    XCTAssertEqual(formattedMessage, "test \(expectedProcessId)")
  }

  func testFormatterAppliesProcessIdMarkerWithCommonParametersPadding() {

    let expectedProcessId = String(ProcessInfo.processInfo.processIdentifier, radix: 16, uppercase: false)
    let formatter = try! PatternFormatter(identifier:"testFormatter", pattern: "test %p{'padding':'10'}")

    // Execute
    let formattedMessage = formatter.format(message: "", info: [:])

    // Validate
    XCTAssertEqual(formattedMessage, "test \(expectedProcessId)     ")
  }

  func testFormatterAppliesProcessIdMarkerWithCommonParametersNegativePadding() {

    let expectedProcessId = String(ProcessInfo.processInfo.processIdentifier, radix: 16, uppercase: false)
    let formatter = try! PatternFormatter(identifier:"testFormatter", pattern: "test %p{'padding':'-10'}")

    // Execute
    let formattedMessage = formatter.format(message: "", info: [:])
    // Validate
    XCTAssertEqual(formattedMessage, "test      \(expectedProcessId)")
  }

  func testFormatterAppliesProcessIdMarkerWithCommonParametersZeroPadding() {

    let expectedProcessId = String(ProcessInfo.processInfo.processIdentifier, radix: 16, uppercase: false)
    let formatter = try! PatternFormatter(identifier:"testFormatter", pattern: "test %p{'padding':'0'}")

    // Execute
    let formattedMessage = formatter.format(message: "", info: [:])

    // Validate
    XCTAssertEqual(formattedMessage, "test \(expectedProcessId)")
  }
}
