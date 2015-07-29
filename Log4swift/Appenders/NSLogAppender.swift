//
//  NSLogAppender.swift
//  Log4swift
//
//  Created by Jérôme Duquennoy on 29/07/15.
//  Copyright © 2015 jerome. All rights reserved.
//

import Foundation

/**
The NSLog appender uses NSLog to issue the logs. It is not extermely performant, you should only use it if you want to have the exact same behavior as NSLog (same formatting, output to stderr of ALS depending on the situation, ...)
*/
public class NSLogAppender: Appender {
  override func performLog(log: String, level: LogLevel, info: LogInfoDictionary) {
    NSLog(log);
  }
}