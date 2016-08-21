//
//  NSLoggerAppenderTests.swift
//  Log4swift
//
//  Created by jerome on 24/06/2015.
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

import XCTest
@testable import Log4swift

class NSLoggerAppenderTests: XCTestCase {

  func testSettingUpAHostLoggerWithSSLEnabledEnablesSSLOption() {
    let appender = NSLoggerAppender(identifier: "test", remoteHost: "test", remotePort: 12345, useLocalCache: false, useSSL: true)
    
    let sslEnabled: Bool = (appender.logger.pointee.options & UInt32(kLoggerOption_UseSSL)) != UInt32(0)
    XCTAssertTrue(sslEnabled, "logger should have the SSL option enabled.")
  }
  
  func testSettingUpAHostLoggerWithSSLDisabledDisablesSSLOption() {
    let appender = NSLoggerAppender(identifier: "test", remoteHost: "test", remotePort: 12345, useLocalCache: false, useSSL: false)
    
    let sslEnabled: Bool = (appender.logger.pointee.options & UInt32(kLoggerOption_UseSSL)) != UInt32(0)
    XCTAssertFalse(sslEnabled, "logger should have the SSL option disabled.")
  }
  
  func testSettingUpAHostLoggerWithLocalCacheDisabledDisablesLocalCacheOption() {
    let appender = NSLoggerAppender(identifier: "test", remoteHost: "test", remotePort: 12345, useLocalCache: false, useSSL: false)
    
    let sslEnabled: Bool = (appender.logger.pointee.options & UInt32(kLoggerOption_BufferLogsUntilConnection)) != UInt32(0)
    XCTAssertFalse(sslEnabled, "logger should have the local cache option disabled.")
  }
  
  func testSettingUpAHostLoggerWithLocalCacheEnabledEnablesLocalCacheOption() {
    let appender = NSLoggerAppender(identifier: "test", remoteHost: "test", remotePort: 12345, useLocalCache: true, useSSL: false)
    
    let sslEnabled: Bool = (appender.logger.pointee.options & UInt32(kLoggerOption_BufferLogsUntilConnection)) != UInt32(0)
    XCTAssertTrue(sslEnabled, "logger should have the local cache option enabled.")
  }
  
  func testSettingUpABonjourLoggerWithSSLEnabledEnablesSSLOption() {
    let appender = NSLoggerAppender(identifier: "test", bonjourServiceName: "test", useLocalCache: false, useSSL: true)
    
    let sslEnabled: Bool = (appender.logger.pointee.options & UInt32(kLoggerOption_UseSSL)) != UInt32(0)
    XCTAssertTrue(sslEnabled, "logger should have the SSL option enabled.")
  }
  
  func testSettingUpABonjourLoggerWithSSLDisabledDisablesSSLOption() {
    let appender = NSLoggerAppender(identifier: "test", bonjourServiceName: "test", useLocalCache: false, useSSL: false)
    
    let sslEnabled: Bool = (appender.logger.pointee.options & UInt32(kLoggerOption_UseSSL)) != UInt32(0)
    XCTAssertFalse(sslEnabled, "logger should have the SSL option disabled.")
  }
  
  func testSettingUpABonjourLoggerWithLocalCacheDisabledDisablesLocalCacheOption() {
    let appender = NSLoggerAppender(identifier: "test", bonjourServiceName: "test", useLocalCache: false, useSSL: false)
    
    let sslEnabled: Bool = (appender.logger.pointee.options & UInt32(kLoggerOption_BufferLogsUntilConnection)) != UInt32(0)
    XCTAssertFalse(sslEnabled, "logger should have the local cache option disabled.")
  }
  
  func testSettingUpABonjourLoggerWithLocalCacheEnabledEnablesLocalCacheOption() {
    let appender = NSLoggerAppender(identifier: "test", bonjourServiceName: "test", useLocalCache: true, useSSL: false)
    
    let sslEnabled: Bool = (appender.logger.pointee.options & UInt32(kLoggerOption_BufferLogsUntilConnection)) != UInt32(0)
    XCTAssertTrue(sslEnabled, "logger should have the local cache option enabled.")
  }

  func testUpdatingAppenderFromDictionaryWithIdentifierButNoRemoteHostNorServiceNameThrowsError () {
    let dictionary = Dictionary<String, Any>()
    let appender = NSLoggerAppender("testAppender")
    
    // Execute
    XCTAssertThrows { try appender.update(withDictionary: dictionary, availableFormatters:[]) }
  }
  
  func testUpdatingAppenderFromDictionaryWithInvalidThresholdThrowsError () {
    let dictionary = [NSLoggerAppender.DictionaryKey.RemoteHost.rawValue: "remoteHost",
      Appender.DictionaryKey.ThresholdLevel.rawValue: "dummy level"]
    let appender = NSLoggerAppender("testAppender")
    
    // Execute
    XCTAssertThrows { try appender.update(withDictionary: dictionary, availableFormatters:[]) }
  }
  
  func testUpdatingAppenderFromDictionaryWithThresholdUsesIt () {
    let dictionary = [NSLoggerAppender.DictionaryKey.RemoteHost.rawValue: "remoteHost",
      Appender.DictionaryKey.ThresholdLevel.rawValue: "Warning"]
    let appender = NSLoggerAppender("testAppender")
    
    // Execute
    try! appender.update(withDictionary: dictionary, availableFormatters:[])
    
    // Validate
    XCTAssertEqual(appender.thresholdLevel, LogLevel.Warning)
  }
  
  func testUpdatingAppenderFromDictionaryWithoutRemotePortUsesDefaultValue () {
    let dictionary = [NSLoggerAppender.DictionaryKey.RemoteHost.rawValue: "remoteHost"]
    let appender = NSLoggerAppender("testAppender")
    
    // Execute
    try! appender.update(withDictionary: dictionary, availableFormatters:[])
    
    // Validate
    XCTAssertEqual(appender.logger.pointee.port, 50000)
  }

  func testUpdatingAppenderFromDictionaryWithAnInvalidRemotePortThrowsError () {
    let dictionary = [NSLoggerAppender.DictionaryKey.RemoteHost.rawValue: "remoteHost",
      NSLoggerAppender.DictionaryKey.RemotePort.rawValue: "not a number"]
    let appender = NSLoggerAppender("testAppender")
    
    // Execute & validate
    XCTAssertThrows { try appender.update(withDictionary: dictionary, availableFormatters:[]) }
  }
  
  func testUpdatingAppenderFromDictionaryWithRemotePortLowerThan1024ThrowsError () {
    let dictionary = [NSLoggerAppender.DictionaryKey.RemoteHost.rawValue: "remoteHost",
      NSLoggerAppender.DictionaryKey.RemotePort.rawValue: "110"]
    let appender = NSLoggerAppender("testAppender")
    
    // Execute & validate
    XCTAssertThrows { try appender.update(withDictionary: dictionary, availableFormatters:[]) }
  }
  
  func testUpdatingAppenderFromDictionaryWithRemotePortLowerThan65535ThrowsError () {
    let dictionary = [NSLoggerAppender.DictionaryKey.RemoteHost.rawValue: "remoteHost",
      NSLoggerAppender.DictionaryKey.RemotePort.rawValue: "65540"]
    let appender = NSLoggerAppender("testAppender")
    
    // Execute & validate
    XCTAssertThrows { try appender.update(withDictionary: dictionary, availableFormatters:[]) }
  }

  func testUpdatingAppenderFromDictionaryWithRemoteHostAndPortAsStringUsesProvidedValue () {
    let dictionary = [NSLoggerAppender.DictionaryKey.RemoteHost.rawValue: "remoteHost",
      NSLoggerAppender.DictionaryKey.RemotePort.rawValue: "1234"]
    let appender = NSLoggerAppender("testAppender")
    
    // Execute
    try! appender.update(withDictionary: dictionary, availableFormatters:[])
    
    // Validate
    XCTAssertEqual(appender.logger.pointee.port, 1234)
    XCTAssertEqual(appender.logger.pointee.host.takeUnretainedValue() as String, "remoteHost")
  }
  
  func testUpdatingAppenderFromDictionaryWithRemoteHostAndPortAsIntUsesProvidedValue () {
    let dictionary:[String: Any] = [NSLoggerAppender.DictionaryKey.RemoteHost.rawValue: "remoteHost",
      NSLoggerAppender.DictionaryKey.RemotePort.rawValue: 1235]
    let appender = NSLoggerAppender("testAppender")
    
    // Execute
    try! appender.update(withDictionary: dictionary, availableFormatters:[])
    
    // Validate
    XCTAssertEqual(appender.logger.pointee.port, 1235)
    XCTAssertEqual(appender.logger.pointee.host.takeUnretainedValue() as String, "remoteHost")
  }
  
  func testUpdatingAppenderFromDictionaryWithSslDisabledUsesProvidedValue () {
    let dictionary = [NSLoggerAppender.DictionaryKey.RemoteHost.rawValue: "remoteHost",
      NSLoggerAppender.DictionaryKey.RemotePort.rawValue: "1234",
      NSLoggerAppender.DictionaryKey.UseSSL.rawValue: "no"]
    let appender = NSLoggerAppender("testAppender")
    
    // Execute
    try! appender.update(withDictionary: dictionary, availableFormatters:[])
    
    // Validate
    XCTAssert((appender.logger.pointee.options & UInt32(kLoggerOption_UseSSL)) == 0)
  }
  
  func testUpdatingAppenderFromDictionaryWithLocalCacheDisabledUsesProvidedValue () {
    let dictionary = [NSLoggerAppender.DictionaryKey.RemoteHost.rawValue: "remoteHost",
      NSLoggerAppender.DictionaryKey.RemotePort.rawValue: "1234",
      NSLoggerAppender.DictionaryKey.UseLocalCache.rawValue: "no"]
    let appender = NSLoggerAppender("testAppender")
    
    // Execute
    try! appender.update(withDictionary: dictionary, availableFormatters:[])
    
    // Validate
    XCTAssert((appender.logger.pointee.options & UInt32(kLoggerOption_BufferLogsUntilConnection)) == 0)
  }
  
  func testUpdatingAppenderFromDictionaryWithoutThresholdUsesDebugAsDefaultValue () {
    let dictionary = [NSLoggerAppender.DictionaryKey.RemoteHost.rawValue: "remoteHost"]
    let appender = NSLoggerAppender("testAppender")
    
    // Execute
    try! appender.update(withDictionary: dictionary, availableFormatters:[])
    
    // Validate
    XCTAssertEqual(appender.thresholdLevel, LogLevel.Debug)
  }
  
  func testUpdatingAppenderFromDictionaryWithBonjourServiceNameStartsABonjourBasedLogger() {
    let dictionary = [NSLoggerAppender.DictionaryKey.BonjourServiceName.rawValue: "bonjourService"]
    let appender = NSLoggerAppender("testAppender")
    
    // Execute
    try! appender.update(withDictionary: dictionary, availableFormatters:[])
    
    // Validate
    XCTAssertEqual(appender.logger.pointee.bonjourServiceName.takeUnretainedValue() as String, "bonjourService")
  }

  func testUpdatingAppenderFromDictionaryWithBonjourServiceNameThatIsNotAStringThrowsError() {
    let dictionary = [NSLoggerAppender.DictionaryKey.BonjourServiceName.rawValue: 123]
    let appender = NSLoggerAppender("testAppender")
    
    // Execute & validate
    XCTAssertThrows { try appender.update(withDictionary: dictionary, availableFormatters:[]) }
  }

  func testUpdatingAppenderFomDictionaryWithNonExistingFormatterIdThrowsError() {
    let dictionary = [Appender.DictionaryKey.FormatterId.rawValue: "not existing id"]
    let appender = NSLoggerAppender("testAppender")
    
    XCTAssertThrows { try appender.update(withDictionary: dictionary, availableFormatters: []) }
  }
  
  func testUpdatingAppenderFomDictionaryWithExistingFormatterIdUsesIt() {
    let formatter = try! PatternFormatter(identifier: "formatterId", pattern: "test pattern")
    let dictionary = [Appender.DictionaryKey.FormatterId.rawValue: "formatterId",
      NSLoggerAppender.DictionaryKey.RemoteHost.rawValue: "remoteHost"]
    let appender = NSLoggerAppender("testAppender")
    
    // Execute
    try! appender.update(withDictionary: dictionary, availableFormatters: [formatter])
    
    // Validate
    XCTAssertEqual((appender.formatter?.identifier)!, formatter.identifier)
  }
  
}
