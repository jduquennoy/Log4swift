//
//  StdOutAppender.swift
//  Log4swift
//
//  Created by Jérôme Duquennoy on 16/06/2015.
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

/// Tests of the stdout appender.
/// In those tests, the output is not tested for strict equality for test robustness:
/// we might receive other logs for the OS while tests are running.
class StdOutAppenderTests: XCTestCase {
  let savedStdout = dup(fileno(stdout))
  let savedStderr = dup(fileno(stderr))
  var stdoutReadFileHandle = FileHandle()
  var stderrReadFileHandle = FileHandle()
  
  override func setUp() {
    super.setUp()
    
    // Capture stdout and stderr
    
    let stdoutPipe = Pipe()
    self.stdoutReadFileHandle = stdoutPipe.fileHandleForReading
    dup2(stdoutPipe.fileHandleForWriting.fileDescriptor, fileno(stdout))
    
    let stderrPipe = Pipe()
    self.stderrReadFileHandle = stderrPipe.fileHandleForReading
    dup2(stderrPipe.fileHandleForWriting.fileDescriptor, fileno(stderr))
  }
  
  override func tearDown() {
    dup2(self.savedStdout, fileno(stdout))
    dup2(self.savedStderr, fileno(stderr))
  }
  
  func testStdOutAppenderDefaultErrorThresholdIsError() {
    let appender = StdOutAppender("appender")
    
    // Validate
    if let errorThreshold = appender.errorThresholdLevel {
      XCTAssertEqual(errorThreshold, LogLevel.Error)
    } else {
      XCTFail("Default error threshold is not defined")
    }
  }
  
  func testStdOutAppenderWritesLogToStdoutWithALineFeedIfErrorThresholdIsNotDefined() {
    let appender = StdOutAppender("appender")
    
    // Execute
    appender.log("log value", level: .Info, info: LogInfoDictionary())
    
    // Validate
    if let stdoutContent = getFileHandleContentAsString(self.stdoutReadFileHandle) {
      XCTAssertTrue(stdoutContent.contains("log value\n"))
    }
  }
  
  func testStdOutAppenderWritesLogToStdoutWithALineFeedIfErrorThresholdIsNotReached() {
    let appender = StdOutAppender("appender")
    appender.errorThresholdLevel = .Warning
    
    // Execute
    appender.log("log value", level: .Info, info: LogInfoDictionary())
    
    // Validate
    if let stdoutContent = getFileHandleContentAsString(self.stdoutReadFileHandle) {
      XCTAssertTrue(stdoutContent.contains("log value\n"))
    }
  }
  
  func testStdOutAppenderWritesLogToStderrWithALineFeedIfErrorThresholdIsReached() {
    let appender = StdOutAppender("appender")
    appender.errorThresholdLevel = .Warning
    
    // Execute
    appender.log("log value", level: .Warning, info: LogInfoDictionary())
    
    // Validate
    if let stderrContent = getFileHandleContentAsString(self.stderrReadFileHandle) {
      XCTAssertTrue(stderrContent.contains("log value\n"))
    }
  }
  
  // MARK: - Update from dictionary testing
  
  func testUpdatingAppenderFromDictionaryWithNoThresholdDoesNotChangeIt() {
    let dictionary = [LoggerFactory.DictionaryKey.Identifier.rawValue: "testAppender"]
    let appender = StdOutAppender("test appender")
    appender.thresholdLevel = .Info
    
    // Execute
    try! appender.update(withDictionary: dictionary, availableFormatters: [])
    
    // Validate
    XCTAssertEqual(appender.thresholdLevel, LogLevel.Info)
  }

  func testUpdatingAppenderFromDictionaryWithInvalidThresholdThrowsError() {
    let dictionary = [LoggerFactory.DictionaryKey.Identifier.rawValue: "testAppender",
      StdOutAppender.DictionaryKey.ThresholdLevel.rawValue: "invalid level"]
    let appender = StdOutAppender("test appender")

    // Execute & validate
    XCTAssertThrows { try appender.update(withDictionary: dictionary, availableFormatters: []) }
  }
  
  func testUpdatingAppenderFromDictionaryWithThresholdUsesSpecifiedValue() {
    let dictionary = [LoggerFactory.DictionaryKey.Identifier.rawValue: "testAppender",
      StdOutAppender.DictionaryKey.ThresholdLevel.rawValue: LogLevel.Info.description]
    let appender = StdOutAppender("test appender")
    appender.thresholdLevel = .Debug
    
    // Execute
    try! appender.update(withDictionary: dictionary, availableFormatters:[])
    
    // Validate
    XCTAssertEqual(appender.thresholdLevel, LogLevel.Info)
  }
  
  func testUpdatingAppenderFromDictionaryWithNoErrorThresholdUsesNilErrorThresholdByDefault() {
    let dictionary = [LoggerFactory.DictionaryKey.Identifier.rawValue: "testAppender"]
    let appender = StdOutAppender("test appender")
    appender.errorThresholdLevel = .Debug

    // Execute
    try! appender.update(withDictionary: dictionary, availableFormatters: [])
    
    // Validate
    XCTAssert(appender.errorThresholdLevel == nil)
  }
  
  func testUpdatingAppenderFromDictionaryWithInvalidErrorThresholdThrowsError() {
    let dictionary = [LoggerFactory.DictionaryKey.Identifier.rawValue: "testAppender",
      StdOutAppender.DictionaryKey.ErrorThreshold.rawValue: "invalid level"]
    let appender = StdOutAppender("test appender")
    
    // Execute & validate
    XCTAssertThrows { try appender.update(withDictionary: dictionary, availableFormatters: []) }
  }
  
  func testUpdatingAppenderFromDictionaryWithErrorThresholdUsesSpecifiedValue() {
    let dictionary = [LoggerFactory.DictionaryKey.Identifier.rawValue: "testAppender",
      StdOutAppender.DictionaryKey.ErrorThreshold.rawValue: LogLevel.Info.description]
    let appender = StdOutAppender("test appender")
    appender.errorThresholdLevel = .Info
    
    // Execute
    try! appender.update(withDictionary: dictionary, availableFormatters: [])
    
    // Validate
    XCTAssertEqual(appender.errorThresholdLevel!, LogLevel.Info)
  }
  
  func testUpdatingAppenderFromDictionaryWithNonExistingFormatterIdThrowsError() {
    let dictionary = [LoggerFactory.DictionaryKey.Identifier.rawValue: "testAppender",
      Appender.DictionaryKey.FormatterId.rawValue: "not existing id"]
    let appender = StdOutAppender("test appender")
    
    XCTAssertThrows { try appender.update(withDictionary: dictionary, availableFormatters: []) }
  }
  
  func testUpdatingAppenderFromDictionaryWithExistingFormatterIdUsesIt() {
    let formatter = try! PatternFormatter(identifier: "formatterId", pattern: "test pattern")
    let dictionary = [LoggerFactory.DictionaryKey.Identifier.rawValue: "testAppender",
      Appender.DictionaryKey.FormatterId.rawValue: "formatterId"]
    let appender = StdOutAppender("test appender")
    
    // Execute
    try! appender.update(withDictionary: dictionary, availableFormatters: [formatter])
    
    // Validate
    XCTAssertEqual((appender.formatter?.identifier)!, formatter.identifier)
  }
  
  func testUpdatingAppenderFromDictionaryWithTextColorsUsesThem() {
    let textColors = [LogLevel.Error.description: "red",
      LogLevel.Info.description: "Green"]
    let dictionary: [String: Any] = [LoggerFactory.DictionaryKey.Identifier.rawValue: "testAppender",
      StdOutAppender.DictionaryKey.TextColors.rawValue: textColors]
    let appender = StdOutAppender("test appender")
    appender.thresholdLevel = .Debug
    
    // Execute
    try! appender.update(withDictionary: dictionary, availableFormatters:[])
    
    // Validate
    XCTAssertEqual(appender.textColors, [LogLevel.Error: StdOutAppender.TTYColor.Red, LogLevel.Info: StdOutAppender.TTYColor.Green])
  }
  
  func testUpdatingAppenderFromDictionaryWithInvalidTextColorsThrowsError() {
    let textColors = [LogLevel.Error.description: "Invalide color",
      LogLevel.Info.description: "Green"]
    let dictionary: [String: Any] = [LoggerFactory.DictionaryKey.Identifier.rawValue: "testAppender",
      StdOutAppender.DictionaryKey.TextColors.rawValue: textColors]
    let appender = StdOutAppender("test appender")
    appender.thresholdLevel = .Debug
    
    // Execute & validate
    XCTAssertThrows { try appender.update(withDictionary: dictionary, availableFormatters: []) }
  }
  
  func testUpdatingAppenderFromDictionaryWithInvalidLevelInTextColorsThrowsError() {
    let textColors = ["Invalid level": "Red",
      LogLevel.Info.description: "Green"]
    let dictionary: [String: Any] = [LoggerFactory.DictionaryKey.Identifier.rawValue: "testAppender",
      StdOutAppender.DictionaryKey.TextColors.rawValue: textColors]
    let appender = StdOutAppender("test appender")
    appender.thresholdLevel = .Debug
    
    // Execute & validate
    XCTAssertThrows { try appender.update(withDictionary: dictionary, availableFormatters: []) }
  }
  
  func testUpdatingAppenderFromDictionaryWithBackgroundColorsUsesThem() {
    let textColors = [LogLevel.Error.description: "red",
      LogLevel.Info.description: "Green"]
    let dictionary: [String: Any] = [LoggerFactory.DictionaryKey.Identifier.rawValue: "testAppender",
      StdOutAppender.DictionaryKey.BackgroundColors.rawValue: textColors]
    let appender = StdOutAppender("test appender")
    appender.thresholdLevel = .Debug
    
    // Execute
    try! appender.update(withDictionary: dictionary, availableFormatters:[])
    
    // Validate
    XCTAssertEqual(appender.backgroundColors, [LogLevel.Error: StdOutAppender.TTYColor.Red, LogLevel.Info: StdOutAppender.TTYColor.Green])
  }
  
  func testUpdatingAppenderFromDictionaryWithForcedXtermTTYTypeUsesSpecifiedType() {
    let dictionary: [String: Any] = [LoggerFactory.DictionaryKey.Identifier.rawValue: "testAppender",
      StdOutAppender.DictionaryKey.ForcedTTYType.rawValue: "xTeRm"]
    let appender = StdOutAppender("test appender")
    appender.ttyType = .XcodeColors
    
    // Execute
    try! appender.update(withDictionary: dictionary, availableFormatters:[])
    
    // Validate
    XCTAssertEqual(appender.ttyType, StdOutAppender.TTYType.XtermColor)
  }
  
  func testUpdatingAppenderFromDictionaryWithForcedXcodeColorsTTYTypeUsesSpecifiedType() {
    let dictionary: [String: Any] = [LoggerFactory.DictionaryKey.Identifier.rawValue: "testAppender",
      StdOutAppender.DictionaryKey.ForcedTTYType.rawValue: "xCoDEcolors"]
    let appender = StdOutAppender("test appender")
    appender.ttyType = .XtermColor
    
    // Execute
    try! appender.update(withDictionary: dictionary, availableFormatters:[])
    
    // Validate
    XCTAssertEqual(appender.ttyType, StdOutAppender.TTYType.XcodeColors)
  }
  
  func testUpdatingAppenderFromDictionaryWithUnknownTTYTypeUsesOtherType() {
    let dictionary: [String: Any] = [LoggerFactory.DictionaryKey.Identifier.rawValue: "testAppender",
      StdOutAppender.DictionaryKey.ForcedTTYType.rawValue: "UnknownType"]
    let appender = StdOutAppender("test appender")
    appender.ttyType = .XtermColor
    
    // Execute
    try! appender.update(withDictionary: dictionary, availableFormatters:[])
    
    // Validate
    XCTAssertEqual(appender.ttyType, StdOutAppender.TTYType.Other)
  }
  
  func testUpdatingAppenderFromDictionaryWithInvalidBackgroundColorsThrowsError() {
    let textColors = [LogLevel.Error.description: "Invalide color",
      LogLevel.Info.description: "Green"]
    let dictionary: [String: Any] = [LoggerFactory.DictionaryKey.Identifier.rawValue: "testAppender",
      StdOutAppender.DictionaryKey.BackgroundColors.rawValue: textColors]
    let appender = StdOutAppender("test appender")
    appender.thresholdLevel = .Debug
    
    // Execute & validate
    XCTAssertThrows { try appender.update(withDictionary: dictionary, availableFormatters: []) }
  }
  
  func testUpdatingAppenderFromDictionaryWithInvalidLevelInBackgroundColorsThrowsError() {
    let textColors = ["Invalid level": "Red",
      LogLevel.Info.description: "Green"]
    let dictionary: [String: Any] = [LoggerFactory.DictionaryKey.Identifier.rawValue: "testAppender",
      StdOutAppender.DictionaryKey.BackgroundColors.rawValue: textColors]
    let appender = StdOutAppender("test appender")
    appender.thresholdLevel = .Debug
    
    // Execute & validate
    XCTAssertThrows { try appender.update(withDictionary: dictionary, availableFormatters: []) }
  }

  // MARK: - Colors testing
  
  func testTextColorSetForErrorLevelIsAppliedWithResetAfterLogForXcodeTTY() {
    setenv("XcodeColors", "YES", 1)
    setenv("TERM", "xterm-256color", 1)
    
    let appender = StdOutAppender("appender")
    appender.errorThresholdLevel = .Warning
    
    appender.setTextColor(.Red, forLevel: .Error)
    
    // Execute
    appender.log("log value", level: .Error, info: LogInfoDictionary())
    
    // Validate
    if let stdoutContent = getFileHandleContentAsString(self.stderrReadFileHandle) {
      XCTAssertTrue(stdoutContent.contains("\u{1B}[fg255,0,0;log value\u{1B}[;\n"))
    }
  }
  
  func testTextColorSetForInfoLevelIsAppliedWithResetAfterLogForXtermTTY() {
    setenv("XcodeColors", "", 1)
    setenv("TERM", "xterm-256color", 1)
    
    let appender = StdOutAppender("appender")
    appender.errorThresholdLevel = .Warning
    
    appender.setTextColor(.Red, forLevel: .Error)
    
    // Execute
    appender.log("log value", level: .Error, info: LogInfoDictionary())
    
    // Validate
    if let stdoutContent = getFileHandleContentAsString(self.stderrReadFileHandle) {
      XCTAssertTrue(stdoutContent.contains("\u{1B}[38;5;9mlog value\u{1B}[0m\n"))
    }
  }
  
  func testTextColorSetForInfoLevelIsAppliedWithResetAfterLogForOtherTTY() {
    setenv("XcodeColors", "", 1)
    setenv("TERM", "xterm", 1)
    
    let appender = StdOutAppender("appender")
    appender.errorThresholdLevel = .Warning
    
    appender.setTextColor(.Red, forLevel: .Error)
    
    // Execute
    appender.log("log value", level: .Error, info: LogInfoDictionary())
    
    // Validate
    if let stdoutContent = getFileHandleContentAsString(self.stderrReadFileHandle) {
      XCTAssertTrue(stdoutContent.contains("log value\n"))
    }
  }
  
  func testTextColorSetForInfoLevelDoesNotAffectOtherLevels() {
    setenv("XcodeColors", "YES", 1)
    setenv("TERM", "xterm-256color", 1)
    
    let appender = StdOutAppender("appender")
    appender.errorThresholdLevel = .Warning
    
    appender.setTextColor(.Red, forLevel: .Info)
    
    // Execute
    appender.log("log value", level: .Error, info: LogInfoDictionary())
    
    // Validate
    if let stdoutContent = getFileHandleContentAsString(self.stderrReadFileHandle) {
      XCTAssertTrue(stdoutContent.contains("log value\n"))
    }
  }
  
  func testBackgroundColorSetForWarningLevelIsAppliedWithResetAfterLogForXcodeTTY() {
    setenv("XcodeColors", "YES", 1)
    setenv("TERM", "xterm-256color", 1)
    
    let appender = StdOutAppender("appender")
    appender.errorThresholdLevel = .Warning
    
    appender.setBackgroundColor(.Blue, forLevel: .Warning)
    
    // Execute
    appender.log("log value", level: .Warning, info: LogInfoDictionary())
    
    // Validate
    if let stdoutContent = getFileHandleContentAsString(self.stderrReadFileHandle) {
      XCTAssertTrue(stdoutContent.contains("\u{1B}[bg0,0,255;log value\u{1B}[;\n"))
    }
  }
  
  func testBackgroundColorSetForInfoLevelIsAppliedWithResetAfterLogForXtermTTY() {
    setenv("XcodeColors", "", 1)
    setenv("TERM", "xterm-256color", 1)
    
    let appender = StdOutAppender("appender")
    appender.errorThresholdLevel = .Warning
    
    appender.setBackgroundColor(.Green, forLevel: .Info)
    
    // Execute
    appender.log("log value", level: .Info, info: LogInfoDictionary())
    
    // Validate
    if let stdoutContent = getFileHandleContentAsString(self.stdoutReadFileHandle) {
      XCTAssertTrue(stdoutContent.contains("\u{1B}[48;5;2mlog value\u{1B}[0m\n"))
    }
  }
  
  func testBackgroundColorSetForInfoLevelIsNotAppliedForOtherTTY() {
    setenv("XcodeColors", "", 1)
    setenv("TERM", "xterm", 1)
    
    let appender = StdOutAppender("appender")
    appender.errorThresholdLevel = .Warning
    
    appender.setBackgroundColor(.Red, forLevel: .Error)
    
    // Execute
    appender.log("log value", level: .Error, info: LogInfoDictionary())
    
    // Validate
    if let stdoutContent = getFileHandleContentAsString(self.stderrReadFileHandle) {
      XCTAssertTrue(stdoutContent.contains("log value\n"))
    }
  }
  
  func testBackgroundColorSetForInfoLevelDoesNotAffectOtherLevels() {
    setenv("XcodeColors", "YES", 1)
    setenv("TERM", "xterm-256color", 1)
    
    let appender = StdOutAppender("appender")
    appender.errorThresholdLevel = .Warning
    
    appender.setBackgroundColor(.Yellow, forLevel: .Warning)
    
    // Execute
    appender.log("log value", level: .Error, info: LogInfoDictionary())
    
    // Validate
    if let stdoutContent = getFileHandleContentAsString(self.stderrReadFileHandle) {
      XCTAssertTrue(stdoutContent.contains("log value\n"))
    }
  }
  
  func testSettingANilTextColorSetsNoColor() {
    setenv("XcodeColors", "YES", 1)
    setenv("TERM", "xterm-256color", 1)
    
    let appender = StdOutAppender("appender")
    appender.errorThresholdLevel = .Warning
    
    appender.setTextColor(.DarkGrey, forLevel: .Warning)
    appender.setTextColor(nil, forLevel: .Warning)
    
    // Execute
    appender.log("log value", level: .Warning, info: LogInfoDictionary())
    
    // Validate
    if let stdoutContent = getFileHandleContentAsString(self.stderrReadFileHandle) {
      XCTAssertTrue(stdoutContent.contains("log value\n"))
    }
  }
  
  func testSettingANilBackgroundColorSetsNoColor() {
    setenv("XcodeColors", "YES", 1)
    setenv("TERM", "xterm-256color", 1)
    
    let appender = StdOutAppender("appender")
    appender.errorThresholdLevel = .Warning
    
    appender.setBackgroundColor(.Grey, forLevel: .Warning)
    appender.setBackgroundColor(nil, forLevel: .Warning)
    
    // Execute
    appender.log("log value", level: .Warning, info: LogInfoDictionary())
    
    // Validate
    if let stdoutContent = getFileHandleContentAsString(self.stderrReadFileHandle) {
      XCTAssertTrue(stdoutContent.contains("log value\n"))
    }
  }
  
  func testCreateTTYColorFromStringIsCaseInsensitive() {
    XCTAssertEqual(StdOutAppender.TTYColor("black"), StdOutAppender.TTYColor.Black)
    XCTAssertEqual(StdOutAppender.TTYColor("DarKGrey"), StdOutAppender.TTYColor.DarkGrey)
    XCTAssertEqual(StdOutAppender.TTYColor("greY"), StdOutAppender.TTYColor.Grey)
    XCTAssertEqual(StdOutAppender.TTYColor("liGHTgREY"), StdOutAppender.TTYColor.LightGrey)
    XCTAssertEqual(StdOutAppender.TTYColor("liGHTred"), StdOutAppender.TTYColor.LightRed)
    XCTAssertEqual(StdOutAppender.TTYColor("ReD"), StdOutAppender.TTYColor.Red)
    XCTAssertEqual(StdOutAppender.TTYColor("darkRed"), StdOutAppender.TTYColor.DarkRed)
    XCTAssertEqual(StdOutAppender.TTYColor("lightGreEn"), StdOutAppender.TTYColor.LightGreen)
    XCTAssertEqual(StdOutAppender.TTYColor("GreEn"), StdOutAppender.TTYColor.Green)
    XCTAssertEqual(StdOutAppender.TTYColor("DarKGreEn"), StdOutAppender.TTYColor.DarkGreen)
    XCTAssertEqual(StdOutAppender.TTYColor("lightblue"), StdOutAppender.TTYColor.LightBlue)
    XCTAssertEqual(StdOutAppender.TTYColor("blue"), StdOutAppender.TTYColor.Blue)
    XCTAssertEqual(StdOutAppender.TTYColor("dArkBlue"), StdOutAppender.TTYColor.DarkBlue)
    XCTAssertEqual(StdOutAppender.TTYColor("lightYelloW"), StdOutAppender.TTYColor.LightYellow)
    XCTAssertEqual(StdOutAppender.TTYColor("yellOw"), StdOutAppender.TTYColor.Yellow)
    XCTAssertEqual(StdOutAppender.TTYColor("lightYellow"), StdOutAppender.TTYColor.LightYellow)
    XCTAssertEqual(StdOutAppender.TTYColor("darkPurple"), StdOutAppender.TTYColor.DarkPurple)
    XCTAssertEqual(StdOutAppender.TTYColor("purple"), StdOutAppender.TTYColor.Purple)
    XCTAssertEqual(StdOutAppender.TTYColor("LightPurPLE"), StdOutAppender.TTYColor.LightPurple)
    XCTAssertEqual(StdOutAppender.TTYColor("DARKoRaNGE"), StdOutAppender.TTYColor.DarkOrange)
    XCTAssertEqual(StdOutAppender.TTYColor("oRaNGE"), StdOutAppender.TTYColor.Orange)
    XCTAssertEqual(StdOutAppender.TTYColor("LightoRaNGE"), StdOutAppender.TTYColor.LightOrange)
  }
  
  // MARK: - Private methods

  fileprivate func getFileHandleContentAsString(_ fileHandle: FileHandle) -> String? {
    let expectation = self.expectation(description: "filHandle content received")
    var expectationIsExpired = false
    var stringContent: String?
    
    if #available(OSX 10.10, *) {
      DispatchQueue.global().async(execute: {
        let data = fileHandle.availableData
        stringContent = String(data: data, encoding: .utf8)
        if(!expectationIsExpired) {
          expectation.fulfill()
        }
      })
    } else {
        // Fallback on earlier versions
    }
    
		waitForExpectations(timeout: 1, handler: { error in
      expectationIsExpired = true
    })
    return stringContent
  }
}
