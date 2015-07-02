//
//  ConsoleAppender.swift
//  Log4swift
//
//  Created by Jérôme Duquennoy on 16/06/2015.
//  Copyright © 2015 Jérôme Duquennoy. All rights reserved.
//
// Log4swift is free software: you can redistribute it and/or modify
// it under the terms of the GNU Lesser General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// Log4swift is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU Lesser General Public License for more details.
//
// You should have received a copy of the GNU Lesser General Public License
// along with Foobar. If not, see <http://www.gnu.org/licenses/>.
//

import XCTest
@testable import Log4swift

class ConsoleAppenderTests: XCTestCase {
  let savedStdout = dup(fileno(stdout));
  let savedStderr = dup(fileno(stderr));
  var stdoutReadFileHandle = NSFileHandle();
  var stderrReadFileHandle = NSFileHandle();
  
  override func setUp() {
    super.setUp()
    
    // Capture stdout and stderr
    
    let stdoutPipe = NSPipe();
    self.stdoutReadFileHandle = stdoutPipe.fileHandleForReading;
    dup2(stdoutPipe.fileHandleForWriting.fileDescriptor, fileno(stdout));
    
    let stderrPipe = NSPipe();
    self.stderrReadFileHandle = stderrPipe.fileHandleForReading;
    dup2(stderrPipe.fileHandleForWriting.fileDescriptor, fileno(stderr));
  }
  
  override func tearDown() {
    dup2(self.savedStdout, fileno(stdout));
    dup2(self.savedStderr, fileno(stderr));
  }
  
  func testConsoleAppenderDefaultErrorThresholdIsError() {
    let appender = ConsoleAppender("appender");
    
    // Validate
    if let errorThreshold = appender.errorThresholdLevel {
      XCTAssertEqual(errorThreshold, LogLevel.Error);
    } else {
      XCTFail("Default error threshold is not defined");
    }
  }
  
  func testConsoleAppenderWritesLogToStdoutWithALineFeedIfErrorThresholdIsNotDefined() {
    let appender = ConsoleAppender("appender");
    
    // Execute
    appender.log("log value", level: .Info, info: FormatterInfoDictionary());
    
    // Validate
    if let stdoutContent = getFileHandleContentAsString(self.stdoutReadFileHandle) {
      XCTAssertEqual(stdoutContent, "log value\n");
    }
  }
  
  func testConsoleAppenderWritesLogToStdoutWithALineFeedIfErrorThresholdIsNotReached() {
    let appender = ConsoleAppender("appender");
    appender.errorThresholdLevel = .Warning;
    
    // Execute
    appender.log("log value", level: .Info, info: FormatterInfoDictionary());
    
    // Validate
    if let stdoutContent = getFileHandleContentAsString(self.stdoutReadFileHandle) {
      XCTAssertEqual(stdoutContent, "log value\n");
    }
  }
  
  func testConsoleAppenderWritesLogToStderrWithALineFeedIfErrorThresholdIsReached() {
    let appender = ConsoleAppender("appender");
    appender.errorThresholdLevel = .Warning;
    
    // Execute
    appender.log("log value", level: .Warning, info: FormatterInfoDictionary());
    
    // Validate
    if let stderrContent = getFileHandleContentAsString(self.stderrReadFileHandle) {
      XCTAssertEqual(stderrContent, "log value\n");
    }
  }
  
  func testCreatingAppenderFromDictionaryWithNoIdentifierThrowsError() {
    let dictionary = Dictionary<String, AnyObject>();
    
    XCTAssertThrows { try ConsoleAppender(dictionary, availableFormatters: []) };
  }

  func testCreatingAppenderFromDictionaryWithNoThresholdUsesDebugByDefault() {
    let dictionary = [ConsoleAppender.DictionaryKey.Identifier.rawValue: "testAppender"];
    
    // Execute
    let appender = try! ConsoleAppender(dictionary, availableFormatters: []);
    
    // Validate
    XCTAssertEqual(appender.thresholdLevel, LogLevel.Debug);
  }

  func testCreatingAppenderFromDictionaryWithInvalidThresholdThrowsError() {
    let dictionary = [ConsoleAppender.DictionaryKey.Identifier.rawValue: "testAppender",
      ConsoleAppender.DictionaryKey.Threshold.rawValue: "invalid level"];
    
    // Execute & validate
    XCTAssertThrows { try ConsoleAppender(dictionary, availableFormatters: []) };
  }
  
  func testCreatingAppenderFromDictionaryWithThresholdUsesSpecifiedValue() {
    let dictionary = [ConsoleAppender.DictionaryKey.Identifier.rawValue: "testAppender",
      ConsoleAppender.DictionaryKey.Threshold.rawValue: LogLevel.Info.description];
    
    // Execute
    let appender = try! ConsoleAppender(dictionary, availableFormatters:[]);
    
    // Validate
    XCTAssertEqual(appender.thresholdLevel, LogLevel.Info);
  }
  
  func testCreatingAppenderFromDictionaryWithNoErrorThresholdUsesNilErrorThresholdByDefault() {
    let dictionary = [ConsoleAppender.DictionaryKey.Identifier.rawValue: "testAppender"];
    
    // Execute
    let appender = try! ConsoleAppender(dictionary, availableFormatters: []);
    
    // Validate
    XCTAssert(appender.errorThresholdLevel == nil);
  }
  
  func testCreatingAppenderFromDictionaryWithInvalidErrorThresholdThrowsError() {
    let dictionary = [ConsoleAppender.DictionaryKey.Identifier.rawValue: "testAppender",
      ConsoleAppender.DictionaryKey.ErrorThreshold.rawValue: "invalid level"];
    
    // Execute & validate
    XCTAssertThrows { try ConsoleAppender(dictionary, availableFormatters: []) };
  }
  
  func testCreatingAppenderFromDictionaryWithErrorThresholdUsesSpecifiedValue() {
    let dictionary = [ConsoleAppender.DictionaryKey.Identifier.rawValue: "testAppender",
      ConsoleAppender.DictionaryKey.ErrorThreshold.rawValue: LogLevel.Info.description];
    
    // Execute
    let appender = try! ConsoleAppender(dictionary, availableFormatters: []);
    
    // Validate
    XCTAssertEqual(appender.errorThresholdLevel!, LogLevel.Info);
  }
  
  func testCreatingAppenderFomDictionaryWithNonExistingFormatterIdThrowsError() {
    let dictionary = [ConsoleAppender.DictionaryKey.Identifier.rawValue: "testAppender",
      Appender.DictionaryKey.FormatterId.rawValue: "not existing id"];
    
    XCTAssertThrows { try ConsoleAppender(dictionary, availableFormatters: []) };
  }
  
  func testCreatingAppenderFomDictionaryWithExistingFormatterIdUsesIt() {
    let formatter = try! PatternFormatter(identifier: "formatterId", pattern: "test pattern");
    let dictionary = [ConsoleAppender.DictionaryKey.Identifier.rawValue: "testAppender",
      Appender.DictionaryKey.FormatterId.rawValue: "formatterId"];
    
    // Execute
    let appender = try! ConsoleAppender(dictionary, availableFormatters: [formatter]);
    
    // Validate
    XCTAssertEqual((appender.formatter?.identifier)!, formatter.identifier);
  }
  
  private func getFileHandleContentAsString(fileHandle: NSFileHandle) -> String? {
    let expectation = expectationWithDescription("filHandle content received");
    var stringContent: String?;
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) { () -> Void in
      let data = fileHandle.availableData;
      stringContent = NSString(data: data, encoding: NSUTF8StringEncoding) as? String;
      
      expectation.fulfill();
    }
    
    waitForExpectationsWithTimeout(1, handler: nil);
    return stringContent;
  }
}
