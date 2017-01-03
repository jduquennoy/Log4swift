//
//  NSLogAppender.swift
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
The NSLog appender uses NSLog to issue the logs. It is not extermely performant, you should only use it if you want to have the exact same behavior as NSLog (same formatting, output to stderr of ALS depending on the situation, ...)
*/
public class NSLogAppender: Appender {
  public override func performLog(_ log: String, level: LogLevel, info: LogInfoDictionary) {
    NSLog(log)
  }
}
