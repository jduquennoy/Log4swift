//
//  FileAppenderRotationPolicy.swift
//  Log4swift
//
//  Created by Jérôme Duquennoy on 20/08/2018.
//  Copyright © 2018 jerome. All rights reserved.
//

import Foundation

/**
 Implement this protocol to create an object that controls when files
 are rotated by the FileAppender.
 */
public protocol FileAppenderRotationPolicy {
  /// Will be called when the file appender opens a destination file.
  /// You can use this hook to collect data on the file.
  func appenderDidOpenFile(atPath path: String)
  
  /// Will be called after a message has be added to the current file.
  /// You can use this hook to update the data you maintain on the file.
  /// Make sure your implementation of this method is as lightweight
  /// as possible, as it will be called for every single log message.
  func appenderDidAppend(data: Data)
  
  /// Will be called before logging to the file. If this method returns
  /// true, then the log file will be rotated before logging.
  /// Make sure your implementation of this method is as lightweight
  /// as possible, as it will be called for every single log message.
  func shouldRotate() -> Bool
}
