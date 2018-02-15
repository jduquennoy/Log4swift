//
//  SubclassingTests.swift
//  Log4swift
//
//  Created by Igor Makarov on 03/01/2017.
//  Copyright © 2017 jerome. All rights reserved.
//

import XCTest
// do not import as @testable, we're testing subclassing from outside the module
import Log4swift


class DummyAppender: Log4swift.Appender {

  override func update(withDictionary dictionary: Dictionary<String, Any>, availableFormatters: Array<Log4swift.Formatter>) throws {
    try super.update(withDictionary: dictionary, availableFormatters: availableFormatters)

  }
  open override func performLog(_ log: String, level: LogLevel, info: LogInfoDictionary) {
    // no need to do anything, just an override
  }
}

class SubclassingTests: XCTestCase {
  func testSubclassing() {
    let dummyAppender = DummyAppender("dummy")
    XCTAssertNotNil(dummyAppender)
  }
}
