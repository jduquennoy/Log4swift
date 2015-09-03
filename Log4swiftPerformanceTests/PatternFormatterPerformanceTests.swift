//
//  PatternFormatterPerformanceTests.swift
//  Log4swift
//
//  Created by Jérôme Duquennoy on 03/09/2015.
//  Copyright © 2015 jerome. All rights reserved.
//

import XCTest
import Log4swift

class PatternFormatterPerformanceTests: XCTestCase {
  
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
