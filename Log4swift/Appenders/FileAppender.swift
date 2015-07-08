//
//  FileAppender.swift
//  Log4swift
//
//  Created by Jérôme Duquennoy on 16/06/2015.
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
This appender will write logs to a file.
If file does not exist, it will be created on the first log, or re-created if deleted or moved (compatible with log rotate systems).
*/
public class FileAppender : Appender {
  public enum DictionaryKey: String {
    case FilePath = "FilePath"
  };
  
  internal var filePath : String {
    willSet {
      if let safeHandler = self.fileHandler {
        safeHandler.closeFile();
        self.fileHandler = nil;
      }
    }
  };
  private var fileHandler: NSFileHandle?;

  public init(identifier: String, filePath: String) {
    self.fileHandler = nil;
    self.filePath = filePath;

    super.init(identifier);
  }

  public required convenience init(_ identifier: String) {
    self.init(identifier: identifier, filePath: "/dev/null");
  }
  
  public override func updateWithDictionary(dictionary: Dictionary<String, AnyObject>, availableFormatters: Array<Formatter>) throws {
    try super.updateWithDictionary(dictionary, availableFormatters: availableFormatters);
    
    if let safeFilePath = (dictionary[DictionaryKey.FilePath.rawValue] as? String) {
      self.filePath = safeFilePath;
    } else {
      self.filePath = "placeholder";
      throw Error.InvalidOrMissingParameterException(parameterName: DictionaryKey.FilePath.rawValue);
    }
  }
  
  override func performLog(var log: String, level: LogLevel, info: LogInfoDictionary) {
    if(self.fileHandler == nil || !NSFileManager.defaultManager().fileExistsAtPath(self.filePath)) {
      do {
        try self.openFileHandleForPath(self.filePath);
      } catch (let error) {
        NSLog("Appender \(self.identifier) failed to write log to \(self.filePath) : \(error)")
      }
    }
    
    if(!log.hasSuffix("\n")) {
      log = "\(log)\n";
    }
    if let dataToLog = log.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: true) {
      fileHandler?.writeData(dataToLog);
    }
  }
  
  private func openFileHandleForPath(filePath: String) throws {
    let fileManager = NSFileManager.defaultManager();
    let directoryPath = filePath.stringByDeletingLastPathComponent;
    try fileManager.createDirectoryAtPath(directoryPath, withIntermediateDirectories: true, attributes: nil);
    
    fileManager.createFileAtPath(filePath, contents: nil, attributes: nil);
    fileHandler = NSFileHandle(forWritingAtPath: filePath);
    fileHandler?.seekToEndOfFile();
  }
}

