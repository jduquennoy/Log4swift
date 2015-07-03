//
//  LogLevel.swift
//  log4swift
//
//  Created by Jérôme Duquennoy on 14/06/2015.
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
Log level defines the importance of the log : is it just a debug log, an informational notice, or an error.
Order of the levels is :

Debug < Info < Warning < Error < Fatal
*/
public enum LogLevel: Int, CustomStringConvertible {
  
  case Debug = 0
  case Info = 1
  case Warning = 2
  case Error = 3
  case Fatal = 4
  
  /// Converts a string to a log level if possible.
  /// This initializer is not case sensitive
  public init?(_ stringValue: String) {
    switch(stringValue.lowercaseString) {
    case LogLevel.Debug.description.lowercaseString:
      self = .Debug;
    case LogLevel.Info.description.lowercaseString:
      self = .Info;
    case LogLevel.Warning.description.lowercaseString:
      self = .Warning;
    case LogLevel.Error.description.lowercaseString:
      self = .Error;
    case LogLevel.Fatal.description.lowercaseString:
      self = .Fatal;
    default:
      return nil;
    }
  }
  
  /// Returns a human readable representation of the log level.
  public var description : String {
    get {
      switch(self) {
      case .Debug:
        return "Debug";
      case .Info:
        return "Info";
      case .Warning:
        return "Warning";
      case .Error:
        return "Error";
      case .Fatal:
        return "Fatal";
      }
    }
  }
}
