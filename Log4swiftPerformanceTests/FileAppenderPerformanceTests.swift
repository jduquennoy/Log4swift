//
//  FileAppenderPerformanceTests.swift
//  log4swiftPerformanceTests
//
//  Created by Jérôme Duquennoy on 07/08/2018.
//  Copyright © 2018 jerome. All rights reserved.
//

import XCTest
import Log4swift

class FileAppenderPerformanceTests: XCTestCase {
  var logFilePath: String = ""
  
  override func setUp() {
    XCTAssertNoThrow(
      self.logFilePath = try self.createTemporaryFilePath(fileExtension: "log")
    )
  }
  
  override func tearDown() {
    try! FileManager().removeItem(atPath: self.logFilePath)
  }
  
  
  func testFileAppenderPerformanceWhenFileIsNotDeleted() {
    do {
      let tempFilePath = try self.createTemporaryFilePath(fileExtension: "log")
      let fileAppender = FileAppender(identifier: "test.appender", filePath: tempFilePath)
      defer {
        unlink((tempFilePath as NSString).fileSystemRepresentation)
      }
      
      measure { () -> Void in
        for _ in 1...1000 {
          fileAppender.log("This is a test log", level: LogLevel.Debug, info: LogInfoDictionary())
        }
      }
    } catch let error {
      XCTAssert(false, "Error in test : \(error)")
    }
  }

  func testPerformanceWithoutRotation() throws {
    let appender = FileAppender(identifier: "testAppender", filePath: self.logFilePath)
    
    self.measure {
      for _ in 1...10_000 {
        appender.performLog("This is a test log string", level: .Info, info: LogInfoDictionary())
      }
    }
  }

  func testPerformanceWithDateRotationTrigger() throws {
    let appender = FileAppender(identifier: "testAppender", filePath: self.logFilePath, maxFileAge: 60*60)
    
    self.measure {
      for _ in 1...10_000 {
        appender.performLog("This is a test log string", level: .Info, info: LogInfoDictionary())
      }
    }
  }

  func testPerformanceWithSizeRotationTrigger() throws {
    let appender = FileAppender(identifier: "testAppender", filePath: self.logFilePath, maxFileSize: 1024 * 1024)
    
    self.measure {
      for _ in 1...10_000 {
        appender.performLog("This is a test log string", level: .Info, info: LogInfoDictionary())
      }
    }
  }

}
