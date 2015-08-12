//
//  Logger+objectiveC.swift
//  Log4swift
//
//  Created by Jérôme Duquennoy on 20/07/15.
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

import Foundation

/**
This extension of the Logger class adds logging methods that can be exported to objective-C.
*/
extension Logger {
  @objc public func logDebug(message: String) {
    self.log(message, level: LogLevel.Debug);
  }
  @objc public func logInfo(message: String) {
    self.log(message, level: LogLevel.Info);
  }
  @objc public func logWarning(message: String) {
    self.log(message, level: LogLevel.Warning);
  }
  @objc public func logError(message: String) {
    self.log(message, level: LogLevel.Error);
  }
  @objc public func logFatal(message: String) {
    self.log(message, level: LogLevel.Fatal);
  }
  
  @objc public func logDebugBloc(closure:() -> (String)) {
    self.log(closure, level: LogLevel.Debug);
  }
  @objc public func logInfoBloc(closure:() -> (String)) {
    self.log(closure, level: LogLevel.Info);
  }
  @objc public func logWarningBloc(closure:() -> (String)) {
    self.log(closure, level: LogLevel.Warning);
  }
  @objc public func logErrorBloc(closure:() -> (String)) {
    self.log(closure, level: LogLevel.Error);
  }
  @objc public func logFatalBloc(closure:() -> (String)) {
    self.log(closure, level: LogLevel.Fatal);
  }
}