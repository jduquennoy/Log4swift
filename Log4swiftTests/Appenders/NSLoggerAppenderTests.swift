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
  
  func testCreatingAppenderFromDictionaryWithNoIdentifierThrowError () {
    XCTAssertThrows({ try NSLoggerAppender(Dictionary<String, AnyObject>()) });
  }

  func testCreatingAppenderFromDictionaryWithIdentifierButNoRemoteHostNorServiceNameThrowsError () {
    let dictionary: Dictionary<String, AnyObject> = [Appender.DictionaryKey.Identifier.rawValue: "identifier"];
    
    // Execute
    XCTAssertThrows({ try NSLoggerAppender(dictionary) });
  }
  
  func testCreatingAppenderFromDictionaryWithInvalidThresholdThrowsError () {
    let dictionary: Dictionary<String, AnyObject> = [Appender.DictionaryKey.Identifier.rawValue: "identifier",
      NSLoggerAppender.DictionaryKey.RemoteHost.rawValue: "remoteHost",
      Appender.DictionaryKey.Threshold.rawValue: "dummy level"];
    
    // Execute
    XCTAssertThrows({ try NSLoggerAppender(dictionary) });
  }
  
  func testCreatingAppenderFromDictionaryWithThresholdUsesIt () {
    let dictionary: Dictionary<String, AnyObject> = [Appender.DictionaryKey.Identifier.rawValue: "identifier",
      NSLoggerAppender.DictionaryKey.RemoteHost.rawValue: "remoteHost",
      Appender.DictionaryKey.Threshold.rawValue: "Warning"];
    
    // Execute
    let appender = try! NSLoggerAppender(dictionary);
    
    // Validate
    XCTAssertEqual(appender.thresholdLevel, LogLevel.Warning);
  }
  
  func testCreatingAppenderFromDictionaryWithoutRemotePortUsesDefaultValue () {
    let dictionary: Dictionary<String, AnyObject> = [Appender.DictionaryKey.Identifier.rawValue: "identifier",
      NSLoggerAppender.DictionaryKey.RemoteHost.rawValue: "remoteHost"];
    
    // Execute
    let appender = try! NSLoggerAppender(dictionary);
    
    // Validate
    XCTAssertEqual(appender.logger.memory.port, 50000);
  }

  func testCreatingAppenderFromDictionaryWithAnInvalidRemotePortThrowsError () {
    let dictionary: Dictionary<String, AnyObject> = [Appender.DictionaryKey.Identifier.rawValue: "identifier",
      NSLoggerAppender.DictionaryKey.RemoteHost.rawValue: "remoteHost",
      NSLoggerAppender.DictionaryKey.RemotePort.rawValue: "not a number"];
    
    // Execute & validate
    XCTAssertThrows({ try NSLoggerAppender(dictionary) });
  }
  
  func testCreatingAppenderFromDictionaryWithRemoteHostAndPortUsesProvidedValue () {
    let dictionary: Dictionary<String, AnyObject> = [Appender.DictionaryKey.Identifier.rawValue: "identifier",
      NSLoggerAppender.DictionaryKey.RemoteHost.rawValue: "remoteHost",
      NSLoggerAppender.DictionaryKey.RemotePort.rawValue: "1234"];
    
    // Execute
    let appender = try! NSLoggerAppender(dictionary);
    
    // Validate
    XCTAssertEqual(appender.logger.memory.port, 1234);
    XCTAssertEqual(appender.logger.memory.host.takeUnretainedValue() as String, "remoteHost");
  }
  
  func testCreatingAppenderFromDictionaryWithSslDisabledUsesProvidedValue () {
    let dictionary: Dictionary<String, AnyObject> = [Appender.DictionaryKey.Identifier.rawValue: "identifier",
      NSLoggerAppender.DictionaryKey.RemoteHost.rawValue: "remoteHost",
      NSLoggerAppender.DictionaryKey.RemotePort.rawValue: "1234",
      NSLoggerAppender.DictionaryKey.UseSSL.rawValue: "no"];
    
    // Execute
    let appender = try! NSLoggerAppender(dictionary);
    
    // Validate
    XCTAssert((appender.logger.memory.options & UInt32(kLoggerOption_UseSSL)) == 0);
  }
  
  func testCreatingAppenderFromDictionaryWithLocalCacheDisabledUsesProvidedValue () {
    let dictionary: Dictionary<String, AnyObject> = [Appender.DictionaryKey.Identifier.rawValue: "identifier",
      NSLoggerAppender.DictionaryKey.RemoteHost.rawValue: "remoteHost",
      NSLoggerAppender.DictionaryKey.RemotePort.rawValue: "1234",
      NSLoggerAppender.DictionaryKey.UseLocalCache.rawValue: "no"];
    
    // Execute
    let appender = try! NSLoggerAppender(dictionary);
    
    // Validate
    XCTAssert((appender.logger.memory.options & UInt32(kLoggerOption_BufferLogsUntilConnection)) == 0);
  }
  
  func testCreatingAppenderFromDictionaryWithoutThresholdUsesDebugAsDefaultValue () {
    let dictionary: Dictionary<String, AnyObject> = [Appender.DictionaryKey.Identifier.rawValue: "identifier",
      NSLoggerAppender.DictionaryKey.RemoteHost.rawValue: "remoteHost"];
    
    // Execute
    let appender = try! NSLoggerAppender(dictionary);
    
    // Validate
    XCTAssertEqual(appender.thresholdLevel, LogLevel.Debug);
  }
  
  func testCreatingAppenderFromDictionaryWithBonjourServiceNameStartsABonjourBasedLogger() {
    let dictionary: Dictionary<String, AnyObject> = [Appender.DictionaryKey.Identifier.rawValue: "identifier",
      NSLoggerAppender.DictionaryKey.BonjourServiceName.rawValue: "bonjourService"];
    
    // Execute
    let appender = try! NSLoggerAppender(dictionary);
    
    // Validate
    XCTAssertEqual(appender.logger.memory.bonjourServiceName.takeUnretainedValue() as String, "bonjourService");
  }

  func testCreatingAppenderFromDictionaryWithBonjourServiceNameThatIsNotAStringThrowsError() {
    let dictionary: Dictionary<String, AnyObject> = [Appender.DictionaryKey.Identifier.rawValue: "identifier",
      NSLoggerAppender.DictionaryKey.BonjourServiceName.rawValue: 123];
    
    // Execute & validate
    XCTAssertThrows({ try NSLoggerAppender(dictionary) });
  }

}
