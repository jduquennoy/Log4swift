//
//  String+utilities.swift
//  log4swift
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
}

extension String : CustomStringConvertible {
  /// Returns the string itself (needed to conform to the CustomStringConvertible protocol)
  public var description: String {
    get {return self;}
  }
}