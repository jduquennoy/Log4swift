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
public class Appender {
  public enum DictionaryKey: String {
    case Identifier = "Identifier"
    case Threshold = "Threshold"
    case FormatterId = "FormatterId"
  }
  
  public enum Error : ErrorType {
    // init with directory errors
    case InvalidOrMissingParameterException(parameterName: String)
  };
  
  let identifier: String;
  public var thresholdLevel = LogLevel.Debug;
  public var formatter: Formatter?;
  
  init(_ identifier: String) {
    self.identifier = identifier;
  }
  
  init(_ dictionary: Dictionary<String, AnyObject>, availableFormatters: Array<Formatter>) throws {
    var errorToThrow: Error? = nil;
    
    if let safeIdentifier = (dictionary[DictionaryKey.Identifier.rawValue] as? String) {
      identifier = safeIdentifier;
    } else {
      identifier = "placeholder";
      errorToThrow = Error.InvalidOrMissingParameterException(parameterName: DictionaryKey.Identifier.rawValue);
    }
    
    if let safeThresholdString = (dictionary[DictionaryKey.Threshold.rawValue] as? String) {
      if let safeThreshold = LogLevelFromString(safeThresholdString) {
        thresholdLevel = safeThreshold;
      } else {
        errorToThrow = Error.InvalidOrMissingParameterException(parameterName: DictionaryKey.Threshold.rawValue);
      }
    }
    
    if let safeFormatterId = (dictionary[DictionaryKey.FormatterId.rawValue] as? String) {
      if let formatter = availableFormatters.find({ $0.identifier == safeFormatterId }) {
        self.formatter = formatter;
      } else {
        throw Error.InvalidOrMissingParameterException(parameterName: DictionaryKey.FormatterId.rawValue);
      }
    }
    
    if let errorToThrow = errorToThrow {
      throw errorToThrow;
    }
  }
  
  func performLog(log: String, level: LogLevel) {
    // To be overriden by subclasses
  }
  
  final func log(log: String, level: LogLevel, info: FormatterInfoDictionary) {
    if(level.rawValue >= self.thresholdLevel.rawValue) {
      let logMessage: String;
      
      if let formatter = self.formatter {
        logMessage = formatter.format(log, info: info)
      } else {
        logMessage = log;
      }
      
      self.performLog(logMessage, level: level);
    }
  }
}