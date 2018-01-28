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

extension StringProtocol {
  /// Return a new string by removing everything after the last occurence of the provided marker and including the marker.  
  /// If the marker is not found, an empty string is returned.
  public func stringByRemovingLastComponent(withDelimiter delimiter: String) -> SubSequence? {
    guard let markerIndex = self.reversed().index(of: Character(delimiter)) else { return nil }
    let endIndex = self.index(markerIndex.base, offsetBy: -1)

    let result = self[self.startIndex..<endIndex]
    return result
  }

}

extension String {
  public func format(args: [CVarArg]) -> String {
    guard args.count > 0 else {
      return self
    }
    
    return withVaList(args) { (argsListPointer) in
      NSString(format: self, arguments: argsListPointer) as String
    }
  }
  
  /// Pads string left or right to a certain width.
  ///
  /// :parameter: width: The width of the final string.  Positive values left-justify the value,
  ///                    negative values right-justify it.  Default value is `0` and causes no
  ///                    padding to occur.  If the string is longer than the specified width,
  ///                    it will be truncated.
  ///
  /// :returns: The padded string
  public func pad(toWidth width: Int) -> String {
		//    var str = self as NSString
		var paddedString: String = self
		
    if width == 0 {
      return self
    }
    
    if self.count > abs(width) {
      if width < 0 {
				paddedString = String(self.suffix(abs(width)))
      } else {
				paddedString = String(self.prefix(width))
      }
    }

    if self.count < abs(width) {
      if width < 0 {
				paddedString = " ".padding(toLength: abs(width) - self.count, withPad: " ", startingAt: 0) + self
      } else {
        paddedString = self.padding(toLength: width, withPad: " ", startingAt: 0)
      }
    }
    
    return paddedString
  }


  /// Returns a dictionary if String contains proper JSON format for a single, non-nested object; a simple dictionary.
  /// Keys and values should be surrounded with single or double quotes.
  /// Ex: {"name":"value", 'name':'value'}
  public func toDictionary() throws -> [String:AnyObject] {
    var dict: [String:AnyObject] = Dictionary()
    let s = (self as NSString).replacingOccurrences(of: "'", with: "\"")

		if let data = s.data(using: String.Encoding.utf8) {
      do {
				dict = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.allowFragments) as! [String:AnyObject]
      }
    }

    return dict
  }
}
