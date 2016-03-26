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
  
  internal var filePath : String {
    didSet {
      if let safeHandler = self.fileHandler {
        safeHandler.closeFile()
        self.fileHandler = nil
      }
      self.filePath = (self.filePath as NSString).stringByExpandingTildeInPath
      didLogFailure = false
    }
  }
  private var fileHandler: NSFileHandle?
  private var didLogFailure = false

  public init(identifier: String, filePath: String) {
    self.fileHandler = nil
    self.filePath = (filePath as NSString).stringByExpandingTildeInPath

    super.init(identifier)
  }

  public required convenience init(_ identifier: String) {
    self.init(identifier: identifier, filePath: "/dev/null")
  }
  
  public override func updateWithDictionary(dictionary: Dictionary<String, AnyObject>, availableFormatters: Array<Formatter>) throws {
    try super.updateWithDictionary(dictionary, availableFormatters: availableFormatters)
    
    if let safeFilePath = (dictionary[DictionaryKey.FilePath.rawValue] as? String) {
      self.filePath = safeFilePath
    } else {
      self.filePath = "placeholder"
      throw NSError.Log4swiftErrorWithDescription("Missing '\(DictionaryKey.FilePath.rawValue)' parameter for file appender '\(self.identifier)'")
    }
  }
  
  override func performLog(log: String, level: LogLevel, info: LogInfoDictionary) {
    if(self.fileHandler == nil || !NSFileManager.defaultManager().fileExistsAtPath(self.filePath)) {
      do {
        try self.openFileHandleForPath(self.filePath)
        didLogFailure = false
      } catch (let error) {
        if(!didLogFailure) {
          NSLog("Appender \(self.identifier) failed to open log file \(self.filePath) : \(error)")
          didLogFailure = true
        }
      }
    }
    
    var normalizedLog = log
    if(!normalizedLog.hasSuffix("\n")) {
      normalizedLog = normalizedLog + "\n"
    }
    if let dataToLog = normalizedLog.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: true) {
      fileHandler?.writeData(dataToLog)
    }
  }
  
  private func openFileHandleForPath(filePath: String) throws {
    let fileManager = NSFileManager.defaultManager()
    let directoryPath = (filePath as NSString).stringByDeletingLastPathComponent
    try fileManager.createDirectoryAtPath(directoryPath, withIntermediateDirectories: true, attributes: nil)
    
    fileManager.createFileAtPath(filePath, contents: nil, attributes: nil)
    fileHandler = NSFileHandle(forWritingAtPath: filePath)
    fileHandler?.seekToEndOfFile()
  }
}

