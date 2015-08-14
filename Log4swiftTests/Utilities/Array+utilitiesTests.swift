//
//  Array+utilitiesTests.swift
//  Log4swift
//
//  Created by dxo on 01/07/15.
//  Copyright © 2015 Jérôme Duquennoy. All rights reserved.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
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
