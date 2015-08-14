//
//  XCTestCase+noThrow.swift
//  Log4swift
//
//  Created by jerome on 27/06/2015.
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