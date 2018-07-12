//
//  SystemAppender.swift
//  Log4swift
//
//  Created by Jérôme Duquennoy on 24/10/2017.
//  Copyright © 2017 jerome. All rights reserved.
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
 The SystemAppender is a meta-appender, that will select the preferable appender depending on the system.
 - For MacOS 10.11, it will be an ASL appender.
 - For MacOS 10.12 and latter, it will be a Unified Logging System appender
 - ...
 This appender is the best suited one for production software that targets multiple platforms.
 */
class SystemAppender: Appender {
  override var thresholdLevel: LogLevel {
    get {
      return self.backendAppender?.thresholdLevel ?? .Off
    }
    set {
      self.backendAppender?.thresholdLevel = newValue
    }
  }
  override var formatter: Formatter? {
    get {
      return self.backendAppender?.formatter
    }
    set {
      self.backendAppender?.formatter = newValue
    }
  }
  
  internal let backendAppender: Appender?
  
  required init(_ identifier: String) {
    if #available(iOS 10.0, macOS 10.12, watchOS 3, *) {
      self.backendAppender = AppleUnifiedLoggerAppender(identifier)
    } else if #available(iOS 9.0, macOS 10.9, *) {
      self.backendAppender = ASLAppender(identifier)
    } else {
      self.backendAppender = nil
      NSLog("No system appender found for current system")
    }
    super.init(identifier)
  }
  
  internal init(_ identifier: String, withBackendAppender appender: Appender?) {
    self.backendAppender = appender
    
    super.init(identifier)
  }
  
  override func update(withDictionary dictionary: Dictionary<String, Any>, availableFormatters: Array<Formatter>) throws {
    try self.backendAppender?.update(withDictionary: dictionary, availableFormatters: availableFormatters)
  }
  
  override func performLog(_ log: String, level: LogLevel, info: LogInfoDictionary) {
    self.backendAppender?.performLog(log, level: level, info: info)
  }
}
