//
//  Logger-AsynchronicityTests.swift
//  Log4swift
//
//  Created by Jérôme Duquennoy on 28/10/2015.
//  Copyright © 2015 jerome. All rights reserved.
//

import XCTest
@testable import Log4swift

class LoggerAsynchronicityTests: XCTestCase {
  
  override func setUp() {
    super.setUp();
    LoggerFactory.sharedInstance.resetConfiguration();
  }
  
  override func tearDown() {
    super.tearDown();
  }  

  func testLoggerIsSynchronousByDefault() {
    let rootLogger = LoggerFactory.sharedInstance.rootLogger;
    
    XCTAssertFalse(rootLogger.isAsync);
  }
  
  func testResetConfigurationSetsLoggerSynchronous() {
    let rootLogger = LoggerFactory.sharedInstance.rootLogger;
    rootLogger.isAsync = true;
    
    // Execute
    rootLogger.resetConfiguration()
    
    // Validate
    XCTAssertFalse(rootLogger.isAsync);
  }
  
  /// This test logs three message to an appender that takes 0.1 second to execute.
  /// It then counts the number of logged messages as soon as possible.
  /// If the logger is synchronous, the three logs should already be recorded.
  func testSynchronousLoggerLogsMessagesSynchronously() {
    let rootLogger = LoggerFactory.sharedInstance.rootLogger;
    let slowAppender = MemoryAppender();
    slowAppender.loggingDelay = 0.1;
    rootLogger.isAsync = false;
    rootLogger.appenders = [slowAppender];
    
    // execute
    rootLogger.error("log1");
    rootLogger.error("log2");
    rootLogger.error("log3");
    
    // Validate
    let loggedMessagesCount = slowAppender.logMessages.count;
    XCTAssertEqual(loggedMessagesCount, 3, "Logged messages were not recorded synchronously (3 messages sent, \(loggedMessagesCount) recorded");
  }
  
  /// This test logs three message to an appender that takes 0.1 second to execute.
  /// It then counts the number of logged messages as soon as possible.
  /// If the logger is synchronous, the three logs should already be recorded.
  func testSynchronousLoggerLogsBlocsSynchronously() {
    let rootLogger = LoggerFactory.sharedInstance.rootLogger;
    let slowAppender = MemoryAppender();
    slowAppender.loggingDelay = 0.1;
    rootLogger.isAsync = false;
    rootLogger.appenders = [slowAppender];
    
    // execute
    rootLogger.error{"log1"};
    rootLogger.error{"log2"};
    rootLogger.error{"log3"};
    
    // Validate
    let loggedMessagesCount = slowAppender.logMessages.count;
    XCTAssertEqual(loggedMessagesCount, 3, "Logged messages were not recorded synchronously (3 messages sent, \(loggedMessagesCount) recorded");
  }

  /// This test logs three message to an appender that takes 0.1 second to execute.
  /// It then counts the number of logged messages as soon as possible, and after a long enough
  /// delay for all messages to be logged
  /// If the logger is synchronous, no message should have been logged right after,
  /// 3 should have been after the delay.
  func testAsynchronousLoggerLogsMessagesAsynchronously() {
    let rootLogger = LoggerFactory.sharedInstance.rootLogger;
    let slowAppender = MemoryAppender();
    slowAppender.loggingDelay = 0.1;
    rootLogger.isAsync = true;
    rootLogger.appenders = [slowAppender];
    
    // execute
    rootLogger.error("log1");
    rootLogger.error("log2");
    rootLogger.error("log3");

    let immediateLoggedMessagesCount = slowAppender.logMessages.count;
    self.waitUntilTrue{slowAppender.logMessages.count == 3};
    let delayedLoggedMessagesCount = slowAppender.logMessages.count;

    // Validate
    XCTAssertEqual(immediateLoggedMessagesCount, 0, "Some messages were not logged asynchronously");
    XCTAssertEqual(delayedLoggedMessagesCount, 3, "Some messages were not logged after");
  }

  /// This test logs three message to an appender that takes 0.1 second to execute.
  /// It then counts the number of logged messages as soon as possible, and after a long enough
  /// delay for all messages to be logged
  /// If the logger is synchronous, no message should have been logged right after,
  /// 3 should have been after the delay.
  func testAsynchronousLoggerLogsBlocsAsynchronously() {
    let rootLogger = LoggerFactory.sharedInstance.rootLogger;
    let slowAppender = MemoryAppender();
    slowAppender.loggingDelay = 0.1;
    rootLogger.isAsync = true;
    rootLogger.appenders = [slowAppender];
    
    // execute
    rootLogger.error{"log1"};
    rootLogger.error{"log2"};
    rootLogger.error{"log3"};
    
    let immediateLoggedMessagesCount = slowAppender.logMessages.count;
    self.waitUntilTrue{slowAppender.logMessages.count == 3};
    let delayedLoggedMessagesCount = slowAppender.logMessages.count;
        
    // Validate
    XCTAssertEqual(immediateLoggedMessagesCount, 0, "Some messages were not logged asynchronously");
    XCTAssertEqual(delayedLoggedMessagesCount, 3, "Some messages were not logged after delay");
  }
  
  func testMessagesSentToAsynchronousLoggersAreOrdered() {
    let logger1 = LoggerFactory.sharedInstance.getLogger("logger1");
    logger1.isAsync = true;
    let logger2 = LoggerFactory.sharedInstance.getLogger("logger2");
    logger2.isAsync = true;

    let slowAppender = MemoryAppender();
    logger1.appenders = [slowAppender];
    logger2.appenders = [slowAppender];
    
    // Execute
    logger2.info{ NSThread.sleepForTimeInterval(0.2); return "1"; };
    logger1.info{ NSThread.sleepForTimeInterval(0.1); return "2"; };
    logger2.info{ NSThread.sleepForTimeInterval(0.2); return "3"; };
    logger1.info{ NSThread.sleepForTimeInterval(0.1); return "4"; };
    
    self.waitUntilTrue{slowAppender.logMessages.count == 4};
    
    // Validate
    let expectedOrderedMessages: [LoggedMessage] = [
      ("1", .Info),
      ("2", .Info),
      ("3", .Info),
      ("4", .Info)];
    
    XCTAssertEqual(slowAppender.logMessages.count, expectedOrderedMessages.count, "All messages were not logged");
    for index in 0...expectedOrderedMessages.count - 1 {
      XCTAssertTrue(slowAppender.logMessages[index] == expectedOrderedMessages[index], "Order of logged messages is not correct");
    }
  }
  
  //MARK: private methods
  
  private func waitUntilTrue(conditionClosure: () -> Bool) {
    let timeout = 5.0;
    let loopDelay = 0.1
    var loopCounter = 0;
    while(conditionClosure() == false && timeout > (loopDelay * Double(loopCounter))) {
      NSThread.sleepForTimeInterval(loopDelay);
      loopCounter += 1;
    }
  }
}
