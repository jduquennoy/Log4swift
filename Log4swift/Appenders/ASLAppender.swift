//
//  ASLAppender.swift
//  Log4swift
//
//  Created by Jérôme Duquennoy on 29/07/15.
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
This appender will send messages to ASL, the Apple System Log.
*/
public class ASLAppender : Appender {
  internal let aslClient = ASLWrapper ()
  
  required public init(_ identifier: String) {
    super.init(identifier)
  }
  
  public override func performLog(_ log: String, level: LogLevel, info: LogInfoDictionary) {
    let category: String
    if let categoryFromInfo = info[LogInfoKeys.LoggerName] {
      category = categoryFromInfo.description
    } else {
      category = "Undefined"
    }
    self.aslClient.logMessage(log, level: Int32(level.rawValue), category: category)
  }
}
