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
  var errorThresholdLevel: LogLevel? = .Error;
  
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
