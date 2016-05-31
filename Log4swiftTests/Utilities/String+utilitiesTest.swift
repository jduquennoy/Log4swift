//
//  String+utilitiesTest.swift
//  Log4swift
//
//  Created by Jérôme Duquennoy on 06/10/2015.
//  Copyright © 2015 jerome. All rights reserved.
//

import XCTest

class String_utilitiesTest: XCTestCase {

  func testRemovingLastComponentWitDelimiterRemovesLastComponent() {
    let exempleString = "This is a string"
    
    // Execute
    let truncatedString = exempleString.stringByRemovingLastComponent(withDelimiter: " ")
    
    // Validate
    XCTAssertEqual(truncatedString, "This is a")
  }
  
  func testRemovingLastComponentWitDelimiterReturnsEmptyStringIfDelimiterIsNotFound() {
    let exempleString = "This is a string"
    
    // Execute
		let truncatedString = exempleString.stringByRemovingLastComponent(withDelimiter: ",")
    
    // Validate
    XCTAssertEqual(truncatedString, "")
  }
  
  func testPadToWidthTruncatesEndOfStringIfWidthIsSmallerThanStringLength() {
    let exempleString = "1234567890"
    
    // Execute
		let truncatedString = exempleString.pad(toWidth: 5)
    
    // Validate
    XCTAssertEqual(truncatedString, "12345")
  }
  
  func testPadToWidthTruncatesBeginingOfStringIfWidthIsSmallerThanStringLengthAndNegative() {
    let exempleString = "1234567890"
    
    // Execute
		let truncatedString = exempleString.pad(toWidth: -5)
    
    // Validate
    XCTAssertEqual(truncatedString, "67890")
  }
  
  func testPadToWidthFillsWithTrailingSpacesIfWidthIsBiggerThanStringLength() {
    let exempleString = "1234567890"
    
    // Execute
		let truncatedString = exempleString.pad(toWidth: 12)
    
    // Validate
    XCTAssertEqual(truncatedString, "1234567890  ")
  }
  
  func testPadToWidthFillsWithLeadingSpacesIfWidthIsBiggerThanStringLengthAndNegative() {
    let exempleString = "1234567890"
    
    // Execute
		let truncatedString = exempleString.pad(toWidth: -12)
    
    // Validate
    XCTAssertEqual(truncatedString, "  1234567890")
  }
  
  func testPadWithZeroWidthReturnsOriginalString() {
    let exempleString = "1234567890"
    
    // Execute
		let truncatedString = exempleString.pad(toWidth: 0)
    
    // Validate
    XCTAssertEqual(truncatedString, "1234567890")
  }

  func testToDictionaryWithValidPatterns() {
    var dict: [String:AnyObject]
    
    // Execute
    dict = try! "{\"padding\":\"-57\", \"case\": \"upper\"}".toDictionary()
    
    // Validate
    XCTAssertEqual(dict.keys.count, 2)
    XCTAssertEqual(dict["padding"] as! String?, "-57")
    XCTAssertEqual(dict["case"] as! String?, "upper")
    XCTAssertEqual(dict["missing"] as! String?, nil)
    
    
    // Execute
    dict = try! "{'padding':'-57', 'case': 'upper'}".toDictionary()
    
    // Validate
    XCTAssertEqual(dict.keys.count, 2)
    XCTAssertEqual(dict["padding"] as! String?, "-57")
    XCTAssertEqual(dict["case"] as! String?, "upper")
    XCTAssertEqual(dict["missing"] as! String?, nil)

  
    // Execute
    dict = try! "{\"padding\":'-57', 'case': \"upper\"}".toDictionary()
    
    // Validate
    XCTAssertEqual(dict.keys.count, 2)
    XCTAssertEqual(dict["padding"] as! String?, "-57")
    XCTAssertEqual(dict["case"] as! String?, "upper")
    XCTAssertEqual(dict["missing"] as! String?, nil)
  }

  func testToDictionaryWithInvalidPatterns() {
    var dict: [String:AnyObject]? = nil
    
    // Execute/Validate
    XCTAssertThrows { try dict = "{\"padding\":-57, case: \"upper\"}".toDictionary() }
    XCTAssertThrows { try dict = "\"padding\":\"-57\", \"case\": \"upper\"".toDictionary() }
    XCTAssertNil(dict)
  }

  func testFormatLongStringWithPercentCharsButNoArguments() {
    let appender = MemoryAppender()
    appender.thresholdLevel = .Debug
    let pattern = "This is a string \"with\" special %characters including escapes : %x %2C %d %s %2C %s %2C"
    var logString = ""
    
    for index in 0...10000 {
      logString += "pattern #\(index): \(pattern)"
    }
    
    // Execute
		_ = logString.format(args: [])
    
    // Validate
    // Nothing to do, it should just not crash
  }
}