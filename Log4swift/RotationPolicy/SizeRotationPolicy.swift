//
//  SizeRotationPolicy.swift
//  Log4swift
//
//  Created by Jérôme Duquennoy on 20/08/2018.
//  Copyright © 2018 jerome. All rights reserved.
//

import Foundation

/**
 This rotation policy will request a rotation once a file gets bigger than a given threshold.
 */
class SizeRotationPolicy: FileAppenderRotationPolicy {
  /// The maximum size of the file in octets before rotation is requested.
  public var maxFileSize: UInt64
  private var currentFileSize: UInt64 = 0

  /// Creates a rotation policy with a max file size in octet.
  init(maxFileSize: UInt64) {
    self.maxFileSize = maxFileSize
  }
  
  func appenderDidOpenFile(atPath path: String) {
    let fileManager = FileManager.default
    do {
      let fileAttributes = try fileManager.attributesOfItem(atPath: path)
      self.currentFileSize = fileAttributes[FileAttributeKey.size] as? UInt64 ?? 0
    } catch {
      self.currentFileSize = 0
    }
  }
  
  func appenderDidAppend(data: Data) {
    self.currentFileSize += UInt64(data.count)
  }
  
  func shouldRotate() -> Bool {
    return self.currentFileSize > self.maxFileSize
  }
}
