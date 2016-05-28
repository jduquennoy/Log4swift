//
//  PatternFormatter.swift
//  Log4swift
//
//  Created by Jérôme Duquennoy on 18/06/2015.
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
The PatternFormatter will format the message according to a given pattern.
The pattern is a regular string, with markers prefixed by '%', that might be passed options encapsulated in '{}'.
When the 'padding' option is provided, positive values left-justify that field to the specified width, negative values
right-justify it to the specified width.
Use '%%' to print a '%' character in the formatted message.
Available markers are :
* l{'padding': 'padding value'} : The name of the log level.
* n{'padding': 'padding value'} : The name of the logger.
* d{'padding': 'padding value', 'format': 'format specifier'} : The date of the log. The format specifier is the one of the strftime function.
* D{'padding': 'padding value', 'format': 'format specifier'} : The date of the log. The format specifier is the one of NSDateFormatter.dateFormat (see also http://www.unicode.org/reports/tr35/tr35-31/tr35-dates.html#Date_Format_Patterns).
* L{'padding': 'padding value'} : the number of the line where the log was issued
* F{'padding': 'padding value'} : the name of the file where the log was issued
* f{'padding': 'padding value'} : the name of the file where the log was issued without the full path
* M{'padding': 'padding value'} : the name of the function in which the log was issued
* t{'padding': 'padding value'} : the id of the current thread as hexadecimal
* T{'padding': 'padding value'} : the name of the current thread or GCD queue
* m{'padding': 'padding value'} : the message
* % : the '%' character

**Examples**  
"[%p] %m" -> "[Debug] log message"
*/
@objc public final class PatternFormatter: NSObject, Formatter {
  /// Definition of errors the PatternFormatter can throw
  public enum Error : ErrorType {
    case InvalidFormatSyntax
    case NotClosedMarkerParameter
  }
  
  /// Definition of the keys that will be used when initializing a PatternFormatter with a dictionary.
  public enum DictionaryKey: String {
    case Pattern = "Pattern"
  }
  
  public let identifier: String
  
  typealias FormattingClosure = (message: String, infos: LogInfoDictionary, dateFormatter: NSDateFormatter) -> String
  private var formattingClosuresSequence = [FormattingClosure]()
  
  private let dateFormatter: NSDateFormatter
  
  /// This initialiser will throw an error if the pattern is not valid.
  public init(identifier: String, pattern: String) throws {
    self.identifier = identifier
    self.dateFormatter = NSDateFormatter()
    let parser = PatternParser()
    super.init()
    self.formattingClosuresSequence = try parser.parsePattern(pattern)
  }

  public required convenience init(_ identifier: String) {
    try! self.init(identifier: identifier, pattern: "%m")
  }
  
  /// This initialiser will create a PatternFormatter with the informations provided as a dictionnary.
  /// It will throw an error if a mandatory parameter is missing of if the pattern is invalid.
  public func updateWithDictionary(dictionary: Dictionary<String, AnyObject>) throws {
    if let safePattern = (dictionary[DictionaryKey.Pattern.rawValue] as? String) {
      let parser = PatternParser()
      self.formattingClosuresSequence = try parser.parsePattern(safePattern)
    } else {
      throw NSError.Log4swiftErrorWithDescription("Missing '\(DictionaryKey.Pattern.rawValue)' parameter for pattern formatter '\(self.identifier)'")
    }
  }
  
  public func format(message: String, info: LogInfoDictionary) -> String {
    return formattingClosuresSequence.reduce("") { (accumulatedValue, currentItem) in accumulatedValue + currentItem(message: message, infos: info, dateFormatter: dateFormatter) }
  }
  
  private class PatternParser {
    typealias MarkerClosure = (parameters: [String:AnyObject], message: String, info: LogInfoDictionary, dateFormatter: NSDateFormatter) -> String
    // This dictionary matches a markers (one letter) with its logic (the closure that will return the value of the marker.  
    // Add an entry to this array to declare a new marker.
    private let markerClosures: Dictionary<String, MarkerClosure> = [
      "d": {(parameters, message, info, dateFormatter) in
        let result: String
        let format = parameters["format"] as? String ?? "%F %T"
        let timestamp = info[.Timestamp] as? Double ?? getSecondsSince1970(withoutMacroSeconds: true)
        var secondsSinceEpoch = Int(timestamp)
        let date = withUnsafePointer(&secondsSinceEpoch) {
          localtime($0)
        }
        let buffer = UnsafeMutablePointer<Int8>.alloc(80)
        strftime(buffer, 80, format , date)
        result = NSString(bytes: buffer, length: Int(strlen(buffer)), encoding: NSUTF8StringEncoding) as! String
        buffer.destroy()

        return processCommonParameters(result, parameters: parameters)
      },
      "D": {(parameters, message, info, dateFormatter) in
        let result: String
        let format = parameters["format"] as? String ?? "yyyy-MM-dd HH:mm:ss.SSS"
        let timestamp = info[.Timestamp] as? Double ?? getSecondsSince1970()
        let date = NSDate(timeIntervalSince1970: timestamp)
        dateFormatter.dateFormat = format
        result = dateFormatter.stringFromDate(date)
        
        return processCommonParameters(result, parameters: parameters)
      },
      "l": {(parameters, message, info, dateFormatter) in
        let logLevel = info[.LogLevel] ?? "-"
        return processCommonParameters(logLevel, parameters: parameters)
      },
      "n": {(parameters, message, info, dateFormatter) in
        let loggerName = info[.LoggerName] ?? "-"
        return processCommonParameters(loggerName, parameters: parameters)
      },
      "L": {(parameters, message, info, dateFormatter) in
        let line = info[.FileLine] ?? "-"
        return processCommonParameters(line, parameters: parameters)
      },
      "F": {(parameters, message, info, dateFormatter) in
        let filename = info[.FileName] ?? "-"
        return processCommonParameters(filename, parameters: parameters)
      },
      "f": {(parameters, message, info, dateFormatter) in
        let filename = NSString(string: (info[.FileName] as? String ?? "-")).lastPathComponent
        return processCommonParameters(filename, parameters: parameters)
      },
      "M": {(parameters, message, info, dateFormatter) in
        let function = info[.Function] ?? "-"
        return processCommonParameters(function, parameters: parameters)
      },
      "m": {(parameters, message, info, dateFormatter) in
        processCommonParameters(message as String, parameters: parameters)
      },
      "t": {(parameters, message, info, dateFormatter) in
        let tid = String(GetThreadID(pthread_self()), radix: 16, uppercase: false)
        return processCommonParameters(tid, parameters: parameters)
      },
      "T": {(parameters, message, info, dateFormatter) in
        let tname = threadName()
        return processCommonParameters(tname, parameters: parameters)
      },
      "%": {(parameters, message, info, dateFormatter) in "%" }
    ]
    
    
    // MARK: Formater parser state machine
    // This machine has two main methods :
    // - parsePattern : the main loop, that iterates on the characters of the pattern
    // - setParserState : the method that applies the logic when switching from one state to another.
    private enum ParserState {
      case Text
      case Marker
      case PostMarker(String)
      case Parameters(String)
      case End
    }
    
    private struct ParserStatus {
      var machineState = ParserState.Text
      var charactersAccumulator = [Character]()
      
      func getParameterValues() throws -> [String:AnyObject] {
        do {
          return try ("{" + String(charactersAccumulator) + "}").toDictionary()
        }
      }
    }
    
    private var parserStatus = ParserStatus()
    private var parsedClosuresSequence = [FormattingClosure]()
    
    // Converts a textual pattern into a sequence of closure that can be executed to render a messaage.
    private func parsePattern(pattern: String) throws -> [FormattingClosure] {
      parsedClosuresSequence = [FormattingClosure]()
      
      for currentCharacter in pattern.characters
      {
        switch(parserStatus.machineState) {
        case .Text where currentCharacter == "%":
          try setParserState(.Marker)
        case .Text:
          parserStatus.charactersAccumulator.append(currentCharacter)
          
        case .Marker:
          try setParserState(.PostMarker(String(currentCharacter)))
          
        case .PostMarker(let markerName) where currentCharacter == "{":
          try setParserState(.Parameters(markerName))
        case .PostMarker:
          try setParserState(.Text)
          parserStatus.charactersAccumulator.append(currentCharacter)
          
        case .Parameters where currentCharacter == "}":
          try setParserState(.Text)
        case .Parameters:
          parserStatus.charactersAccumulator.append(currentCharacter)
        case .End:
          throw Error.InvalidFormatSyntax
        }
      }
      try setParserState(.End)
      
      return parsedClosuresSequence
    }
    
    private func setParserState(newState: ParserState) throws {
      switch(parserStatus.machineState) {
      case .Text where parserStatus.charactersAccumulator.count > 0:
        let parsedString = String(parserStatus.charactersAccumulator)
        if(!parsedString.isEmpty) {
          parsedClosuresSequence.append({(_, _, _ ) in return parsedString})
          parserStatus.charactersAccumulator.removeAll()
        }
      case .PostMarker(let markerName):
        switch(newState) {
        case .Text, .End:
          parserStatus.charactersAccumulator.removeAll()
          processMarker(markerName)
        case .Parameters:
          break
        default:
          break
        }
        
      case .Parameters(let markerName):
        switch(newState) {
        case .End:
          throw Error.NotClosedMarkerParameter
        default:
          do {
            try processMarker(markerName, parameters: parserStatus.getParameterValues())
          }
          catch {
            throw Error.InvalidFormatSyntax
          }

          parserStatus.charactersAccumulator.removeAll()
        }
      default:
        break
      }
      parserStatus.machineState = newState
    }
    
    private func processMarker(markerName: String, parameters: [String:AnyObject] = [:]) {
      if let closureForMarker = markerClosures[markerName] {
        parsedClosuresSequence.append({(message, info, dateFormatter) in closureForMarker(parameters: parameters, message: message, info: info, dateFormatter: dateFormatter) })
      } else {
        parserStatus.charactersAccumulator += "%\(markerName)".characters
      }
    }
  }
}


/// Processes common parameters such as 'padding'.
/// - parameter value: The string value
/// - parameter parameters: Dictionary of formatting key/values
///
/// - returns: The processed value
func processCommonParameters(value: CustomStringConvertible, parameters: [String:AnyObject]) -> String
{
  var width: Int = 0

  if let widthString = parameters["padding"] as? NSString {
    width = widthString.integerValue
  }

  return value.description.padToWidth(width)
}

/// Returns the number of seconds between 1970-01-01 00:00:00 UTC and the current date and time in the integral part of the double.
/// The fractional part of the double contains the current macroseconds unless withoutMacroSeconds is true, in which case the fractional part is 0
func getSecondsSince1970(withoutMacroSeconds withoutMacroSeconds: Bool = false) -> Double {
  var time: timeval = timeval(tv_sec: 0, tv_usec: 0)
  gettimeofday(&time, nil)
  
  if (withoutMacroSeconds) {
    return Double(time.tv_sec)
  }
  
  return Double(time.tv_sec) + (Double(time.tv_usec) / 1000000.0)
}


/// returns the current thread name
private func threadName() -> String {
  if NSThread.isMainThread() {
    return "main"
  } else {
    if let threadName = NSThread.currentThread().name where !threadName.isEmpty {
      return threadName
    } else if let queueName = String(UTF8String: dispatch_queue_get_label(DISPATCH_CURRENT_QUEUE_LABEL)) where !queueName.isEmpty {
      return queueName
    } else {
      return String(format: "%p", NSThread.currentThread())
    }
  }
}
