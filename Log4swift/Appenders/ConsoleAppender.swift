//
//  ConsoleAppender.swift
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
ConsoleAppender will print the log to stdout or stderr depending on thresholds and levels.
* If general threshold is reached but error threshold is undefined or not reached, log will be printed to stdout
* If both general and error threshold are reached, log will be printed to stderr
*/
public class ConsoleAppender: Appender {
  public enum DictionaryKey: String {
    case ErrorThreshold = "ErrorThreshold"
  };
  
  var errorThresholdLevel: LogLevel? = .Error;
  
  public required init(_ identifier: String) {
    super.init(identifier);
  }
  
  public override func updateWithDictionary(dictionary: Dictionary<String, AnyObject>, availableFormatters: Array<Formatter>) throws {

    try super.updateWithDictionary(dictionary, availableFormatters: availableFormatters);

    if let safeErrorThresholdString = (dictionary[DictionaryKey.ErrorThreshold.rawValue] as? String) {
      if let safeErrorThreshold = LogLevel(safeErrorThresholdString) {
        errorThresholdLevel = safeErrorThreshold;
      } else {
        throw Error.InvalidOrMissingParameterException(parameterName: DictionaryKey.ErrorThreshold.rawValue);
      }
    } else {
      errorThresholdLevel = nil;
    }
  }
  
  override func performLog(log: String, level: LogLevel) {
    var destinationFile = stdout;
    
    if let errorThresholdLevel = self.errorThresholdLevel {
      if(level.rawValue >= errorThresholdLevel.rawValue) {
        destinationFile  = stderr;
      }
    }
    fputs(strdup(log + "\n"), destinationFile);
  }
}
