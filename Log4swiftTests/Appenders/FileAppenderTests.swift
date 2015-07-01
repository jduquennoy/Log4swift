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
  
  func testFileAppenderCreatesFileIfItDoesNotExist()  {
    do {
      let tempFilePath = try self.createTemporaryFileUrl();
      let fileAppender = FileAppender(identifier: "test.appender", filePath: tempFilePath);
      let logContent = "ping";
      defer {
        unlink(tempFilePath.fileSystemRepresentation());
      }
      
      // Execute
      fileAppender.log(logContent, level: LogLevel.Debug, info: FormatterInfoDictionary());
      
      // Validate
      let fileContent = try NSString(contentsOfFile: tempFilePath, encoding: NSUTF8StringEncoding);
      XCTAssert(fileContent.length > 0, "Content of log file should not be empty")
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
      
      fileAppender.log(logContent, level: LogLevel.Debug, info: FormatterInfoDictionary());
      unlink(tempFilePath.fileSystemRepresentation());
      
      // Execute
      fileAppender.log(logContent, level: LogLevel.Debug, info: FormatterInfoDictionary());
      
      // Validate
      let fileContent = try NSString(contentsOfFile: tempFilePath, encoding: NSUTF8StringEncoding);
      XCTAssert(fileContent.length > 0, "Content of log file should not be empty")
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
      
      fileAppender.log(logContent, level: LogLevel.Debug, info: FormatterInfoDictionary());
      unlink(tempFilePath.fileSystemRepresentation());
      
      // Execute
      fileAppender.log(logContent, level: LogLevel.Debug, info: FormatterInfoDictionary());
      
      // Validate
      let fileContent = try NSString(contentsOfFile: tempFilePath, encoding: NSUTF8StringEncoding);
      XCTAssertEqual(fileContent, logContent + "\n", "Content of log file does not match expectation")
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
      
      fileAppender.log(logContent, level: LogLevel.Debug, info: FormatterInfoDictionary());
      unlink(tempFilePath.fileSystemRepresentation());
      
      // Execute
      fileAppender.log(logContent, level: LogLevel.Debug, info: FormatterInfoDictionary());

      // Validate
      let fileContent = try NSString(contentsOfFile: tempFilePath, encoding: NSUTF8StringEncoding);
      XCTAssertEqual(fileContent, logContent, "Content of log file does not match expectation")
    } catch let error {
      XCTAssert(false, "Error in test : \(error)");
    }
  }
  
  func testCreatingAppenderFromDictionaryWithNoIdentifierThrowsError() {
    let dictionary = Dictionary<String, AnyObject>();
    
    XCTAssertThrows({ try FileAppender(dictionary)});
  }
  
  func testCreatingAppenderFromDictionaryWithNoFilePathThrowsError() {
    let dictionary = [ConsoleAppender.DictionaryKey.Identifier.rawValue: "testAppender"];
    
    // Execute & Analyze
    XCTAssertThrows({ try FileAppender(dictionary) });
  }
  
  func testCreatingAppenderFromDictionaryWithFilePathUsesProvidedValue() {
    let dictionary = [ConsoleAppender.DictionaryKey.Identifier.rawValue: "testAppender",
      FileAppender.DictionaryKey.FilePath.rawValue: "/log/file/path.log"];
    
    // Execute
    let appender = try! FileAppender(dictionary);
    
    // Analyze
    XCTAssertEqual(appender.filePath,  "/log/file/path.log");
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
          fileAppender.log("This is a test log", level: LogLevel.Debug, info: FormatterInfoDictionary());
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
