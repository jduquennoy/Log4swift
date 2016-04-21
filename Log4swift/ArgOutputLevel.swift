//
//  ArgOutputLevel.swift
//  log4swift
//
//  Created by Markus Arndt on 20/04/2016.
//  Copyright © 2016 Jérôme Duquennoy & Markus Arndt. All rights reserved.
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

import Foundation

/**
Argument output level defines how arguments are logged: are arguments logged at all, just the value or the value with its type.
Order of the levels is :

Off < ValueOnly < ValueWithType
*/
@objc public enum ArgOutputLevel: Int, CustomStringConvertible {
  
  case Off = 0
  case ValueOnly = 1
  case ValueWithType = 2
  
  /// Converts a string to a argument output level if possible.
  /// This initializer is not case sensitive
  public init?(_ stringValue: String) {
    switch(stringValue.lowercaseString) {
    case ArgOutputLevel.Off.description.lowercaseString:
      self = .Off
    case ArgOutputLevel.ValueOnly.description.lowercaseString:
      self = .ValueOnly
    case ArgOutputLevel.ValueWithType.description.lowercaseString:
      self = .ValueWithType
    default:
      return nil
    }
  }
  
  /// Returns a human readable representation of the argument output level.
  public var description : String {
    get {
      switch(self) {
      case .Off:
        return "Off"
      case .ValueOnly:
        return "ValueOnly"
      case .ValueWithType:
        return "ValueWithType"
      }
    }
  }
}
