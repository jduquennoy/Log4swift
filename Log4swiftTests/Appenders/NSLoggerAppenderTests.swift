//
//  NSLoggerAppenderTests.swift
//  Log4swift
//
//  Created by jerome on 24/06/2015.
//  Copyright © 2015 jerome. All rights reserved.
//

import XCTest
@testable import Log4swift

class NSLoggerAppenderTests: XCTestCase {

  func testSettingUpAHostLoggerWithSSLEnabledEnablesSSLOption() {
    let appender = NSLoggerAppender(identifier: "test", remoteHost: "test", remotePort: 12345, useLocalCache: false, useSSL: true);
    
    let sslEnabled: Bool = (appender.logger.memory.options & UInt32(kLoggerOption_UseSSL)) != UInt32(0);
    XCTAssertTrue(sslEnabled, "logger should have the SSL option enabled.");
  }
  
  func testSettingUpAHostLoggerWithSSLDisabledDisablesSSLOption() {
    let appender = NSLoggerAppender(identifier: "test", remoteHost: "test", remotePort: 12345, useLocalCache: false, useSSL: false);
    
    let sslEnabled: Bool = (appender.logger.memory.options & UInt32(kLoggerOption_UseSSL)) != UInt32(0);
    XCTAssertFalse(sslEnabled, "logger should have the SSL option disabled.");
  }
  
  func testSettingUpAHostLoggerWithLocalCacheDisabledDisablesLocalCacheOption() {
    let appender = NSLoggerAppender(identifier: "test", remoteHost: "test", remotePort: 12345, useLocalCache: false, useSSL: false);
    
    let sslEnabled: Bool = (appender.logger.memory.options & UInt32(kLoggerOption_BufferLogsUntilConnection)) != UInt32(0);
    XCTAssertFalse(sslEnabled, "logger should have the local cache option disabled.");
  }
  
  func testSettingUpAHostLoggerWithLocalCacheEnabledEnablesLocalCacheOption() {
    let appender = NSLoggerAppender(identifier: "test", remoteHost: "test", remotePort: 12345, useLocalCache: true, useSSL: false);
    
    let sslEnabled: Bool = (appender.logger.memory.options & UInt32(kLoggerOption_BufferLogsUntilConnection)) != UInt32(0);
    XCTAssertTrue(sslEnabled, "logger should have the local cache option enabled.");
  }
  
  func testSettingUpABonjourLoggerWithSSLEnabledEnablesSSLOption() {
    let appender = NSLoggerAppender(identifier: "test", bonjourServiceName: "test", useLocalCache: false, useSSL: true);
    
    let sslEnabled: Bool = (appender.logger.memory.options & UInt32(kLoggerOption_UseSSL)) != UInt32(0);
    XCTAssertTrue(sslEnabled, "logger should have the SSL option enabled.");
  }
  
  func testSettingUpABonjourLoggerWithSSLDisabledDisablesSSLOption() {
    let appender = NSLoggerAppender(identifier: "test", bonjourServiceName: "test", useLocalCache: false, useSSL: false);
    
    let sslEnabled: Bool = (appender.logger.memory.options & UInt32(kLoggerOption_UseSSL)) != UInt32(0);
    XCTAssertFalse(sslEnabled, "logger should have the SSL option disabled.");
  }
  
  func testSettingUpABonjourLoggerWithLocalCacheDisabledDisablesLocalCacheOption() {
    let appender = NSLoggerAppender(identifier: "test", bonjourServiceName: "test", useLocalCache: false, useSSL: false);
    
    let sslEnabled: Bool = (appender.logger.memory.options & UInt32(kLoggerOption_BufferLogsUntilConnection)) != UInt32(0);
    XCTAssertFalse(sslEnabled, "logger should have the local cache option disabled.");
  }
  
  func testSettingUpABonjourLoggerWithLocalCacheEnabledEnablesLocalCacheOption() {
    let appender = NSLoggerAppender(identifier: "test", bonjourServiceName: "test", useLocalCache: true, useSSL: false);
    
    let sslEnabled: Bool = (appender.logger.memory.options & UInt32(kLoggerOption_BufferLogsUntilConnection)) != UInt32(0);
    XCTAssertTrue(sslEnabled, "logger should have the local cache option enabled.");
  }
  
}
