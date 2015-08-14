//
//  LogLevel.swift
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

import Foundation

/**
Log level defines the importance of the log : is it just a debug log, an informational notice, or an error.
Order of the levels is :

Debug < Info < Warning < Error < Fatal
*/
@objc public enum LogLevel: Int, CustomStringConvertible {
  
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
