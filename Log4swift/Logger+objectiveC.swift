//
//  Logger+objectiveC.swift
//  Log4swift
//
//  Created by Jérôme Duquennoy on 20/07/15.
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