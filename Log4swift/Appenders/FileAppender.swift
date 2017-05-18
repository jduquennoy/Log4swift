//
//  FileAppender.swift
//  Log4swift
//
//  Created by Jérôme Duquennoy on 16/06/2015.
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
This appender will write logs to a file.
If file does not exist, it will be created on the first log, or re-created if deleted or moved (compatible with log rotate systems).
*/
public class FileAppender : Appender {
  public enum DictionaryKey: String {
    case FilePath = "FilePath"
  }
  
  public internal(set) var filePath : String {
    didSet {
      if let safeHandler = self.fileHandler {
        safeHandler.closeFile()
        self.fileHandler = nil
      }
      self.filePath = (self.filePath as NSString).expandingTildeInPath
      didLogFailure = false
    }
  }
  private var fileHandler: FileHandle?
  private var didLogFailure = false

  public init(identifier: String, filePath: String) {
    self.fileHandler = nil
    self.filePath = (filePath as NSString).expandingTildeInPath

    super.init(identifier)
  }

  public required convenience init(_ identifier: String) {
    self.init(identifier: identifier, filePath: "/dev/null")
  }
  
	public override func update(withDictionary dictionary: Dictionary<String, Any>, availableFormatters: Array<Formatter>) throws {
		try super.update(withDictionary: dictionary, availableFormatters: availableFormatters)
    
    if let safeFilePath = (dictionary[DictionaryKey.FilePath.rawValue] as? String) {
      self.filePath = safeFilePath
    } else {
      self.filePath = "placeholder"
			throw NSError.Log4swiftError(description: "Missing '\(DictionaryKey.FilePath.rawValue)' parameter for file appender '\(self.identifier)'")
    }
  }
  
  public override func performLog(_ log: String, level: LogLevel, info: LogInfoDictionary) {
		guard createFileHandlerIfNeeded() else {
			return
		}
    
    var normalizedLog = log
    if(!normalizedLog.hasSuffix("\n")) {
      normalizedLog = normalizedLog + "\n"
    }
    if let dataToLog = normalizedLog.data(using: String.Encoding.utf8, allowLossyConversion: true) {
      self.fileHandler?.write(dataToLog)
    }
  }
	
	/// - returns: true if the file handler can be used, false if not.
  private func createFileHandlerIfNeeded() -> Bool {
    let fileManager = FileManager.default
    
    do {
			if !fileManager.fileExists(atPath: self.filePath) {
				self.fileHandler = nil
				
        let directoryPath = (filePath as NSString).deletingLastPathComponent
				try fileManager.createDirectory(atPath: directoryPath, withIntermediateDirectories: true, attributes: nil)
        
				fileManager.createFile(atPath: filePath, contents: nil, attributes: nil)
      }
      if fileHandler == nil {
        self.fileHandler = FileHandle(forWritingAtPath: self.filePath)
        self.fileHandler?.seekToEndOfFile()
      }
      didLogFailure = false
      
    } catch (let error) {
      if(!didLogFailure) {
        NSLog("Appender \(self.identifier) failed to open log file \(self.filePath) : \(error)")
        didLogFailure = true
				self.fileHandler = nil
      }
    }
		return self.fileHandler != nil
  }
  
}

