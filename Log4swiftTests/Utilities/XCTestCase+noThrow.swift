//
//  XCTestCase+noThrow.swift
//  Log4swift
//
//  Created by jerome on 27/06/2015.
//  Copyright © 2015 jerome. All rights reserved.
//

import XCTest

extension XCTestCase {

  func XCTAssertThrows(file: String = __FILE__, line: UInt = __LINE__, _ closure:() throws -> Void) {
    do {
      try closure();
      XCTFail("Closure did not throw an error", file: file, line: line);
    } catch {
      // expected, nothing to do
    }
  }
  
  func XCTAssertNoThrow<T>(file: String = __FILE__, line: UInt = __LINE__, _ closure:() throws -> T) -> T? {
    do {
      return try closure();
    } catch let error {
      XCTFail("Closure throw unexpected error \(error)", file: file, line: line);
    }
    return nil;
  }
  
}