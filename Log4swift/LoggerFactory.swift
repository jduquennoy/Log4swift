//
//  LoggerFactory.swift
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
The logger factory is responsible for
* loading configuration from files or dictionaries
* holding the loggers and appenders
* matching UTI identifiers to loggers
*/
public class LoggerFactory {
  static public let sharedInstance = LoggerFactory();
  
  public let rootLogger = Logger();
  private var loggers = Dictionary<String, Logger>();
  
  // MARK: Configuration
  
  /// Reads a whole configuration from the given dictionary.  
  /// **Warning:** This will destroy all current loggers and appenders, replacing them by those found in that configuration.
  public func readConfiguration(configurationDictionary: Dictionary<String, AnyObject>) {
    // TODO
  }
  
  /// Adds the given logger to the list of available loggers. If a logger with the same identifier already exists, it will be replaced by the new one.
  public func registerLogger(newLogger: Logger) {
    self.loggers[newLogger.identifier] = newLogger;
  }
  
  // MARK: Acccessing loggers

  /// Returns the declared logger with the longest maching identifier. If none is found, the root logger will be returned
  public func getLogger(identifierToFind: String) -> Logger {
    let foundLogger: Logger;
    
    if let loggerFromCache = self.loggers[identifierToFind] {
      foundLogger = loggerFromCache;
    } else {
      var reducedIdentifier = identifierToFind.stringByRemovingLastComponentWithDelimiter(".");
      var loggerToCopy = self.rootLogger;
      while (loggerToCopy === self.rootLogger && !reducedIdentifier.isEmpty) {
        if let loggerFromCache = self.loggers[reducedIdentifier] {
          loggerToCopy = loggerFromCache;
        }
        reducedIdentifier = reducedIdentifier.stringByRemovingLastComponentWithDelimiter(".");
      }
      
      foundLogger = Logger(loggerToCopy: loggerToCopy, newIdentifier: identifierToFind);
      self.loggers[identifierToFind] = foundLogger;
    }
    
    return foundLogger;
  }
}