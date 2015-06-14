//
//  Appender.swift
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

/**
Appenders are responsible for sending logs to heir destination.  
This class is the base class, from which all appenders should inherit.
*/
public class Appender {
  var thresholdLevel = LogLevel.debug;
  
  public init() {}
  
  func performLog(log: String, level: LogLevel) {
    // To be overriden by subclasses
  }
  
  final func log(log: String, level: LogLevel) {
    if(level.rawValue >= self.thresholdLevel.rawValue) {
      self.performLog(log, level: level);
    }
  }
}