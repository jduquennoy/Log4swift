//
//  TestRotationPolicy.swift
//  Log4swift
//
//  Created by Jérôme Duquennoy on 20/08/2018.
//  Copyright © 2018 jerome. All rights reserved.
//

import Foundation
import Log4swift

class TestRotationPolicy: FileAppenderRotationPolicy {
  public var shouldRotateValue = false
  public var appendedData: Data? = nil
  public var openedFilePath: String? = nil
  
  func appenderDidOpenFile(atPath path: String) {
    self.openedFilePath = path
  }
  
  func appenderDidAppend(data: Data) {
    self.appendedData = data
  }
  
  func shouldRotate() -> Bool {
    return self.shouldRotateValue
  }
}
