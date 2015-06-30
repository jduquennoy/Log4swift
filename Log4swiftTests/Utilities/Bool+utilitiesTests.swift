//
//  Bool+utilitiesTests.swift
//  Log4swift
//
//  Created by jduquennoy on 30/06/2015.
//  Copyright © 2015 jerome. All rights reserved.
//

import XCTest
import Log4swift

class BoolUtilitiesTests: XCTestCase {

  func testBoolParsesYesOrTrueAsTrueCaseInsensitively() {
    XCTAssertTrue(Bool("yes"));
    XCTAssertTrue(Bool("YES"));
    XCTAssertTrue(Bool("true"));
    XCTAssertTrue(Bool("TruE"));
  }
  
  func testBoolParsesNoOrFalseAsFalseCaseInsensitively() {
    XCTAssertFalse(Bool("no"));
    XCTAssertFalse(Bool("nO"));
    XCTAssertFalse(Bool("false"));
    XCTAssertFalse(Bool("fALse"));
  }
  
  func testBoolParsesNilStringAsFalse() {
    XCTAssertFalse(Bool(nil as String?));
  }
  
}
