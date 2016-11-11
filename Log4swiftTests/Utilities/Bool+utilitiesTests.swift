//
//  Bool+utilitiesTests.swift
//  Log4swift
//
//  Created by jduquennoy on 30/06/2015.
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
import Log4swift

class BoolUtilitiesTests: XCTestCase {

  func testBoolParsesYesOrTrueAsTrueCaseInsensitively() {
    XCTAssertTrue(Bool("yes"))
    XCTAssertTrue(Bool("YES"))
    XCTAssertTrue(Bool("true"))
    XCTAssertTrue(Bool("TruE"))
  }
  
  func testBoolParsesNoOrFalseAsFalseCaseInsensitively() {
    XCTAssertFalse(Bool("no"))
    XCTAssertFalse(Bool("nO"))
    XCTAssertFalse(Bool("false"))
    XCTAssertFalse(Bool("fALse"))
  }
  
  func testBoolParsesNilStringAsFalse() {
    XCTAssertFalse(Bool((nil as String?)))
  }
  
}
