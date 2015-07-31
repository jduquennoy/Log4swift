//
//  ASLAppender.swift
//  Log4swift
//
//  Created by Jérôme Duquennoy on 29/07/15.
//  Copyright © 2015 jerome. All rights reserved.
//

import Foundation

/**
This appender will send messages to ASL, the Apple System Log.
*/
public class ASLAppender : Appender {
  internal let aslClient = ASLWrapper ();
  
  required public init(_ identifier: String) {
    super.init(identifier);
    
  }
  
  override func performLog(log: String, level: LogLevel, info: LogInfoDictionary) {
    let category: String;
    if let categoryFromInfo = info[LogInfoKeys.LoggerName] {
      category = categoryFromInfo.description;
    } else {
      category = "Undefined";
    }
    aslClient.logMessage(log, level: Int32(level.rawValue), category: category);
  }
}