//
//  Array+utilitiesTests.swift
//  Log4swift
//
//  Created by dxo on 01/07/15.
//  Copyright © 2015 jerome. All rights reserved.
//

import XCTest

class ArrayUtilitiesTests: XCTestCase {

  func testFindReturnsFirstItemMatchingFilter() {
    let var1 = "ping1";
    let var2 = "pong";
    let var3 = "ping2";
    
    let array = [var1, var2, var3];
    
    // Execute
    let foundItem = array.find{ $0.hasPrefix("ping") };
    
    // Validate
    XCTAssertTrue(foundItem == var1);
  }

  func testFindReturnsNilIfItemIsNotFound() {
    let var1 = "ping";
    let var2 = "pong";
    let var3 = "p1ng";
    
    let array = [var1, var2, var3];
    
    // Execute
    let foundItem = array.find{ $0 == "notExisting" };
    
    // Validate
    XCTAssert(foundItem == nil);
  }

}
