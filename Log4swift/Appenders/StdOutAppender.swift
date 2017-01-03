//
//  StdOutAppender.swift
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

/**
StdOutAppender will print the log to stdout or stderr depending on thresholds and levels.
* If general threshold is reached but error threshold is undefined or not reached, log will be printed to stdout
* If both general and error threshold are reached, log will be printed to stderr
*/
public class StdOutAppender: Appender {
  public enum DictionaryKey: String {
    case ErrorThreshold = "ErrorThresholdLevel"
    case TextColors = "TextColors"
    case BackgroundColors = "BackgroundColors"
    case ForcedTTYType = "ForcedTTYType"
  }
  
  public enum TTYType {
    /// Xcode with XcodeColors plugin
    case XcodeColors
    /// xterm-256color terminal
    case XtermColor
    /// non color-compatible tty
    case Other

    init(_ name: String) {
      switch(name.lowercased()) {
      case "xterm" : self = .XtermColor
      case "xcodecolors" : self = .XcodeColors
      default: self = .Other
      }
    }
  }
  
  /// ttyType will determine what color codes should be used if colors are enabled.
  /// This is supposed to be automatically detected when creating the logger.
  /// Change that only if you need to override the automatic detection.
  public var ttyType: TTYType
  public var errorThresholdLevel: LogLevel? = .Error
  internal fileprivate(set) var textColors = [LogLevel: TTYColor]()
  internal fileprivate(set) var backgroundColors = [LogLevel: TTYColor]()
  
  public required init(_ identifier: String) {
    let xcodeColors = ProcessInfo().environment["XcodeColors"]
    let terminalType = ProcessInfo().environment["TERM"]
    switch (xcodeColors, terminalType) {
    case (.some("YES"), _):
      self.ttyType = .XcodeColors
    case (_, .some("xterm-256color")):
      self.ttyType = .XtermColor
    default:
      self.ttyType = .Other
    }
    
    super.init(identifier)
  }
  
  public override func update(withDictionary dictionary: Dictionary<String, Any>, availableFormatters: Array<Formatter>) throws {
    
		try super.update(withDictionary: dictionary, availableFormatters: availableFormatters)
    
    if let errorThresholdString = (dictionary[DictionaryKey.ErrorThreshold.rawValue] as? String) {
      if let errorThreshold = LogLevel(errorThresholdString) {
        errorThresholdLevel = errorThreshold
      } else {
				throw NSError.Log4swiftError(description: "Invalide '\(DictionaryKey.ErrorThreshold.rawValue)' value for Stdout appender '\(self.identifier)'")
      }
    } else {
      errorThresholdLevel = nil
    }
    
    if let textColors = (dictionary[DictionaryKey.TextColors.rawValue] as? Dictionary<String, String>) {
      for (levelName, colorName) in textColors {
        guard let level = LogLevel(levelName) else {
          throw NSError.Log4swiftError(description: "Invalide level '\(levelName)' in '\(DictionaryKey.TextColors.rawValue)' for Stdout appender '\(self.identifier)'")
        }
        guard let color = TTYColor(colorName) else {
          throw NSError.Log4swiftError(description: "Invalide color '\(colorName)' in '\(DictionaryKey.TextColors.rawValue)' for Stdout appender '\(self.identifier)'")
        }

        self.textColors[level] = color
      }
    }

    if let backgroundColors = (dictionary[DictionaryKey.BackgroundColors.rawValue] as? Dictionary<String, String>) {
      for (levelName, colorName) in backgroundColors {
        guard let level = LogLevel(levelName) else {
          throw NSError.Log4swiftError(description: "Invalide level '\(levelName)' in '\(DictionaryKey.BackgroundColors.rawValue)' for Stdout appender '\(self.identifier)'")
        }
        guard let color = TTYColor(colorName) else {
          throw NSError.Log4swiftError(description: "Invalide color '\(colorName)' in '\(DictionaryKey.BackgroundColors.rawValue)' for Stdout appender '\(self.identifier)'")
        }
        
        self.backgroundColors[level] = color
      }
    }
    
    if let forcedTtyType = (dictionary[DictionaryKey.ForcedTTYType.rawValue] as? String) {
      self.ttyType = TTYType(forcedTtyType)
    }
  }
  
  public override func performLog(_ log: String, level: LogLevel, info: LogInfoDictionary) {
    var destinationFile = stdout
    
    if let errorThresholdLevel = self.errorThresholdLevel {
      if(level.rawValue >= errorThresholdLevel.rawValue) {
        destinationFile  = stderr
      }
    }
    
		let finalLogString = self.colorizeLog(log: log, level: level) + "\n"
    fputs(finalLogString, destinationFile)
  }
  
}

// MARK: - Color management extension
extension StdOutAppender {
  public enum TTYColor {
    case Black
    case DarkGrey
    case Grey
    case LightGrey
    case White
    case LightRed
    case Red
    case DarkRed
    case LightGreen
    case Green
    case DarkGreen
    case LightBlue
    case Blue
    case DarkBlue
    case LightYellow
    case Yellow
    case DarkYellow
    case Purple
    case LightPurple
    case DarkPurple
    case LightOrange
    case Orange
    case DarkOrange
    
    init?(_ name: String) {
      switch(name.lowercased()) {
      case "black" : self = .Black
      case "darkgrey" : self = .DarkGrey
      case "grey" : self = .Grey
      case "lightgrey" : self = .LightGrey
      case "white" : self = .White
      case "lightred" : self = .LightRed
      case "red" : self = .Red
      case "darkred" : self = .DarkRed
      case "lightgreen" : self = .LightGreen
      case "green" : self = .Green
      case "darkgreen" : self = .DarkGreen
      case "lightblue" : self = .LightBlue
      case "blue" : self = .Blue
      case "darkblue" : self = .DarkBlue
      case "lightyellow" : self = .LightYellow
      case "yellow" : self = .Yellow
      case "darkyellow" : self = .DarkYellow
      case "lightpurple" : self = .LightPurple
      case "purple" : self = .Purple
      case "darkpurple" : self = .DarkPurple
      case "lightorange" : self = .LightOrange
      case "orange" : self = .Orange
      case "darkorange" : self = .DarkOrange
      default: return nil
      }
    }
    
    private func xtermCode() -> Int {
      switch(self) {
      case .Black : return 0
      case .DarkGrey : return 238
      case .Grey : return 241
      case .LightGrey : return 251
      case .White : return 15
      case .LightRed : return 199
      case .Red : return 9
      case .DarkRed : return 1
      case .LightGreen : return 46
      case .Green : return 2
      case .DarkGreen : return 22
      case .LightBlue : return 45
      case .Blue : return 21
      case .DarkBlue : return 18
      case .LightYellow : return 228
      case .Yellow : return 11
      case .DarkYellow : return 3
      case .Purple : return 93
      case .LightPurple : return 135
      case .DarkPurple : return 55
      case .LightOrange: return 215
      case .Orange: return 208
      case .DarkOrange: return 166
      }
    }
    
    private func xcodeCode() -> String {
      switch(self) {
      case .Black : return "0,0,0"
      case .DarkGrey : return "68,68,68"
      case .Grey : return "98,98,98"
      case .LightGrey : return "200,200,200"
      case .White : return "255,255,255"
      case .LightRed : return "255,37,174"
      case .Red : return "255,0,0"
      case .DarkRed : return "201,14,19"
      case .LightGreen : return "57,255,42"
      case .Green : return "0,255,0"
      case .DarkGreen : return "18,94,11"
      case .LightBlue : return "47,216,255"
      case .Blue : return "0,0,255"
      case .DarkBlue : return "0,18,133"
      case .LightYellow : return "255,255,143"
      case .Yellow : return "255,255,56"
      case .DarkYellow : return "206,203,43"
      case .Purple : return "131,46,252"
      case .LightPurple : return "172,105,252"
      case .DarkPurple : return "92,28,173"
      case .LightOrange: return "255,176,95"
      case .Orange: return "255,135,0"
      case .DarkOrange: return "216,96,0"
      }
    }
    
    fileprivate func code(forTTYType type: TTYType) -> String {
      switch(type) {
      case .XtermColor: return String(self.xtermCode())
      case .XcodeColors: return self.xcodeCode()
      case .Other: return ""
      }
    }
  }
  
  private var textColorPrefix: String {
    switch(self.ttyType) {
    case .XcodeColors: return "\u{1B}[fg"
    case .XtermColor: return "\u{1B}[38;5;"
    case .Other: return ""
    }
  }
  
  private var backgroundColorPrefix: String {
    switch(self.ttyType) {
    case .XcodeColors: return "\u{1B}[bg"
    case .XtermColor: return "\u{1B}[48;5;"
    case .Other: return ""
    }
  }
  
  private var colorSuffix: String {
    switch(self.ttyType) {
    case .XcodeColors: return ";"
    case .XtermColor: return "m"
    case .Other: return ""
    }
  }
  
  private var resetColorSequence: String {
    switch(self.ttyType) {
    case .XcodeColors: return "\u{1B}[;"
    case .XtermColor: return "\u{1B}[0m"
    case .Other: return ""
    }
  }
  
  fileprivate func colorizeLog(log: String, level: LogLevel) ->  String {
    var shouldResetColors = false
    var colorizedLog = ""
    
    if let textColor = self.textColors[level] {
      shouldResetColors = true
			colorizedLog += self.textColorPrefix + textColor.code(forTTYType: self.ttyType) + self.colorSuffix
    }
    if let backgroundColor = self.backgroundColors[level] {
      shouldResetColors = true
			colorizedLog += self.backgroundColorPrefix + backgroundColor.code(forTTYType: self.ttyType) + self.colorSuffix
    }

    colorizedLog += log
    
    if(shouldResetColors) {
      colorizedLog += self.resetColorSequence
    }
    
    return colorizedLog
  }
  
  /// :param: color The color to set, or nil to set no color
  /// :param: level The log level to which the provided color applies
  public func setTextColor(_ color: TTYColor?, forLevel level: LogLevel) {
    if let color = color {
      self.textColors[level] = color
    } else {
			self.textColors.removeValue(forKey: level)
    }
  }

  /// :param: color The color to set, or nil to set no color
  /// :param: level The log level to which the provided color applies
  public func setBackgroundColor(_ color: TTYColor?, forLevel level: LogLevel) {
    if let color = color {
      self.backgroundColors[level] = color
    } else {
			self.backgroundColors.removeValue(forKey: level)
    }
  }

}
