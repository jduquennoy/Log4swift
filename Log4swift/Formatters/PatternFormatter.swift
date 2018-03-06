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
* t{'padding': 'padding value'} : the id of the current thread in hexadecimal
* T{'padding': 'padding value'} : the name of the current thread or GCD queue
* p{'padding': 'padding value'} : the id of the current process in hexadecimal
* m{'padding': 'padding value'} : the message
* % : the '%' character

**Examples**  
"[%p] %m" -> "[Debug] log message"
*/
@objc public final class PatternFormatter: NSObject, Formatter {
  /// Definition of errors the PatternFormatter can throw
  public enum FormatterError : Error {
    case InvalidFormatSyntax
    case NotClosedMarkerParameter
  }
  
  /// Definition of the keys that will be used when initializing a PatternFormatter with a dictionary.
  public enum DictionaryKey: String {
    case Pattern = "Pattern"
  }
  
  public let identifier: String
  
  typealias FormattingClosure = (_ message: String, _ infos: LogInfoDictionary) -> String
  private var formattingClosuresSequence = [FormattingClosure]()
  
  /// This initialiser will throw an error if the pattern is not valid.
  public init(identifier: String, pattern: String) throws {
    self.identifier = identifier
    let parser = PatternParser()
    super.init()
    self.formattingClosuresSequence = try parser.parsePattern(pattern)
  }

  public required convenience init(_ identifier: String) {
    try! self.init(identifier: identifier, pattern: "%m")
  }
  
  /// This initialiser will create a PatternFormatter with the informations provided as a dictionnary.
  /// It will throw an error if a mandatory parameter is missing of if the pattern is invalid.
	public func update(withDictionary dictionary: Dictionary<String, Any>) throws {
    if let safePattern = (dictionary[DictionaryKey.Pattern.rawValue] as? String) {
      let parser = PatternParser()
      self.formattingClosuresSequence = try parser.parsePattern(safePattern)
    } else {
			throw NSError.Log4swiftError(description: "Missing '\(DictionaryKey.Pattern.rawValue)' parameter for pattern formatter '\(self.identifier)'")
    }
  }
  
  public func format(message: String, info: LogInfoDictionary) -> String {
    return formattingClosuresSequence.reduce("") { (accumulatedValue, currentItem) in accumulatedValue + currentItem(message, info) }
  }
  
  private class PatternParser {
    typealias MarkerClosure = (_ parameters: [String:AnyObject], _ message: String, _ info: LogInfoDictionary) -> String
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

    private static let processId = String(ProcessInfo.processInfo.processIdentifier, radix: 16, uppercase: false)

    private var parserStatus = ParserStatus()
    private var parsedClosuresSequence = [FormattingClosure]()
    
    // Converts a textual pattern into a sequence of closure that can be executed to render a messaage.
    fileprivate func parsePattern(_ pattern: String) throws -> [FormattingClosure] {
      parsedClosuresSequence = [FormattingClosure]()
      
      for currentCharacter in pattern
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
          throw FormatterError.InvalidFormatSyntax
        }
      }
      try setParserState(.End)
      
      return parsedClosuresSequence
    }
    
    private func setParserState(_ newState: ParserState) throws {
      switch(parserStatus.machineState) {
      case .Text where parserStatus.charactersAccumulator.count > 0:
        let parsedString = String(parserStatus.charactersAccumulator)
        if(!parsedString.isEmpty) {
          parsedClosuresSequence.append({(_, _ ) in return parsedString})
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
          throw FormatterError.NotClosedMarkerParameter
        default:
          do {
            try processMarker(markerName, parameters: parserStatus.getParameterValues())
          }
          catch {
            throw FormatterError.InvalidFormatSyntax
          }

          parserStatus.charactersAccumulator.removeAll()
        }
      default:
        break
      }
      parserStatus.machineState = newState
    }
    
    private func processMarker(_ markerName: String, parameters: [String:AnyObject] = [:]) {
      if let closureForMarker = self.closureForMarker(markerName, parameters: parameters) {
        parsedClosuresSequence.append({(message, info) in closureForMarker(parameters, message, info) })
      } else {
        parserStatus.charactersAccumulator += "%\(markerName)"
      }
    }
    
    // This method is a factory that will generate a closure for a markers (one letter) and its parameters.
    // Add an entry to this switch to create a new marker.
    private func closureForMarker(_ marker: String, parameters: [String:AnyObject]) -> MarkerClosure? {
      let generatedClosure: MarkerClosure?
      
      switch(marker) {
      case "d":
        generatedClosure = {(parameters, message, info) in
          let result: String
          let format = parameters["format"] as? String ?? "%F %T"
          let timestamp = info[.Timestamp] as? TimeInterval ?? NSDate().timeIntervalSince1970
          var secondsSinceEpoch = Int(timestamp)
          let date = withUnsafePointer(to: &secondsSinceEpoch) {
            localtime($0)
          }
          let buffer = UnsafeMutablePointer<Int8>.allocate(capacity: 80)
          strftime(buffer, 80, format , date)
          result = String(bytesNoCopy: buffer, length: strlen(buffer), encoding: .utf8, freeWhenDone: true) ?? "error"
          
          return processCommonParameters(result, parameters: parameters)
        }
      case "D":
        let format = parameters["format"] as? String ?? "yyyy-MM-dd HH:mm:ss.SSS"
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        generatedClosure = {(parameters, message, info) in
          let result: String
          let date: Date
          if let timestamp = info[.Timestamp] as? Double {
            date = Date(timeIntervalSince1970: timestamp)
          } else {
            date = Date()
          }
          result = dateFormatter.string(from: date)
          
          return processCommonParameters(result, parameters: parameters)
        }
      case "l":
        generatedClosure = {(parameters, message, info) in
          let logLevel = info[.LogLevel] ?? "-"
          return processCommonParameters(logLevel, parameters: parameters)
        }
      case "n":
        generatedClosure = {(parameters, message, info) in
          let loggerName = info[.LoggerName] ?? "-"
          return processCommonParameters(loggerName, parameters: parameters)
        }
      case "L":
        generatedClosure = {(parameters, message, info) in
          let line = info[.FileLine] ?? "-"
          return processCommonParameters(line, parameters: parameters)
        }
      case "F":
        generatedClosure = {(parameters, message, info) in
          let filename = info[.FileName] ?? "-"
          return processCommonParameters(filename, parameters: parameters)
        }
      case "f":
        generatedClosure = {(parameters, message, info) in
          let filename = NSString(string: (info[.FileName] as? String ?? "-")).lastPathComponent
          return processCommonParameters(filename, parameters: parameters)
        }
      case "M":
        generatedClosure = {(parameters, message, info) in
          let function = info[.Function] ?? "-"
          return processCommonParameters(function, parameters: parameters)
        }
      case "t":
        generatedClosure = {(parameters, message, info) in
          let threadId: String
          if let tid = info[.ThreadId] as? UInt64 {
            threadId = String(tid, radix: 16, uppercase: false)
          }
          else {
            threadId = "-"
          }
          return processCommonParameters(threadId, parameters: parameters)
        }
      case "T":
        generatedClosure = {(parameters, message, info) in
          let threadName = info[.ThreadName] ?? "-"
          return processCommonParameters(threadName, parameters: parameters)
        }
      case "m":
        generatedClosure = {(parameters, message, info) in
          processCommonParameters(message as String, parameters: parameters)
        }
      case "p":
        generatedClosure = {(parameters, _, _) in
          return processCommonParameters(PatternParser.processId, parameters: parameters)
        }
      case "%":
        generatedClosure = {(parameters, message, info) in "%" }
      default:
        generatedClosure = nil
      }
      
      return generatedClosure
    }
  }
}


/// Processes common parameters such as 'padding'.
/// - parameter value: The string value
/// - parameter parameters: Dictionary of formatting key/values
///
/// - returns: The processed value
func processCommonParameters(_ value: CustomStringConvertible, parameters: [String:AnyObject]) -> String
{
  var width: Int = 0

  if let widthString = parameters["padding"] as? NSString {
    width = widthString.integerValue
  }

	return value.description.pad(toWidth: width)
}
