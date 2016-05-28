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
    let formatter = try! PatternFormatter(identifier:"testFormatter", pattern: "[%l][%n][%d] %m")
    let info: LogInfoDictionary = [
      LogInfoKeys.LoggerName: "nameOfTheLogger",
      LogInfoKeys.LogLevel: LogLevel.Info
    ]
    
    self.measureBlock() {
      for _ in 1...10000 {
        formatter.format("Log message", info: info)
      }
    }
  }
  
  func testStrftimeDateFormatterPerformance() {
    let formatter = try! PatternFormatter(identifier:"testFormatter", pattern: "%d{'format':'%d.%m.%y %k:%M:%s'}")
    let info: LogInfoDictionary = [
      LogInfoKeys.LoggerName: "nameOfTheLogger",
      LogInfoKeys.LogLevel: LogLevel.Info
    ]
    
    self.measureBlock() {
      for _ in 1...10000 {
        formatter.format("Log message", info: info)
      }
    }
  }
  
  func testStrftimeDateFormatterRealWorldPerformance() {
    let formatter = try! PatternFormatter(identifier:"testFormatter", pattern: "%d{'format':'%y-%m-%d %k:%M:%s'} [%l{'padding':'-5'}][%n][%f:%L][%M] %m")
    let info: LogInfoDictionary = [
      LogInfoKeys.LoggerName: "testName",
      LogInfoKeys.LogLevel: LogLevel.Info,
      LogInfoKeys.FileName: "/Users/test/Swift/test.swift",
      LogInfoKeys.FileLine: 42,
      LogInfoKeys.Function: "testFunction",
      LogInfoKeys.Timestamp: 123456789.876
    ]
    let x = Int(10)
    self.measureBlock() {
      for _ in 1...10000 {
        formatter.format("Log message", info: info)
      }
    }
  }
  
  func testCocoaDateFormatterPerformance() {
    let formatter = try! PatternFormatter(identifier:"testFormatter", pattern: "%D{'format':'dd.MM.yyyy HH:mm:ss.SSS'}")
    let info: LogInfoDictionary = [
      LogInfoKeys.LoggerName: "nameOfTheLogger",
      LogInfoKeys.LogLevel: LogLevel.Info
    ]
    
    self.measureBlock() {
      for _ in 1...10000 {
        formatter.format("Log message", info: info)
      }
    }
  }
  
  func testCocoaDateFormatterRealWorldPerformance() {
    let formatter = try! PatternFormatter(identifier:"testFormatter", pattern: "%D{'format':'yyyy-MM-dd HH:mm:ss.SSS'} [%l{'padding':'-5'}][%n][%f:%L][%M] %m")
    let info: LogInfoDictionary = [
      LogInfoKeys.LoggerName: "testName",
      LogInfoKeys.LogLevel: LogLevel.Info,
      LogInfoKeys.FileName: "/Users/test/Swift/test.swift",
      LogInfoKeys.FileLine: 42,
      LogInfoKeys.Function: "testFunction",
      LogInfoKeys.Timestamp: 123456789.876
    ]
    
    self.measureBlock() {
      for _ in 1...10000 {
        formatter.format("Log message", info: info)
      }
    }
  }
  
}
