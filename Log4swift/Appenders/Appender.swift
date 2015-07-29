//
//  Appender.swift
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
Appenders are responsible for sending logs to heir destination.
This class is the base class, from which all appenders should inherit.
*/
@objc public class Appender: NSObject {
  public enum DictionaryKey: String {
    case ThresholdLevel = "ThresholdLevel"
    case FormatterId = "FormatterId"
  }
  
  let identifier: String;
  public var thresholdLevel = LogLevel.Debug;
  public var formatter: Formatter?;
  
  public required init(_ identifier: String) {
    self.identifier = identifier;
  }
  
  internal func updateWithDictionary(dictionary: Dictionary<String, AnyObject>, availableFormatters: Array<Formatter>) throws {
     if let safeThresholdString = (dictionary[DictionaryKey.ThresholdLevel.rawValue] as? String) {
      if let safeThreshold = LogLevel(safeThresholdString) {
        thresholdLevel = safeThreshold;
      } else {
        throw Error.InvalidOrMissingParameterException(parameterName: DictionaryKey.ThresholdLevel.rawValue);
      }
    }
    
    if let safeFormatterId = (dictionary[DictionaryKey.FormatterId.rawValue] as? String) {
      if let formatter = availableFormatters.find({ $0.identifier == safeFormatterId }) {
        self.formatter = formatter;
      } else {
        throw Error.InvalidOrMissingParameterException(parameterName: DictionaryKey.FormatterId.rawValue);
      }
    }
  }
  
  func performLog(log: String, level: LogLevel, info: LogInfoDictionary) {
    // To be overriden by subclasses
  }
  
  final func log(log: String, level: LogLevel, info: LogInfoDictionary) {
    if(level.rawValue >= self.thresholdLevel.rawValue) {
      let logMessage: String;
      
      if let formatter = self.formatter {
        logMessage = formatter.format(log, info: info)
      } else {
        logMessage = log;
      }
      
      self.performLog(logMessage, level: level, info: info);
    }
  }
}