//
//  AppleUnifiedLoggerAppender.swift
//  Log4swift
//
//  Created by Jérôme Duquennoy on 24/10/2017.
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

import os.log

@available(iOS 10.0, macOS 10.12, watchOS 3, *)
class AppleUnifiedLoggerAppender : Appender {
  private static var levelsMapping = [
    LogLevel.Trace: OSLogType.debug,
    LogLevel.Debug: OSLogType.debug,
    LogLevel.Info: OSLogType.info,
    LogLevel.Warning: OSLogType.default,
    LogLevel.Error: OSLogType.error,
    LogLevel.Fatal: OSLogType.fault
  ]
  private var loggerToOSLogCache = [String: OSLog]()
  
  public override func performLog(_ log: String, level: LogLevel, info: LogInfoDictionary) {
    guard let logType = type(of: self).levelsMapping[level] else { return }
    let loggerName = info[LogInfoKeys.LoggerName] as? String ?? "-"
    let osLog = self.osLog(ForLoggerName: loggerName)
    os_log("%@", log: osLog, type: logType, log)
  }
  
  private func osLog(ForLoggerName loggerName: String) -> OSLog {
    let osLog: OSLog
    if let osLogFromCache = self.loggerToOSLogCache[loggerName] {
      osLog = osLogFromCache
    } else {
      let subsystem = Bundle.main.infoDictionary?["CFBundleIdentifier"] as? String ?? "-"
      osLog = OSLog(subsystem: subsystem, category: loggerName)
      self.loggerToOSLogCache[loggerName] = osLog
    }
    
    return osLog
  }
}
