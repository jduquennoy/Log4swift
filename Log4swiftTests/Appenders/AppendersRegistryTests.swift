//
//  AppendersRegistry.swift
//  log4swiftTests
//
//  Created by Jérome Duquennoy on 29/03/2020.
//  Copyright © 2020 jerome. All rights reserved.
//

import XCTest
@testable import Log4swift

class AppendersRegistryTests: XCTestCase {
  
  func testRegistryKnowsIncludedAppendersByDefault() {
    XCTAssertNotNil(AppendersRegistry.appenderForClassName("StdOutAppender"))
    XCTAssertNotNil(AppendersRegistry.appenderForClassName("FileAppender"))
    XCTAssertNotNil(AppendersRegistry.appenderForClassName("NSLoggerAppender"))
    XCTAssertNotNil(AppendersRegistry.appenderForClassName("NSLogAppender"))
    XCTAssertNotNil(AppendersRegistry.appenderForClassName("ASLAppender"))
    XCTAssertNotNil(AppendersRegistry.appenderForClassName("SystemAppender"))
    XCTAssertNotNil(AppendersRegistry.appenderForClassName("AppleUnifiedLoggerAppender"))
  }
  
  func testRegistryKnowsCustomAppendersOnceRegistered() {
    AppendersRegistry.registerAppender(MemoryAppender.self)
    
    XCTAssertNotNil(AppendersRegistry.appenderForClassName("MemoryAppender"))
  }
  
  func testRegistryAppendersMatchingIsCaseInsensitive() {
    XCTAssertNotNil(AppendersRegistry.appenderForClassName("stDoutapPEnder"))
    XCTAssert(
      AppendersRegistry.appenderForClassName("StdOutAppender") === AppendersRegistry.appenderForClassName("stDoutapPEnder")
    )
  }
}
