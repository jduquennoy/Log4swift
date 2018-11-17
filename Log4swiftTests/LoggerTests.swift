 //
//  LoggerTests.swift
//  log4swift
//
//  Created by Jérôme Duquennoy on 14/06/2015.
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

class LoggerTests: XCTestCase {
  
  override func setUp() {
    super.setUp()
    LoggerFactory.sharedInstance.resetConfiguration()
  }
  
  override func tearDown() {
    super.tearDown()
  }

  //MARK: Defaults
  
  func testLoggerDefaultLevelIsDebug() {
    let logger = Logger()
    
    XCTAssertEqual(logger.thresholdLevel , LogLevel.Debug, "Default log level for loggers should be Debug")
  }
  
  func testLoggerHasNoParentByDefault() {
    let logger = Logger()
    
    XCTAssertNil(logger.parent, "Logger should have not parentIdentifier by default")
  }
  
  //MARK: Log closure
  
  func testLogWithClosureWillCallClosureIfNoThresholdPreventsLogging() {
    var closureCalled = false
    let logger = Logger()
    
    logger.thresholdLevel = .Info
    
    // Execute
    logger.fatal(closure: {
      closureCalled = true
      return ""
    })
    
    // Validate
    XCTAssertTrue(closureCalled)
  }
  
  func testLogWithClosureWillNotCallClosureIfLoggerThresholdsPreventsLogging() {
    var closureCalled = false
    let logger = Logger()
    
    logger.thresholdLevel = .Info
    
    // Execute
    logger.debug(closure: {
      closureCalled = true
      return ""
    })
    
    // Validate
    XCTAssertFalse(closureCalled, "Closure should not be call if logger threshold is not reached")
  }
  
  func testLogWithClosureWorksWithTrailingClosure() {
    var closureCalled = false
    let logger = Logger()
    
    logger.thresholdLevel = .Info
    
    // Execute
    logger.info {
      closureCalled = true
      return ""
    }
    
    // Validate
    XCTAssertTrue(closureCalled)
  }
  
  func testLogWithClosureWillNotCallClosureIfAppendersThresholdsPreventsLogging() {
    var closureCalled = false
    let logger = Logger()
    let appender1 = MemoryAppender()
    let appender2 = MemoryAppender()
    
    appender1.thresholdLevel = .Info
    appender2.thresholdLevel = .Info
    logger.appenders = [appender1, appender2]
    
    // Execute
    logger.debug(closure: {
      closureCalled = true
      return ""
    })
    
    // Validate
    XCTAssertFalse(closureCalled, "Closure should not be call if no appender threshold is reached")
  }
  
  func testLogWithClosureWillCallClosureIfLogWillBeIssuedByAtLeastOneAppender() {
    var closureCalled = false
    let logger = Logger()
    let appender1 = MemoryAppender()
    let appender2 = MemoryAppender()
    
    appender1.thresholdLevel = .Info
    appender2.thresholdLevel = .Debug
    logger.appenders = [appender1, appender2]
    
    // Execute
    logger.debug {
      closureCalled = true
      return ""
    }
    
    // Validate
    XCTAssertTrue(closureCalled, "Closure should have been called")
  }
  
  //MARK: Static log methods

  func testStaticLogTraceMessageMethodsLogToRootLogger() {
    let memoryAppender = MemoryAppender()
    memoryAppender.thresholdLevel = .Trace

    LoggerFactory.sharedInstance.rootLogger.appenders.removeAll()
    LoggerFactory.sharedInstance.rootLogger.appenders.append(memoryAppender)
    LoggerFactory.sharedInstance.rootLogger.thresholdLevel = .Trace

    //Execute
    Logger.trace("ping")

    // Validate
    XCTAssertEqual(memoryAppender.logMessages.count, 1)
    XCTAssertEqual(memoryAppender.logMessages[0].level, LogLevel.Trace)
  }

  func testStaticLogDebugMessageMethodsLogToRootLogger() {
    let memoryAppender = MemoryAppender()
    LoggerFactory.sharedInstance.rootLogger.appenders.removeAll()
    LoggerFactory.sharedInstance.rootLogger.appenders.append(memoryAppender)
    
    //Execute
    Logger.debug("ping")
    
    // Validate
    XCTAssertEqual(memoryAppender.logMessages.count, 1)
    XCTAssertEqual(memoryAppender.logMessages[0].level, LogLevel.Debug)
  }
  
  func testStaticLogInfoMessageMethodsLogToRootLogger() {
    let memoryAppender = MemoryAppender()
    LoggerFactory.sharedInstance.rootLogger.appenders.removeAll()
    LoggerFactory.sharedInstance.rootLogger.appenders.append(memoryAppender)
    
    //Execute
    Logger.info("ping")
    
    // Validate
    XCTAssertEqual(memoryAppender.logMessages.count, 1)
    XCTAssertEqual(memoryAppender.logMessages[0].level, LogLevel.Info)
  }
  
  func testStaticLogWarningMessageMethodsLogToRootLogger() {
    let memoryAppender = MemoryAppender()
    LoggerFactory.sharedInstance.rootLogger.appenders.removeAll()
    LoggerFactory.sharedInstance.rootLogger.appenders.append(memoryAppender)
    
    //Execute
    Logger.warning("ping")
    
    // Validate
    XCTAssertEqual(memoryAppender.logMessages.count, 1)
    XCTAssertEqual(memoryAppender.logMessages[0].level, LogLevel.Warning)
  }
  
  func testStaticLogErrorMessageMethodsLogToRootLogger() {
    let memoryAppender = MemoryAppender()
    LoggerFactory.sharedInstance.rootLogger.appenders.removeAll()
    LoggerFactory.sharedInstance.rootLogger.appenders.append(memoryAppender)
    
    //Execute
    Logger.error("ping")
    
    // Validate
    XCTAssertEqual(memoryAppender.logMessages.count, 1)
    XCTAssertEqual(memoryAppender.logMessages[0].level, LogLevel.Error)
  }
  
  func testStaticLogFatalMessageMethodsLogToRootLogger() {
    let memoryAppender = MemoryAppender()
    LoggerFactory.sharedInstance.rootLogger.appenders.removeAll()
    LoggerFactory.sharedInstance.rootLogger.appenders.append(memoryAppender)
    
    //Execute
    Logger.fatal("ping")
    
    // Validate
    XCTAssertEqual(memoryAppender.logMessages.count, 1)
    XCTAssertEqual(memoryAppender.logMessages[0].level, LogLevel.Fatal)
  }

  func testStaticLogTraceClosureMethodsLogToRootLogger() {
    let memoryAppender = MemoryAppender()
    memoryAppender.thresholdLevel = .Trace

    LoggerFactory.sharedInstance.rootLogger.appenders.removeAll()
    LoggerFactory.sharedInstance.rootLogger.appenders.append(memoryAppender)
    LoggerFactory.sharedInstance.rootLogger.thresholdLevel = .Trace

    //Execute
    Logger.trace{ return "ping"; }

    // Validate
    XCTAssertEqual(memoryAppender.logMessages.count, 1)
    XCTAssertEqual(memoryAppender.logMessages[0].level, LogLevel.Trace)
  }

  func testStaticLogDebugClosureMethodsLogToRootLogger() {
    let memoryAppender = MemoryAppender()
    LoggerFactory.sharedInstance.rootLogger.appenders.removeAll()
    LoggerFactory.sharedInstance.rootLogger.appenders.append(memoryAppender)
    
    //Execute
    Logger.debug{ return "ping"; }
    
    // Validate
    XCTAssertEqual(memoryAppender.logMessages.count, 1)
    XCTAssertEqual(memoryAppender.logMessages[0].level, LogLevel.Debug)
  }
  
  func testStaticLogInfoClosureMethodsLogToRootLogger() {
    let memoryAppender = MemoryAppender()
    LoggerFactory.sharedInstance.rootLogger.appenders.removeAll()
    LoggerFactory.sharedInstance.rootLogger.appenders.append(memoryAppender)
    
    //Execute
    Logger.info{ return "ping"; }
    
    // Validate
    XCTAssertEqual(memoryAppender.logMessages.count, 1)
    XCTAssertEqual(memoryAppender.logMessages[0].level, LogLevel.Info)
  }
  
  func testStaticLogWarningClosureMethodsLogToRootLogger() {
    let memoryAppender = MemoryAppender()
    LoggerFactory.sharedInstance.rootLogger.appenders.removeAll()
    LoggerFactory.sharedInstance.rootLogger.appenders.append(memoryAppender)
    
    //Execute
    Logger.warning{ return "ping"; }
    
    // Validate
    XCTAssertEqual(memoryAppender.logMessages.count, 1)
    XCTAssertEqual(memoryAppender.logMessages[0].level, LogLevel.Warning)
  }
  
  func testStaticLogErrorClosureMethodsLogToRootLogger() {
    let memoryAppender = MemoryAppender()
    LoggerFactory.sharedInstance.rootLogger.appenders.removeAll()
    LoggerFactory.sharedInstance.rootLogger.appenders.append(memoryAppender)
    
    //Execute
    Logger.error{ return "ping"; }
    
    // Validate
    XCTAssertEqual(memoryAppender.logMessages.count, 1)
    XCTAssertEqual(memoryAppender.logMessages[0].level, LogLevel.Error)
  }
  
  func testStaticLogFatalClosureMethodsLogToRootLogger() {
    let memoryAppender = MemoryAppender()
    LoggerFactory.sharedInstance.rootLogger.appenders.removeAll()
    LoggerFactory.sharedInstance.rootLogger.appenders.append(memoryAppender)
    
    //Execute
    Logger.fatal{ return "ping"; }
    
    // Validate
    XCTAssertEqual(memoryAppender.logMessages.count, 1)
    XCTAssertEqual(memoryAppender.logMessages[0].level, LogLevel.Fatal)
  }
  
  //MARK: Configuration from dictionary

  func testCreateLoggerFromDictionaryWithInvalidLevelThrowsError() {
    let dictionary: Dictionary<String, Any> = [LoggerFactory.DictionaryKey.Identifier.rawValue: "test.logger",
      Logger.DictionaryKey.ThresholdLevel.rawValue: "invalidLevel"]

    let logger = Logger(identifier: "testLogger")
    
    // Execute & Validate
    XCTAssertThrows { try logger.update(withDictionary: dictionary, availableAppenders: []) }
  }
  
  func testUpdateLoggerFromDictionaryWithValidLevelUsesProvidedValue() {
    let dictionary: Dictionary<String, Any> = [LoggerFactory.DictionaryKey.Identifier.rawValue: "test.logger",
      Logger.DictionaryKey.ThresholdLevel.rawValue: "info"];    
    
    let logger = Logger(identifier: "testLogger")
    
    // Execute
    try! logger.update(withDictionary: dictionary, availableAppenders: Array<Appender>())
    
    // Validate
    XCTAssertEqual(logger.thresholdLevel, LogLevel.Info)
  }

  func testUpdateLoggerFromDictionaryWithoutAppenderDoesNotChangeExistingAppenders() {
    let dictionary: Dictionary<String, Any> = [LoggerFactory.DictionaryKey.Identifier.rawValue: "test.logger",
      Logger.DictionaryKey.ThresholdLevel.rawValue: "info"]
    
    let logger = Logger(identifier: "testLogger")
    logger.appenders.append(MemoryAppender())
    logger.appenders.append(MemoryAppender())

    // Execute
    try! logger.update(withDictionary: dictionary, availableAppenders: Array<Appender>())
    
    // Validate
    XCTAssertEqual(logger.appenders.count, 2)
  }
  
  func testUpdateLoggerFromDictionaryWithEmptyAppendersArrayRemovesThem() {
    let dictionary: Dictionary<String, Any> = [LoggerFactory.DictionaryKey.Identifier.rawValue: "test.logger",
      Logger.DictionaryKey.ThresholdLevel.rawValue: "info",
    Logger.DictionaryKey.AppenderIds.rawValue: []]
    
    let logger = Logger(identifier: "testLogger")
    logger.appenders.append(MemoryAppender())
    logger.appenders.append(MemoryAppender())
    
    // Execute
    try! logger.update(withDictionary: dictionary, availableAppenders: Array<Appender>())
    
    // Validate
    XCTAssertEqual(logger.appenders.count, 0)
    
  }
  
  func testUpdateLoggerWithNotAvailableAppenderIdThrowsError() {
    let dictionary: Dictionary<String, Any> = [LoggerFactory.DictionaryKey.Identifier.rawValue: "test.logger",
    Logger.DictionaryKey.AppenderIds.rawValue: ["id1", "id2"]]
  
    let logger = Logger(identifier: "testLogger")
    
    // Execute
    XCTAssertThrows { try logger.update(withDictionary: dictionary, availableAppenders: Array<Appender>()) }
  }
  
  func testUpdateLoggerWithAsynchronousKeyAppliesKey() {
    let dictionary: Dictionary<String, Any> = [LoggerFactory.DictionaryKey.Identifier.rawValue: "test.logger",
      Logger.DictionaryKey.Asynchronous.rawValue: true]
    
    let logger = Logger(identifier: "testLogger")
    
    // Execute
    try! logger.update(withDictionary: dictionary, availableAppenders: Array<Appender>())
    
    // Validate
    XCTAssertTrue(logger.asynchronous)
  }
  
  func testUpdateLoggerWithExistingAppenderIdUsesThem() {
    let appender1 = StdOutAppender("id1")
    let appender2 = StdOutAppender("id2")
    
    let dictionary: Dictionary<String, Any> = [LoggerFactory.DictionaryKey.Identifier.rawValue: "test.logger",
    Logger.DictionaryKey.AppenderIds.rawValue: ["id1", "id2"]]
    
    let logger = Logger(identifier: "testLogger")
    logger.appenders.append(StdOutAppender("appenderThatShouldBeRemoved"))
    
    // Execute
    try! logger.update(withDictionary: dictionary, availableAppenders: [appender1, appender2])
  
    // Validate
    XCTAssertEqual(logger.appenders.count, 2)
    XCTAssertTrue(logger.appenders[0] === appender1)
    XCTAssertTrue(logger .appenders[1] === appender2)
  }
  
  //MARK: Misc
  
  func testCopyInitializerCreatesIdenticalLoggerWithNewIdentifierAndParentIdentifier() {
    let appender1 = StdOutAppender("id1")
    let logger1 = Logger(identifier: "test.logger", level: LogLevel.Info, appenders: [appender1])
    
    // Execute
    let logger2 = Logger(parentLogger: logger1, identifier: "test.logger2")
    
    // Validate
    XCTAssertEqual(logger2.identifier, "test.logger2")
    XCTAssertTrue(logger2.parent! === logger1)
    XCTAssertEqual(logger2.thresholdLevel, logger1.thresholdLevel)
    XCTAssertEqual(logger2.appenders.count, logger1.appenders.count)
    XCTAssertTrue(logger2.appenders[0] === logger1.appenders[0])
  }

  func testLoggerSendsLogToAllAppenders() {
    let appender1 = MemoryAppender()
    let appender2 = MemoryAppender()
    let logger = Logger(identifier: "test.logger", level: LogLevel.Debug, appenders: [appender1, appender2])
    
    // Execute
    logger.info("ping")
    
    // Validate
    XCTAssertEqual(appender1.logMessages.count, 1, "Appender 1 should have received one message")
    XCTAssertEqual(appender2.logMessages.count, 1, "Appender 2 should have received one message")
  }
  
  func testLoggerDoNotSendMessagesToAppendersIfLevelIsEqualToThreshold() {
    let appender = MemoryAppender()
    let logger = Logger(identifier: "test.logger", level: LogLevel.Warning, appenders: [appender])
    
    // Execute
    logger.warning("Info message")
    
    // Validate
    XCTAssertEqual(appender.logMessages.count, 1, "The message should have been sent to the appender")
  }
  
  func testLoggerDoNotSendMessagesToAppendersIfThresholdLevelIsNotReached() {
    let appender = MemoryAppender()
    let logger = Logger(identifier: "test.logger", level: LogLevel.Warning, appenders: [appender])
    
    // Execute
    logger.info("Info message")
    
    // Validate
    XCTAssertEqual(appender.logMessages.count, 0, "The message should not have been sent to the appender")
  }
  
  func testLoggerMethodsFormatsString() {
    let appender = MemoryAppender()
    appender.thresholdLevel = .Trace

    let logger = Logger(identifier: "test.logger", level: LogLevel.Trace, appenders: [appender])
    
    // Execute
		logger.trace("ping %@ %02x", "blabla", 12)
    logger.debug("ping %@ %02x", "blabla", 12)
    logger.info("ping %@ %02x", "blabla", 12)
    logger.warning("ping %@ %02x", "blabla", 12)
    logger.error("ping %@ %02x", "blabla", 12)
		logger.fatal("ping %@ %02x", "blabla", 12)
    
    // Validate
    XCTAssertEqual(appender.logMessages[0].message, "ping blabla 0c")
    XCTAssertEqual(appender.logMessages[1].message, "ping blabla 0c")
    XCTAssertEqual(appender.logMessages[2].message, "ping blabla 0c")
    XCTAssertEqual(appender.logMessages[3].message, "ping blabla 0c")
    XCTAssertEqual(appender.logMessages[4].message, "ping blabla 0c")
    XCTAssertEqual(appender.logMessages[5].message, "ping blabla 0c")
  }
  
  func testLoggerConvenienceMethodsFormatsMessages() {
    let appender = MemoryAppender()
    appender.thresholdLevel = .Trace

    LoggerFactory.sharedInstance.rootLogger.appenders = [appender]
    LoggerFactory.sharedInstance.rootLogger.thresholdLevel = .Trace

    // Execute
    Logger.trace("ping %@ %02x", "blabla", 12)
    Logger.debug("ping %@ %02x", "blabla", 12)
    Logger.info("ping %@ %02x", "blabla", 12)
    Logger.warning("ping %@ %02x", "blabla", 12)
    Logger.error("ping %@ %02x", "blabla", 12)
    Logger.fatal("ping %@ %02x", "blabla", 12)
    
    // Validate
    XCTAssertEqual(appender.logMessages[0].message, "ping blabla 0c")
    XCTAssertEqual(appender.logMessages[1].message, "ping blabla 0c")
    XCTAssertEqual(appender.logMessages[2].message, "ping blabla 0c")
    XCTAssertEqual(appender.logMessages[3].message, "ping blabla 0c")
    XCTAssertEqual(appender.logMessages[4].message, "ping blabla 0c")
    XCTAssertEqual(appender.logMessages[5].message, "ping blabla 0c")
  }
  
  //MARK: Parent relationship
  
  func testLoggerWithParentUsesParentThreshold() {
    let parentLogger = Logger(identifier: "parent.logger", level: .Info, appenders: [MemoryAppender()])
    let sonLogger = Logger(parentLogger: parentLogger, identifier: "son.logger")
    
    // Execute
    let threshold1 = sonLogger.thresholdLevel
    parentLogger.thresholdLevel = .Debug
    let threshold2 = sonLogger.thresholdLevel
    
    // Validate
    XCTAssertEqual(threshold1, LogLevel.Info)
    XCTAssertEqual(threshold2, LogLevel.Debug)
  }
  
  func testLoggerWithParentUsesParentAppenders() {
    let parentLogger = Logger(identifier: "parent.logger", level: .Info, appenders: [MemoryAppender()])
    let sonLogger = Logger(parentLogger: parentLogger, identifier: "son.logger")
    
    // Execute
    parentLogger.appenders.append(MemoryAppender())
    let appenders = sonLogger.appenders
    
    // Validate
    XCTAssertEqual(appenders.count, 2)
  }
  
  func testLoggerIsAsynchronousIfParentIsAsynchronous() {
    let parentLogger = Logger(identifier: "parent.logger", level: .Info, appenders: [MemoryAppender()])
    let sonLogger = Logger(parentLogger: parentLogger, identifier: "son.logger")
    
    parentLogger.asynchronous = true
    
    // Execute
    let sonIsAsynchronous = sonLogger.asynchronous
    
    // Validate
    XCTAssertTrue(sonIsAsynchronous)
  }
  
  func testChangingSonLoggerParameterBreakLinkWithParent() {
    let parentLogger = Logger(identifier: "parent.logger", level: .Info, appenders: [MemoryAppender()])
    let sonLogger = Logger(parentLogger: parentLogger, identifier: "son.logger")
    
    // Execute
    sonLogger.thresholdLevel = .Warning
    
    // Validate
    XCTAssertEqual(parentLogger.thresholdLevel, LogLevel.Info)
    XCTAssertEqual(sonLogger.thresholdLevel, LogLevel.Warning)
    XCTAssertNil(sonLogger.parent)
  }
  
  func testSettingSonLoggerAppendersArrayBreakLinkWithParent() {
    let parentLogger = Logger(identifier: "parent.logger", level: .Info, appenders: [MemoryAppender()])
    let sonLogger = Logger(parentLogger: parentLogger, identifier: "son.logger")
    
    // Execute
    sonLogger.appenders = [MemoryAppender(), MemoryAppender()]
    
    // Validate
    XCTAssertEqual(parentLogger.appenders.count, 1)
    XCTAssertEqual(sonLogger.appenders.count, 2)
    XCTAssertNil(sonLogger.parent)
  }

  
  func testSettingSonLoggerAsyncStatusBreakLinkWithParent() {
    let parentLogger = Logger(identifier: "parent.logger", level: .Info, appenders: [MemoryAppender()])
    let sonLogger = Logger(parentLogger: parentLogger, identifier: "son.logger")
    parentLogger.asynchronous = false
    
    // Execute
    sonLogger.asynchronous = true
    
    // Validate
    XCTAssertNil(sonLogger.parent)
    XCTAssertFalse(parentLogger.asynchronous)
    XCTAssertTrue(sonLogger.asynchronous)
  }
  
  func testLoggedTimeIsTakenWhenLogIsRequested() {
    let formatter = try! PatternFormatter(identifier:"testFormatter", pattern: "%d{'format':'%s'}")
    let appender = MemoryAppender()
    appender.thresholdLevel = .Debug
    appender.formatter = formatter
    let logger = Logger(identifier: "test.identifier", level: .Debug, appenders: [appender])
    
    // Execute
    let timestampBefore = Date().timeIntervalSince1970
		logger.debug {Thread.sleep(forTimeInterval: 2); return "This is a debug message";}
    
    // Validate
    if let loggedMessageTime = TimeInterval(appender.logMessages[0].message) {
      XCTAssertEqual(loggedMessageTime, timestampBefore, accuracy: 1.0)
    } else {
      XCTAssertTrue(false, "Could not read logged time")
    }
  }

  
  func testLoggingStringWithPercentAndNoParametersDoesNotCrash() {
    let appender = MemoryAppender()
    appender.thresholdLevel = .Debug
    let logger = Logger(identifier: "test.identifier", level: .Debug, appenders: [appender])
    
    // Execute
    logger.debug("test %s %d %2C log with missing parameter")
    
    // Validate
    // nothing to test, it should just not crash
  }
  
  func testLoggerLogsHexadecimalThreadId() {
    let formatter = try! PatternFormatter(identifier:"testFormatter", pattern: "%t %m")
    let appender = MemoryAppender()
    appender.thresholdLevel = .Debug
    appender.formatter = formatter
    
    let logger = Logger(identifier: "test.logger", level: LogLevel.Debug, appenders: [appender])
    let threadId = currentThreadId()
    let hexaThreadId = String(threadId, radix: 16, uppercase: false)

    // Execute
    logger.debug("ping")
    
    // Validate
    XCTAssert(threadId != 0, "Failed to get thread ID")
    XCTAssertEqual(appender.logMessages.first!.message, "\(hexaThreadId) ping")
  }
  
  func testLoggerLogsMainAsThreadName() {
    let formatter = try! PatternFormatter(identifier:"testFormatter", pattern: "%T %m")
    let appender = MemoryAppender()
    appender.thresholdLevel = .Debug
    appender.formatter = formatter
    
    let logger = Logger(identifier: "test.logger", level: LogLevel.Debug, appenders: [appender])
    
    // Execute
    logger.debug("ping")
    
    // Validate
    XCTAssertEqual(appender.logMessages[0].message, "main ping")
  }
  
  
  func testLoggerLogsNSThreadNameAndId() {
    @objc class MyThreadClass : NSObject {
      var logMessage = ""
      var threadId: UInt64 = 0
      
      @objc func loggingMethod(_ object: AnyObject?) {
        let formatter = try! PatternFormatter(identifier:"testFormatter", pattern: "%t %T %m")
        let appender = MemoryAppender()
        appender.thresholdLevel = .Debug
        appender.formatter = formatter
        
        let logger = Logger(identifier: "test.logger", level: LogLevel.Debug, appenders: [appender])
        
        // Execute
        logger.debug("ping")
        
        threadId = currentThreadId()
        logMessage = appender.logMessages[0].message
      }
    }
    

    let myInstance = MyThreadClass()
    
    let thread = Thread(target: myInstance, selector: #selector(myInstance.loggingMethod(_:)), object: nil)
    thread.name = "someThreadName"
    thread.stackSize = 4 * 4096
    thread.threadPriority = 0.75
    thread.start()

    // Using expectation causes a crash in that context, when running on xcode 10
    usleep(500)
    
    let threadId = String(myInstance.threadId, radix: 16, uppercase: false)
    
    // Validate
    XCTAssertEqual(myInstance.logMessage, "\(threadId) someThreadName ping")
  }
  
  
  func testLoggerLogsGCDQueueNameAndId() {
    var logMessage = ""
    var tid: UInt64 = 0

    let expectation = self.expectation(description: "logIssued")

    let gcdQueue = DispatchQueue(label: "someQueueName", attributes: .concurrent)

    gcdQueue.async {
      let formatter = try! PatternFormatter(identifier:"testFormatter", pattern: "%t %T %m")
      let appender = MemoryAppender()
      appender.thresholdLevel = .Debug
      appender.formatter = formatter

      let logger = Logger(identifier: "test.logger", level: LogLevel.Debug, appenders: [appender])

      // Execute
      logger.debug("ping")

      tid = currentThreadId()
      logMessage = appender.logMessages[0].message

      expectation.fulfill()
    }

    waitForExpectations(timeout: 1.0, handler: nil)
    
    let threadId = String(tid, radix: 16, uppercase: false)
    
    // Validate
    XCTAssertEqual(logMessage, "\(threadId) someQueueName ping")
  }

}

 class TestExpectation: XCTestExpectation {
  deinit {
    NSLog("######## deinit")
  }
 }
