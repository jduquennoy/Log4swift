//
//  PerformanceTests.swift
//  Log4swift
//
//  Created by Jérôme Duquennoy on 15/07/2015.
//  Copyright © 2015 jerome. All rights reserved.
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
import Log4swift

class PerformanceTests: XCTestCase {

  func testNSLogPerformanceTest() {
    // This is an example of a performance test case.
    self.measureBlock() {
      for _ in 0...5000 {
        NSLog("This is a simple log");
      }
    }
  }
  
  func testConsoleLoggerWithFormatterPerformanceTest() {
    let formatter = try! PatternFormatter(identifier: "formatter", pattern: "%d %m");
    let consoleAppender = ConsoleAppender("appender");
    consoleAppender.errorThresholdLevel = .Debug;
    consoleAppender.formatter = formatter;
    let logger = Logger(identifier: "");
    logger.appenders = [consoleAppender];
    
    // This is an example of a performance test case.
    self.measureBlock() {
      for _ in 0...5000 {
        logger.error("This is a simple log");
      }
    }
  }
  
  func testFileLoggerWithFormatterPerformanceTest() {
    let formatter = try! PatternFormatter(identifier: "formatter", pattern: "%d %m");
    let tempFilePath = try! self.createTemporaryFileUrl();
    let fileAppender = FileAppender(identifier: "test.appender", filePath: tempFilePath);
    fileAppender.formatter = formatter;
    let logger = Logger(identifier: "");
    logger.appenders = [fileAppender];
    
    // This is an example of a performance test case.
    self.measureBlock() {
      for _ in 0...5000 {
        logger.error("This is a simple log");
      }
    }

    unlink(tempFilePath.fileSystemRepresentation());
  }
  
  private func createTemporaryFileUrl() throws -> String {
    let temporaryFilePath = NSTemporaryDirectory().stringByAppendingPathComponent(NSUUID().UUIDString + ".log");
    return temporaryFilePath;
  }

}
