//
//  SizeRotationPolicyTests.swift
//  Log4swift
//
//  Created by Jérôme Duquennoy on 20/08/2018.
//  Copyright © 2018 jerome. All rights reserved.
//

import Foundation
import XCTest
@testable import Log4swift

class SizeRotationPolicyTests: XCTestCase {

  func testRotationIsRequestedWhenLoggedDataExceedsMaxSize() throws {
    let rotationPolicy = SizeRotationPolicy(maxFileSize: 100)
    let logMessageData = "test message".data(using: .utf8)!
    var logsCount = 0
    
    // Execute
    repeat {
      rotationPolicy.appenderDidAppend(data: logMessageData)
      logsCount += 1
    } while !rotationPolicy.shouldRotate() && logsCount < 1000
    
    // Validate
    XCTAssertEqual(logsCount, 100/logMessageData.count + 1)
  }

  func testPolicyConsidersNullSizeIfOpenFileIsNotReadable() throws {
    let rotationPolicy = SizeRotationPolicy(maxFileSize: 100)
    let logMessageData = "test message".data(using: .utf8)!
    var logsCount = 0
    
    // Execute
    rotationPolicy.appenderDidOpenFile(atPath: "/file/that/does/not/exist.log")
    repeat {
      rotationPolicy.appenderDidAppend(data: logMessageData)
      logsCount += 1
    } while !rotationPolicy.shouldRotate() && logsCount < 1000
    
    // Validate
    XCTAssertEqual(logsCount, 100/logMessageData.count + 1)
  }

  func testInitialFileSizeIsTakenIntoAccount() throws {
    let filePath = try self.createTemporaryFilePath(fileExtension: "log")
    let initialFileContent = "this is the initial file content.\n".data(using: .utf8)!
    try initialFileContent.write(to: URL.init(fileURLWithPath: filePath))
    let rotationPolicy = SizeRotationPolicy(maxFileSize: UInt64(initialFileContent.count.advanced(by: 10)))
    let logMessageData = "a".data(using: .utf8)!
    var logsCount = 0
    
    // Execute
    rotationPolicy.appenderDidOpenFile(atPath: filePath)
    repeat {
      rotationPolicy.appenderDidAppend(data: logMessageData)
      logsCount += 1
    } while !rotationPolicy.shouldRotate() && logsCount < 1000

    // Validate
    XCTAssertEqual(logsCount, 10/logMessageData.count + 1)
  }
  
}
