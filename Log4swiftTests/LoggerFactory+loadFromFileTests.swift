//
//  LoggerFactory+loadFromFileTests.swift
//  Log4swift
//
//  Created by Jérôme Duquennoy on 03/07/2015.
//  Copyright © 2015 jerome. All rights reserved.
//
// Log4swift is free software: you can redistribute it and/or modify
// it under the terms of the GNU Lesser General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// Log4swift is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU Lesser General Public License for more details.
//
// You should have received a copy of the GNU Lesser General Public License
// along with Foobar. If not, see <http://www.gnu.org/licenses/>.
//

import XCTest
@testable import Log4swift

class LoggerFactoryLoadFromFileTests: XCTestCase {
  
  // MARK: Formatters tests
  
  func testLoadDictionaryWithNoFormatterClassThrowsError() {
    let formattersDictionary = [PatternFormatter.DictionaryKey.Identifier.rawValue: "ping"];
    let dictionary = [LoggerFactory.DictionaryKey.Formatters.rawValue: [formattersDictionary]];
    
    // Execute & validate
    XCTAssertThrows { try LoggerFactory.sharedInstance.readConfiguration(dictionary) };
  }
  
  func testLoadDictionaryWithUnknownFormatterClassThrowsError() {
    let formattersDictionary = [LoggerFactory.DictionaryKey.ClassName.rawValue: "UnknownFormatterClass",
      PatternFormatter.DictionaryKey.Identifier.rawValue: "ping"];
    let dictionary = [LoggerFactory.DictionaryKey.Formatters.rawValue: [formattersDictionary]];
    
    // Execute & validate
    XCTAssertThrows { try LoggerFactory.sharedInstance.readConfiguration(dictionary) };
  }
  
  func testLoadDictionaryWithPatternFormatterClassCreatesRequestedFormatter() {
    let formattersDictionary = [LoggerFactory.DictionaryKey.ClassName.rawValue: "PatternFormatter",
      PatternFormatter.DictionaryKey.Identifier.rawValue: "test pattern formatter",
      PatternFormatter.DictionaryKey.Pattern.rawValue: "test pattern"];
    
    let dictionary = [LoggerFactory.DictionaryKey.Formatters.rawValue: [formattersDictionary]];
    
    // Execute
    let (formatters, _, _) = try! LoggerFactory.sharedInstance.readConfiguration(dictionary);
    
    // validate
    XCTAssertEqual(formatters.count, 1);
    XCTAssertEqual(classNameAsString(formatters[0]), "PatternFormatter");
    XCTAssertEqual(formatters[0].identifier, "test pattern formatter");
    
  }
  
  func testLoadDictionaryWithMultipleFormattersCreatesRequestedFormatters() {
    let formattersDictionary1 = [LoggerFactory.DictionaryKey.ClassName.rawValue: "PatternFormatter",
      PatternFormatter.DictionaryKey.Identifier.rawValue: "test pattern formatter 1",
      PatternFormatter.DictionaryKey.Pattern.rawValue: "test pattern"];
    let formattersDictionary2 = [LoggerFactory.DictionaryKey.ClassName.rawValue: "PatternFormatter",
      PatternFormatter.DictionaryKey.Identifier.rawValue: "test pattern formatter 2",
      PatternFormatter.DictionaryKey.Pattern.rawValue: "test pattern"];
    
    let dictionary = [LoggerFactory.DictionaryKey.Formatters.rawValue: [formattersDictionary1, formattersDictionary2]];
    
    // Execute
    let (formatters, _, _) = try! LoggerFactory.sharedInstance.readConfiguration(dictionary);
    
    // validate
    XCTAssertEqual(formatters.count, 2);
    XCTAssertEqual(formatters[0].identifier, "test pattern formatter 1");
    XCTAssertEqual(formatters[1].identifier, "test pattern formatter 2");
  }
  
  // MARK: Appenders tests
  
  func testLoadDictionaryWithNoAppenderThrowsError() {
    let appenderDictionary = [Appender.DictionaryKey.Identifier.rawValue: "test pattern formatter 2"];
    
    let dictionary = [LoggerFactory.DictionaryKey.Appenders.rawValue: [appenderDictionary]];
    
    // Execute
    XCTAssertThrows { try LoggerFactory.sharedInstance.readConfiguration(dictionary) };
  }
  
  func testLoadDictionaryWithUnknownAppenderThrowsError() {
    let appenderDictionary = [LoggerFactory.DictionaryKey.ClassName.rawValue: "UnknownAppenderClass",
      Appender.DictionaryKey.Identifier.rawValue: "test appender"];
    
    let dictionary = [LoggerFactory.DictionaryKey.Appenders.rawValue: [appenderDictionary]];
    
    // Execute
    XCTAssertThrows { try LoggerFactory.sharedInstance.readConfiguration(dictionary) };
  }
  
  func testLoadDictionaryWithConsoleAppenderAndFormatCreatesRequestedAppender() {
    let formattersDictionary = [LoggerFactory.DictionaryKey.ClassName.rawValue: "PatternFormatter",
      PatternFormatter.DictionaryKey.Identifier.rawValue: "test pattern",
      PatternFormatter.DictionaryKey.Pattern.rawValue: "test pattern"];
    let appenderDictionary = [LoggerFactory.DictionaryKey.ClassName.rawValue: "ConsoleAppender",
      Appender.DictionaryKey.Identifier.rawValue: "test appender",
      Appender.DictionaryKey.FormatterId.rawValue: "test pattern"];
    
    let dictionary = [LoggerFactory.DictionaryKey.Formatters.rawValue: [formattersDictionary],
      LoggerFactory.DictionaryKey.Appenders.rawValue: [appenderDictionary]];
    
    // Execute
    let (formatters, appenders, _) = try! LoggerFactory.sharedInstance.readConfiguration(dictionary);
    
    // Validate
    XCTAssertEqual(appenders.count, 1);
    XCTAssertEqual(formatters.count, 1);
    XCTAssertEqual(appenders[0].identifier, "test appender");
    XCTAssertEqual(appenders[0].formatter!.identifier, formatters[0].identifier);
  }
  
  func testLoadDictionaryWithMultipleAppendersAndFormatCreatesRequestedAppender() {
    let formattersDictionary1 = [LoggerFactory.DictionaryKey.ClassName.rawValue: "PatternFormatter",
      PatternFormatter.DictionaryKey.Identifier.rawValue: "formatter1",
      PatternFormatter.DictionaryKey.Pattern.rawValue: "test pattern"];
    let formattersDictionary2 = [LoggerFactory.DictionaryKey.ClassName.rawValue: "PatternFormatter",
      PatternFormatter.DictionaryKey.Identifier.rawValue: "formatter2",
      PatternFormatter.DictionaryKey.Pattern.rawValue: "test pattern"];
    let appenderDictionary1 = [LoggerFactory.DictionaryKey.ClassName.rawValue: "FileAppender",
      Appender.DictionaryKey.Identifier.rawValue: "appender1",
      Appender.DictionaryKey.FormatterId.rawValue: "formatter2",
      FileAppender.DictionaryKey.FilePath.rawValue: "/test/path"];
    let appenderDictionary2 = [LoggerFactory.DictionaryKey.ClassName.rawValue: "NSLoggerAppender",
      Appender.DictionaryKey.Identifier.rawValue: "appender2",
      Appender.DictionaryKey.FormatterId.rawValue: "formatter1",
      NSLoggerAppender.DictionaryKey.RemoteHost.rawValue: "remoteHost"];
    
    let dictionary = [LoggerFactory.DictionaryKey.Formatters.rawValue: [formattersDictionary1, formattersDictionary2],
      LoggerFactory.DictionaryKey.Appenders.rawValue: [appenderDictionary1, appenderDictionary2]];
    
    // Execute
    let (formatters, appenders, _) = try! LoggerFactory.sharedInstance.readConfiguration(dictionary);
    
    // Validate
    XCTAssertEqual(appenders.count, 2);
    XCTAssertEqual(formatters.count, 2);
    XCTAssertEqual(appenders[0].identifier, "appender1");
    XCTAssertEqual(appenders[0].formatter!.identifier, "formatter2");
    XCTAssertEqual(appenders[1].identifier, "appender2");
    XCTAssertEqual(appenders[1].formatter!.identifier, "formatter1");
  }
  
  // MARK: Utility methods
  
 private func classNameAsString(obj: Any) -> String {
    return _stdlib_getDemangledTypeName(obj).componentsSeparatedByString(".").last!
  }

}