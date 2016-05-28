//
//  Logger+objectiveC.swift
//  Log4swift
//
//  Created by Jérôme Duquennoy on 20/07/15.
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

import Foundation

/**
This extension of the Logger class adds logging methods that can be exported to objective-C.
There are multiple functions to accomodate the limitations of Objective-C (no default values for parameters notably).
*/
extension Logger {

  /// Logs a trace message. This method is meant to be used from Objective-C.
  /// When in swift, prefer the "trace" method.
  @objc public func logTrace(message: String) {
    self.log(message, level: LogLevel.Trace)
  }
  /// Logs a debug message. This method is meant to be used from Objective-C.
  /// When in swift, prefer the "debug" method.
  @objc public func logDebug(message: String) {
    self.log(message, level: LogLevel.Debug)
  }
  /// Logs a info message. This method is meant to be used from Objective-C.
  /// When in swift, prefer the "info" method.
  @objc public func logInfo(message: String) {
    self.log(message, level: LogLevel.Info)
  }
  /// Logs a warning message. This method is meant to be used from Objective-C.
  /// When in swift, prefer the "warning" method.
  @objc public func logWarning(message: String) {
    self.log(message, level: LogLevel.Warning)
  }
  /// Logs a error message. This method is meant to be used from Objective-C.
  /// When in swift, prefer the "error" method.
  @objc public func logError(message: String) {
    self.log(message, level: LogLevel.Error)
  }
  /// Logs a fatal message. This method is meant to be used from Objective-C.
  /// When in swift, prefer the "fatal" method.
  @objc public func logFatal(message: String) {
    self.log(message, level: LogLevel.Fatal)
  }
  /// Logs the entering of a function and its parameters with a trace level. This method is meant to be used from Objective-C.
  /// When in swift, prefer the "entering" method.
  @objc public func logEntering(args: [AnyObject]) {
    self.logEnteringInternal(objArgs: args)
  }
  /// Logs the exiting of a function and its return values with a trace level. This method is meant to be used from Objective-C.
  /// When in swift, prefer the "exiting" method.
  @objc public func logExiting(args: [AnyObject]) {
    self.logExitingInternal(objArgs: args)
  }
  /// Logs the message and the given values according to the argOutputLevel of the logger with a trace level. This method is meant to be used from Objective-C.
  /// When in swift, prefer the "values" method.
  @objc public func logValues(message: String, args: [AnyObject]) {
    self.logValuesInternal(message: message, objArgs: args)
  }

  /// Logs a trace message. This method is meant to be used in macros when using Objective-C, to provide the file, line and function using the __FILE__, __LINE__ and __FUNCTION__ macros.
  /// When in swift, prefer the "trace" method.
  @objc public func logTrace(message: String, file: String, line: Int, function: String) {
    self.log(message, level: LogLevel.Trace, file: file, line: line, function: function)
  }
  /// Logs a debug message. This method is meant to be used in macros when using Objective-C, to provide the file, line and function using the __FILE__, __LINE__ and __FUNCTION__ macros.
  /// When in swift, prefer the "debug" method.
  @objc public func logDebug(message: String, file: String, line: Int, function: String) {
    self.log(message, level: LogLevel.Debug, file: file, line: line, function: function)
  }
  /// Logs a info message. This method is meant to be used in macros when using Objective-C, to provide the file, line and function using the __FILE__, __LINE__ and __FUNCTION__ macros.
  /// When in swift, prefer the "info" method.
  @objc public func logInfo(message: String, file: String, line: Int, function: String) {
    self.log(message, level: LogLevel.Info, file: file, line: line, function: function)
  }
  /// Logs a warning message. This method is meant to be used in macros when using Objective-C, to provide the file, line and function using the __FILE__, __LINE__ and __FUNCTION__ macros.
  /// When in swift, prefer the "warning" method.
  @objc public func logWarning(message: String, file: String, line: Int, function: String) {
    self.log(message, level: LogLevel.Warning, file: file, line: line, function: function)
  }
  /// Logs a error message. This method is meant to be used in macros when using Objective-C, to provide the file, line and function using the __FILE__, __LINE__ and __FUNCTION__ macros.
  /// When in swift, prefer the "error" method.
  @objc public func logError(message: String, file: String, line: Int, function: String) {
    self.log(message, level: LogLevel.Error, file: file, line: line, function: function)
  }
  /// Logs a fatal message. This method is meant to be used in macros when using Objective-C, to provide the file, line and function using the __FILE__, __LINE__ and __FUNCTION__ macros.
  /// When in swift, prefer the "fatal" method.
  @objc public func logFatal(message: String, file: String, line: Int, function: String) {
    self.log(message, level: LogLevel.Fatal, file: file, line: line, function: function)
  }
  /// Logs the entering of a function and its parameters with a trace level. This method is meant to be used in macros when using Objective-C, to provide the file, line and function using the __FILE__, __LINE__ and __FUNCTION__ macros.
  /// When in swift, prefer the "entering" method.
  @objc public func logEntering(args: [AnyObject], file: String, line: Int, function: String) {
    logEnteringInternal(file: file, line: line, function: function, objArgs: args)
  }
  /// Logs the exiting of a function and its return values with a trace level. This method is meant to be used in macros when using Objective-C, to provide the file, line and function using the __FILE__, __LINE__ and __FUNCTION__ macros.
  /// When in swift, prefer the "exiting" method.
  @objc public func logExiting(args: [AnyObject], file: String, line: Int, function: String) {
    logExitingInternal(file: file, line: line, function: function, objArgs: args)
  }
  /// Logs the message and the given values according to the argOutputLevel of the logger with a trace level. This method is meant to be used in macros when using Objective-C, to provide the file, line and function using the __FILE__, __LINE__ and __FUNCTION__ macros.
  /// When in swift, prefer the "values" method.
  @objc public func logValues(message: String, args: [AnyObject], file: String, line: Int, function: String) {
    self.logValuesInternal(message: message, file: file, line: line, function: function, objArgs: args)
  }

  /// Logs a trace message. This method is meant to be used from Objective-C.
  /// When in swift, prefer the "trace" method.
  @objc public func logTraceBloc(closure:() -> (String)) {
    self.log(closure, level: LogLevel.Trace)
  }
  /// Logs a debug message. This method is meant to be used from Objective-C.
  /// When in swift, prefer the "debug" method.
  @objc public func logDebugBloc(closure:() -> (String)) {
    self.log(closure, level: LogLevel.Debug)
  }
  /// Logs info message. This method is meant to be used from Objective-C.
  /// When in swift, prefer the "info" method.
  @objc public func logInfoBloc(closure:() -> (String)) {
    self.log(closure, level: LogLevel.Info)
  }
  /// Logs a warning message. This method is meant to be used from Objective-C.
  /// When in swift, prefer the "warning" method.
  @objc public func logWarningBloc(closure:() -> (String)) {
    self.log(closure, level: LogLevel.Warning)
  }
  /// Logs a error message. This method is meant to be used from Objective-C.
  /// When in swift, prefer the "error" method.
  @objc public func logErrorBloc(closure:() -> (String)) {
    self.log(closure, level: LogLevel.Error)
  }
  /// Logs a fatal closure. This method is meant to be used from Objective-C.
  /// When in swift, prefer the "fatal" method.
  @objc public func logFatalBloc(closure:() -> (String)) {
    self.log(closure, level: LogLevel.Fatal)
  }
  /// Logs the entering of a function and its parameters with a trace level. This method is meant to be used from Objective-C.
  /// When in swift, prefer the "entering" method.
  @objc public func logEnteringBloc(closure: () -> [AnyObject]) {
    self.logEnteringInternal(closure: closure)
  }
  /// Logs the exiting of a function and its return values with a trace level. This method is meant to be used from Objective-C.
  /// When in swift, prefer the "exiting" method.
  @objc public func logExitingBloc(closure: () -> [AnyObject]) {
    self.logExitingInternal(closure: closure)
  }
  /// Logs the message and the given values according to the argOutputLevel of the logger with a trace level. This method is meant to be used from Objective-C.
  /// When in swift, prefer the "exiting" method.
  @objc public func logValuesBloc(message: String, closure: () -> [AnyObject]) {
    self.logValuesInternal(message: message, closure: closure)
  }

  /// Logs a trace message. This method is meant to be used in macros when using Objective-C, to provide the file, line and function using the __FILE__, __LINE__ and __FUNCTION__ macros.
  /// When in swift, prefer the "trace" method.
  @objc public func logTraceBloc(closure:() -> (String), file: String, line: Int, function: String) {
    self.log(closure, level: LogLevel.Trace, file: file, line: line, function: function)
  }
  /// Logs a debug message. This method is meant to be used in macros when using Objective-C, to provide the file, line and function using the __FILE__, __LINE__ and __FUNCTION__ macros.
  /// When in swift, prefer the "debug" method.
  @objc public func logDebugBloc(closure:() -> (String), file: String, line: Int, function: String) {
    self.log(closure, level: LogLevel.Debug, file: file, line: line, function: function)
  }
  /// Logs a info message. This method is meant to be used in macros when using Objective-C, to provide the file, line and function using the __FILE__, __LINE__ and __FUNCTION__ macros.
  /// When in swift, prefer the "info" method.
  @objc public func logInfoBloc(closure:() -> (String), file: String, line: Int, function: String) {
    self.log(closure, level: LogLevel.Info, file: file, line: line, function: function)
  }
  /// Logs a warning message. This method is meant to be used in macros when using Objective-C, to provide the file, line and function using the __FILE__, __LINE__ and __FUNCTION__ macros.
  /// When in swift, prefer the "warning" method.
  @objc public func logWarningBloc(closure:() -> (String), file: String, line: Int, function: String) {
    self.log(closure, level: LogLevel.Warning, file: file, line: line, function: function)
  }
  /// Logs a error message. This method is meant to be used in macros when using Objective-C, to provide the file, line and function using the __FILE__, __LINE__ and __FUNCTION__ macros.
  /// When in swift, prefer the "error" method.
  @objc public func logErrorBloc(closure:() -> (String), file: String, line: Int, function: String) {
    self.log(closure, level: LogLevel.Error, file: file, line: line, function: function)
  }
  /// Logs a fatal message. This method is meant to be used in macros when using Objective-C, to provide the file, line and function using the __FILE__, __LINE__ and __FUNCTION__ macros.
  /// When in swift, prefer the "fatal" method.
  @objc public func logFatalBloc(closure:() -> (String), file: String, line: Int, function: String) {
    self.log(closure, level: LogLevel.Fatal, file: file, line: line, function: function)
  }
  /// Logs the entering of a function and its parameters with a trace level. This method is meant to be used in macros when using Objective-C, to provide the file, line and function using the __FILE__, __LINE__ and __FUNCTION__ macros.
  /// When in swift, prefer the "entering" method.
  @objc public func logEnteringBloc(closure: () -> [AnyObject], file: String, line: Int, function: String) {
    self.logEnteringInternal(file: file, line: line, function: function, closure: closure)
  }
  /// Logs the exiting of a function and its return values with a trace level. This method is meant to be used in macros when using Objective-C, to provide the file, line and function using the __FILE__, __LINE__ and __FUNCTION__ macros.
  /// When in swift, prefer the "exiting" method.
  @objc public func logExitingBloc(closure: () -> [AnyObject], file: String, line: Int, function: String) {
    self.logExitingInternal(file: file, line: line, function: function, closure: closure)
  }
  /// Logs the message and the given values according to the argOutputLevel of the logger with a trace level. This method is meant to be used in macros when using Objective-C, to provide the file, line and function using the __FILE__, __LINE__ and __FUNCTION__ macros.
  /// When in swift, prefer the "exiting" method.
  @objc public func logValuesBloc(message: String, closure: () -> [AnyObject], file: String, line: Int, function: String) {
    self.logValuesInternal(message: message, file: file, line: line, function: function, closure: closure)
  }
}
