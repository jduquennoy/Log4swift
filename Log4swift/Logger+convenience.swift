//
//  Logger+convenience.swift
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
This extension of the Logger class provides several convenience class methods to make use of log4swift easier in simple cases.
*/
extension Logger {
  
  public class func getLogger(loggerId: String) -> Logger {
    return LoggerFactory.sharedInstance.getLogger(loggerId);
  }
  
  // MARK: Logging class methods
  
  public class func debug(message: String) {
    LoggerFactory.sharedInstance.rootLogger.debug(message);
  }
  public class func info(message: String) {
    LoggerFactory.sharedInstance.rootLogger.info(message);
  }
  public class func warn(message: String) {
    LoggerFactory.sharedInstance.rootLogger.warn(message);
  }
  public class func error(message: String) {
    LoggerFactory.sharedInstance.rootLogger.error(message);
  }
  public class func fatal(message: String) {
    LoggerFactory.sharedInstance.rootLogger.fatal(message);
  }
  
  public class func debug(closure: () -> (String)) {
    LoggerFactory.sharedInstance.rootLogger.debug(closure);
  }
  public class func info(closure: () -> (String)) {
    LoggerFactory.sharedInstance.rootLogger.info(closure);
  }
  public class func warn(closure: () -> (String)) {
    LoggerFactory.sharedInstance.rootLogger.warn(closure);
  }
  public class func error(closure: () -> (String)) {
    LoggerFactory.sharedInstance.rootLogger.error(closure);
  }
  public class func fatal(closure: () -> (String)) {
    LoggerFactory.sharedInstance.rootLogger.fatal(closure);
  }
  
}