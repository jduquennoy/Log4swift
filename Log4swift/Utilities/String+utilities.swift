//
//  String+utilities.swift
//  log4swift
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

extension String {
  /// Return a new string by removing everything after the last occurence of the provided marker and including the marker.  
  /// If the marker is not found, an empty string is returned.
  public func stringByRemovingLastComponentWithDelimiter(delimiter: String) -> String {
    let markerIndex = self.rangeOfString(delimiter, options: NSStringCompareOptions.BackwardsSearch, range: nil);
    let result: String;
    if let markerIndex = markerIndex {
      result = self.substringToIndex(markerIndex.startIndex);
    } else {
      result = "";
    }
    return result;
  }

  public func format(args: CVaListPointer) -> String {
    return NSString(format: self, arguments: args) as String
  }


  /// Pads string left or right to a certain width.
  ///
  /// - parameter width: The width of the final string.  Positive values left-justify the value,
  ///                    negative values right-justify it.  Default value is `0` and causes no
  ///                    padding to occur.  If the string is longer than the specified width,
  ///                    it will be truncated.
  ///
  /// - returns: The padded string
  func padtoWidth(width: Int = 0) -> String {
    var str = self as NSString
    
    if width == 0 {
      return self
    }
    
    if str.length > abs(width) {
      str = str.substringWithRange(NSRange(location: 0, length: abs(width)))
    }

    if str.length < abs(width) {
      if width < 0 {
        str = " ".stringByPaddingToLength(abs(width) - str.length, withString: " ", startingAtIndex: 0) + (str as String)
      } else {
        str = str.stringByPaddingToLength(width, withString: " ", startingAtIndex: 0)
      }
    }
    
    return str as String
  }
}


extension String : CustomStringConvertible {
  /// Returns the string itself (needed to conform to the CustomStringConvertible protocol)
  public var description: String {
    get {return self;}
  }
}