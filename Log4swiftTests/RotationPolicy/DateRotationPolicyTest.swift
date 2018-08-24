//
//  DateRotationPolicyTest.swift
//  log4swiftTests
//
//  Created by Jérôme Duquennoy on 24/08/2018.
//  Copyright © 2018 jerome. All rights reserved.
//

import Foundation
import XCTest
@testable import Log4swift

class DateRotationPolicyTest: XCTestCase {
  func testRotationIsRequestedWhenAgeExceedsLimit() throws {
    let filePath = try self.createTemporaryFilePath(fileExtension: "log")
    let policy = DateRotationPolicy(maxFileAge: 10)
    let fileCreationInterval = -1 * (policy.maxFileAge + 1)
    FileManager.default.createFile(atPath: filePath, contents: nil, attributes: [FileAttributeKey.creationDate: Date(timeIntervalSinceNow: fileCreationInterval)])
    
    policy.appenderDidOpenFile(atPath: filePath)
    
    // Execute & validate
    XCTAssertTrue(policy.shouldRotate())
  }
  
  func testRotationIsNotRequestedWhenFileAgeDoesNotExceedLimit() throws {
    let filePath = try self.createTemporaryFilePath(fileExtension: "log")
    let policy = DateRotationPolicy(maxFileAge: 10)
    let fileCreationInterval = -1 * (policy.maxFileAge - 1)
    FileManager.default.createFile(atPath: filePath, contents: nil, attributes: [FileAttributeKey.creationDate: Date(timeIntervalSinceNow: fileCreationInterval)])
    
    policy.appenderDidOpenFile(atPath: filePath)
    
    // Execute & validate
    XCTAssertFalse(policy.shouldRotate())
  }
  
  func testRotationIsNotRequestedIfNoFileWasOpened() {
    let policy = DateRotationPolicy(maxFileAge: 10)
    
    // Execute & validate
    XCTAssertFalse(policy.shouldRotate())
  }

  func testRotationIsNotRequestedIfNonExistingFileWasOpened() {
    let policy = DateRotationPolicy(maxFileAge: 10)
    
    // Execute & validate
    policy.appenderDidOpenFile(atPath: "/File/that/does/not/exist.log")
    XCTAssertFalse(policy.shouldRotate())
  }
  
  func testFileDateDefaultsToNowIfFileDoesNotExist() {
    let policy = DateRotationPolicy(maxFileAge: 1)
    
    // Execute & validate
    policy.appenderDidOpenFile(atPath: "/File/that/does/not/exist.log")
    XCTAssertFalse(policy.shouldRotate())
    Thread.sleep(forTimeInterval: 1.5)
    XCTAssertTrue(policy.shouldRotate())
  }
}
