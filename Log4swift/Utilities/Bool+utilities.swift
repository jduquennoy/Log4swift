//
//  Bool.utilities.swift
//  Log4swift
//
//  Created by Jérôme Duquennoy on 14/06/2015.
//  Copyright © 2015 jerome. All rights reserved.
//
// Log4swift is free software: you can redistribute it and/or modify
// it under the terms of the GNU Lesser General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// Log4swift is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU Lesser General Public License for more details.
//
// You should have received a copy of the GNU Lesser General Public License
// along with Foobar. If not, see <http://www.gnu.org/licenses/>.
//

/**
Extends Bool to add the ability to initialize with a string value.
*/
extension Bool {
  /// Returns true if the value is "true" or "yes" (case insensitive compare).  
  /// This initializer accepts an optional string, and will return false if the optional is not set.
  public init(_ stringValue: String?) {
    if let stringValue = stringValue {
      switch(stringValue.lowercaseString) {
      case "true", "yes":
        self = true;
      default:
        self = false;
      }
    } else {
      self = false;
    }
  }
}
