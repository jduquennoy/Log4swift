//
//  FileAppenderTests.swift
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

enum TestError : ErrorType {
  case TemporaryFileError
}

class FileAppenderTests: XCTestCase {
  
  override func setUp() {
    super.setUp()
    // Put setup code here. This method is called before the invocation of each test method in the class.
  }
  
  override func tearDown() {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    super.tearDown()
  }
  
  func testFileAppenderExpandsTildeWhenInitializing() {
    let filePath = "~/log/logFile.log";
    
    // Execute
    let fileAppender = FileAppender(identifier: "test.appender", filePath: filePath);
    
    // Validate
    XCTAssertEqual(fileAppender.filePath, filePath.stringByExpandingTildeInPath);
  }

  func testFileAppenderExpandsTildeWhenSettingFilePath() {
    let filePath = "~/log/logFile.log";
    let fileAppender = FileAppender(identifier: "test.appender", filePath: "/dummy/path");
    
    // Execute
    fileAppender.filePath = filePath
    
    // Validate
    XCTAssertEqual(fileAppender.filePath, filePath.stringByExpandingTildeInPath);
  }
  
  func testFileAppenderCreatesFileIfItDoesNotExist()  {
    do {
      let tempFilePath = try self.createTemporaryFileUrl();
      let fileAppender = FileAppender(identifier: "test.appender", filePath: tempFilePath);
      let logContent = "ping";
      defer {
        unlink(tempFilePath.fileSystemRepresentation());
      }
      
      // Execute
      fileAppender.log(logContent, level: LogLevel.Debug, info: LogInfoDictionary());
      
      // Validate
      let fileContent = try NSString(contentsOfFile: tempFilePath, encoding: NSUTF8StringEncoding);
      XCTAssert(fileContent.length > 0, "Content of log file should not be empty");
    } catch let error {
      XCTAssert(false, "Error in test : \(error)");
    }
    
  }
  
  func testFileAppenderReCreatesFileIfItDeletedAfterFirstLog()  {
    do {
      let tempFilePath = try self.createTemporaryFileUrl();
      let fileAppender = FileAppender(identifier: "test.appender", filePath: tempFilePath);
      let logContent = "ping";
      defer {
        unlink(tempFilePath.fileSystemRepresentation());
      }
      
      fileAppender.log(logContent, level: LogLevel.Debug, info: LogInfoDictionary());
      unlink(tempFilePath.fileSystemRepresentation());
      
      // Execute
      fileAppender.log(logContent, level: LogLevel.Debug, info: LogInfoDictionary());
      
      // Validate
      let fileContent = try NSString(contentsOfFile: tempFilePath, encoding: NSUTF8StringEncoding);
      XCTAssert(fileContent.length > 0, "Content of log file should not be empty");
    } catch let error {
      XCTAssert(false, "Error in test : \(error)");
    }
  }
  
  func testFileAppenderAddsEndOfLineToLogsIfNotPresentAtEndOfMessage()  {
    do {
      let tempFilePath = try self.createTemporaryFileUrl();
      let fileAppender = FileAppender(identifier: "test.appender", filePath: tempFilePath);
      let logContent = "ping";
      defer {
        unlink(tempFilePath.fileSystemRepresentation());
      }
      
      fileAppender.log(logContent, level: LogLevel.Debug, info: LogInfoDictionary());
      unlink(tempFilePath.fileSystemRepresentation());
      
      // Execute
      fileAppender.log(logContent, level: LogLevel.Debug, info: LogInfoDictionary());
      
      // Validate
      let fileContent = try NSString(contentsOfFile: tempFilePath, encoding: NSUTF8StringEncoding);
      XCTAssertEqual(fileContent, logContent + "\n", "Content of log file does not match expectation");
    } catch let error {
      XCTAssert(false, "Error in test : \(error)");
    }
  }
  
  func testFileAppenderDoesNotAddEndOfLineToLogsIfAlreadyPresent()  {
    do {
      let tempFilePath = try self.createTemporaryFileUrl();
      let fileAppender = FileAppender(identifier: "test.appender", filePath: tempFilePath);
      let logContent = "ping\n";
      defer {
        unlink(tempFilePath.fileSystemRepresentation());
      }
      
      fileAppender.log(logContent, level: LogLevel.Debug, info: LogInfoDictionary());
      unlink(tempFilePath.fileSystemRepresentation());
      
      // Execute
      fileAppender.log(logContent, level: LogLevel.Debug, info: LogInfoDictionary());
      
      // Validate
      let fileContent = try NSString(contentsOfFile: tempFilePath, encoding: NSUTF8StringEncoding);
      XCTAssertEqual(fileContent, logContent, "Content of log file does not match expectation");
    } catch let error {
      XCTAssert(false, "Error in test : \(error)");
    }
  }
  
  func testLogsAreRedirectedToNewLogFileIfPathIsChanged()  {
    do {
      let tempFilePath = try self.createTemporaryFileUrl();
      let tempFilePath2 = try self.createTemporaryFileUrl();
      let fileAppender = FileAppender(identifier: "test.appender", filePath: tempFilePath);
      let logContent1 = "ping1";
      let logContent2 = "ping2";
      defer {
        unlink(tempFilePath.fileSystemRepresentation());
        unlink(tempFilePath2.fileSystemRepresentation());
      }
      
      fileAppender.log(logContent1, level: LogLevel.Debug, info: LogInfoDictionary());
      
      // Execute
      fileAppender.filePath = tempFilePath2;
      fileAppender.log(logContent2, level: LogLevel.Debug, info: LogInfoDictionary());
      
      
      // Validate
      let fileContent2 = try NSString(contentsOfFile: tempFilePath2, encoding: NSUTF8StringEncoding);
      XCTAssertEqual(fileContent2, logContent2 + "\n", "Content of second log file does not match expectation");
    } catch let error {
      XCTAssert(false, "Error in test : \(error)");
    }
  }
  
  func testUpdatingAppenderFromDictionaryWithNoIdentifierThrowsError() {
    let dictionary = Dictionary<String, AnyObject>();
    let appender = FileAppender("testAppender");
    
    XCTAssertThrows { try appender.updateWithDictionary(dictionary, availableFormatters:[]) };
  }
  
  func testUpdatingAppenderFromDictionaryWithNoFilePathThrowsError() {
    let dictionary = Dictionary<String, AnyObject>();
    let appender = FileAppender("testAppender");
    
    // Execute & Analyze
    XCTAssertThrows { try appender.updateWithDictionary(dictionary, availableFormatters:[]) };
  }
  
  func testUpdatingAppenderFromDictionaryWithFilePathUsesProvidedValue() {
    let dictionary = [FileAppender.DictionaryKey.FilePath.rawValue: "/log/file/path.log"];
    let appender = FileAppender("testAppender");
    
    // Execute
    try! appender.updateWithDictionary(dictionary, availableFormatters:[]);
    
    // Analyze
    XCTAssertEqual(appender.filePath,  "/log/file/path.log");
  }
  
  func testUpdatingAppenderFomDictionaryWithNonExistingFormatterIdThrowsError() {
    let dictionary = [FileAppender.DictionaryKey.FilePath.rawValue: "/log/file/path.log",
      Appender.DictionaryKey.FormatterId.rawValue: "not existing id"];
    let appender = FileAppender("testAppender");
    
    XCTAssertThrows { try appender.updateWithDictionary(dictionary, availableFormatters: []) };
  }
  
  func testUpdatingAppenderFomDictionaryWithExistingFormatterIdUsesIt() {
    let formatter = try! PatternFormatter(identifier: "formatterId", pattern: "test pattern");
    let dictionary = [FileAppender.DictionaryKey.FilePath.rawValue: "/log/file/path.log",
      Appender.DictionaryKey.FormatterId.rawValue: "formatterId"];
    let appender = FileAppender("testAppender");
    
    // Execute
    try! appender.updateWithDictionary(dictionary, availableFormatters: [formatter]);
    
    // Validate
    XCTAssertEqual((appender.formatter?.identifier)!, formatter.identifier);
  }
  
  func testFileAppenderPerformanceWhenFileIsNotDeleted() {
    do {
      let tempFilePath = try self.createTemporaryFileUrl();
      let fileAppender = FileAppender(identifier: "test.appender", filePath: tempFilePath);
      defer {
        unlink(tempFilePath.fileSystemRepresentation());
      }
      
      measureBlock { () -> Void in
        for _ in 1...1000 {
          fileAppender.log("This is a test log", level: LogLevel.Debug, info: LogInfoDictionary());
        }
      }
    } catch let error {
      XCTAssert(false, "Error in test : \(error)");
    }
  }
  
  private func createTemporaryFileUrl() throws -> String {
    let temporaryFilePath = NSTemporaryDirectory().stringByAppendingPathComponent(NSUUID().UUIDString + ".log");
    return temporaryFilePath;
  }
}
