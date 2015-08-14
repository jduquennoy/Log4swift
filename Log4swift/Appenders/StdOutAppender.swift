//
//  StdOutAppender.swift
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

/**
StdOutAppender will print the log to stdout or stderr depending on thresholds and levels.
* If general threshold is reached but error threshold is undefined or not reached, log will be printed to stdout
* If both general and error threshold are reached, log will be printed to stderr
*/
public class StdOutAppender: Appender {
  public enum DictionaryKey: String {
    case ErrorThreshold = "ErrorThresholdLevel"
  };
  
  public var errorThresholdLevel: LogLevel? = .Error;
  
  public required init(_ identifier: String) {
    super.init(identifier);
  }
  
  public override func updateWithDictionary(dictionary: Dictionary<String, AnyObject>, availableFormatters: Array<Formatter>) throws {

    try super.updateWithDictionary(dictionary, availableFormatters: availableFormatters);

    if let safeErrorThresholdString = (dictionary[DictionaryKey.ErrorThreshold.rawValue] as? String) {
      if let safeErrorThreshold = LogLevel(safeErrorThresholdString) {
        errorThresholdLevel = safeErrorThreshold;
      } else {
        throw InvalidOrMissingParameterException("Invalide '\(DictionaryKey.ErrorThreshold.rawValue)' value for console appender '\(self.identifier)'");
      }
    } else {
      errorThresholdLevel = nil;
    }
  }
  
  override func performLog(log: String, level: LogLevel, info: LogInfoDictionary) {
    var destinationFile = stdout;
    
    if let errorThresholdLevel = self.errorThresholdLevel {
      if(level.rawValue >= errorThresholdLevel.rawValue) {
        destinationFile  = stderr;
      }
    }
    fputs(strdup(log + "\n"), destinationFile);
  }
}
