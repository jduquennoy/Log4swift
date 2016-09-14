//
//  MemoryAppender.swift
//  Log4swift
//
//  Created by jerome on 14/06/2015.
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
@testable import Log4swift

typealias LoggedMessage = (message: String, level: LogLevel)

/**
 This test appender will store logs in memory for latter validation.
 It can also add a delay when logging messages.
*/
class MemoryAppender: Appender {
  var loggingDelay: TimeInterval? = nil
  var logMessages = [LoggedMessage]()
  
  init() {
    super.init("test.memoryAppender")
  }

  required init(_ identifier: String) {
    super.init(identifier)
  }
  
  override func performLog(_ log: String, level: LogLevel, info: LogInfoDictionary) {
    if let loggingDelay = self.loggingDelay {
      Thread.sleep(forTimeInterval: loggingDelay)
    }
    logMessages.append((message: log, level: level))
  }
  
}

func ==(left: LoggedMessage, right: LoggedMessage) -> Bool {
  return (left.message == right.message) && (left.level == right.level)
}
