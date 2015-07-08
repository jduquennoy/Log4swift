//
//  Formatter.swift
//  Log4swift
//
//  Created by Jérôme Duquennoy on 18/06/2015.
//  Copyright © 2015 Jérôme Duquennoy. All rights reserved.
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
This protocol defines a formatter, that will format log messages on the fly.
*/
public protocol Formatter {
  /// A string identifier that should uniquely identify a formatter.
  var identifier: String { get };
  
  init (_ identifier: String);
  
  func updateWithDictionary(dictionary: Dictionary<String, AnyObject>) throws;
  
  /// Formats the given message, using the provided info dictionary.
  /// Info dictionary contains additional infos that can be rendered as a string and that can be used by matchers.
  func format(message: String, info: LogInfoDictionary) -> String;
}
