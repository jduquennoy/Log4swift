//
//  DateRotationPolicy.swift
//  Log4swift
//
//  Created by Jérôme Duquennoy on 20/08/2018.
//  Copyright © 2018 jerome. All rights reserved.
//

import Foundation

/**
 This rotation policy will request a rotation once a file gets older than a given threshold.
 */
class DateRotationPolicy: FileAppenderRotationPolicy {
  /// The maximum age of the file in seconds before rotation is requested.
  public var maxFileAge: TimeInterval
  internal var currentFileCreationCreationDate: Date? = nil
  
  /// Creates a rotation policy with a max file age in seconds.
  init(maxFileAge: TimeInterval) {
    self.maxFileAge = maxFileAge
  }
  
  func appenderDidOpenFile(atPath path: String) {
    let fileManager = FileManager.default
    do {
      let fileAttributes = try fileManager.attributesOfItem(atPath: path)
      self.currentFileCreationCreationDate = fileAttributes[FileAttributeKey.creationDate] as? Date ?? Date()
    } catch {
      self.currentFileCreationCreationDate = Date()
    }
  }
  
  func appenderDidAppend(data: Data) {
  }
  
  func shouldRotate() -> Bool {
    guard let fileDate = self.currentFileCreationCreationDate else { return false }
  
    return Date().timeIntervalSince(fileDate) >= self.maxFileAge
  }
}
