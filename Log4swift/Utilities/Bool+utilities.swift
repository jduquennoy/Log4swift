//
//  Bool.utilities.swift
//  Log4swift
//
//  Created by Jérôme Duquennoy on 14/06/2015.
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

/**
Extends Bool to add the ability to initialize with a string value.
*/
extension Bool {
  /// Returns true if the value is "true" or "yes" (case insensitive compare).  
  /// This initializer accepts an optional string, and will return false if the optional is not set.
  public init(_ stringValue: String?) {
    if let stringValue = stringValue {
      switch(stringValue.lowercased()) {
      case "true", "yes":
        self = true
      default:
        self = false
      }
    } else {
      self = false
    }
  }
}
