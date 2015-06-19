//
//  PatternFormatter.swift
//  Log4swift
//
//  Created by Jérôme Duquennoy on 18/06/2015.
//  Copyright © 2015 Jérôme Duquennoy. All rights reserved.
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

import Foundation

/**
The PatternFormatter will format the message according to a given pattern.
The pattern is a regular string, with markers prefixed by '%', that might be passed options encapsulated in '{}'.
Use '%%' to print a '%' character in the formatted message.
Available markers are :
* l : The name of the log level
* d : The date of the log
* m : the message

**Exemples**  
"[%p] %m" -> "[Debug] log message"
*/
public class PatternFormatter : Formatter {
  public enum FormatterError : ErrorType {
    case InvalidFormatSyntax
    case NotClosedMarkerParameter
  };
  
  typealias FormattingClosure = (message: String, infos: FormatterInfoDictionary) -> String;
  var formattingClosuresSequence = [FormattingClosure]();

  typealias MarkerClosure = (parameters: String?, message: String, info: FormatterInfoDictionary) -> String;
  let markerClosures : Dictionary<String, MarkerClosure> = [
    "d": {(parameters, message, info) in NSDate().description },
    "l": {(parameters, message, info) in
      if let logLevel = info[.LogLevel] {
        return logLevel.description
      } else {
        return "-";
      }
    },
    "n": {(parameters, message, info) in 
      if let loggerName = info[.LoggerName] {
        return loggerName.description;
      } else {
        return "-";
      }
    },
    "m": {(parameters, message, infos) in message },
    "%": {(parameters, message, infos) in return "%" }
  ];
  
  init(pattern: String) throws {
    try self.parsePattern(pattern);
  }
  
  func format(message: String, info: FormatterInfoDictionary) -> String {
    return formattingClosuresSequence.reduce("") { (accumulatedValue, currentItem) in accumulatedValue + currentItem(message: message, infos: info) };
  }

  // MARK: Formater parser state machine
  enum ParserState {
    case Text
    case Marker
    case PostMarker(String)
    case Parameters(String)
  };

  struct ParserStatus {
    var machineState = ParserState.Text;
    var charactersAccumulator = [Character]();
  };
  
  var parserStatus = ParserStatus();
  
  
  private func parsePattern(pattern: String) throws {
    for currentCharacter in pattern.characters
    {
      switch(parserStatus.machineState) {
      case .Text where currentCharacter == "%":
        setParserState(.Marker);
      case .Text:
        parserStatus.charactersAccumulator.append(currentCharacter);
        
      case .Marker:
        setParserState(.PostMarker(String(currentCharacter)));
        
      case .PostMarker(let markerName) where currentCharacter == "{":
        setParserState(.Parameters(markerName));
      case .PostMarker:
          setParserState(.Text);
          parserStatus.charactersAccumulator.append(currentCharacter);
        
      case .Parameters where currentCharacter == "}":
        setParserState(.Text);
      case .Parameters:
        parserStatus.charactersAccumulator.append(currentCharacter);
      }
    }
    switch(parserStatus.machineState) {
    case .PostMarker:
      setParserState(.Text); // to validated the last marker if any
    case .Text:
      break;
    case .Parameters:
      throw FormatterError.NotClosedMarkerParameter;
    default:
      throw FormatterError.InvalidFormatSyntax;
    }
  }
  
  private func setParserState(newState: ParserState) {
    switch(parserStatus.machineState) {
    case .Text where parserStatus.charactersAccumulator.count > 0:
      let parsedString = String(parserStatus.charactersAccumulator);
      if(!parsedString.isEmpty) {
        formattingClosuresSequence.append({(_, _ ) in return parsedString});
        parserStatus.charactersAccumulator.removeAll();
      }
    case .PostMarker(let markerName):
      switch(newState) {
      case .Text:
        parserStatus.charactersAccumulator.removeAll();
        processMarker(markerName);
      case .Parameters:
        break;
      default:
        break;
      }
    case .Parameters(let markerName):
      processMarker(markerName);
      parserStatus.charactersAccumulator.removeAll();
    default:
      break;
    }
    parserStatus.machineState = newState;
  }
  
  private func processMarker(markerName: String, parameters: String? = nil) {
    if let closureForMarker = markerClosures[markerName] {
      formattingClosuresSequence.append({(message, info) in closureForMarker(parameters: parameters, message: message, info: info) });
    } else {
      parserStatus.charactersAccumulator += "%\(markerName)".characters;
    }
  }
}