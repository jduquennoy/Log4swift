//
//  FileAppender.swift
//  Log4swift
//
//  Created by Jérôme Duquennoy on 16/06/2015.
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

import Foundation

enum FileAppenderError : ErrorType {
  case FilePathError
}

/**
This appender will write logs to a file.
If file does not exist, it will be created on the first log, or re-created if deleted or moved (compatible with log rotate systems).
*/
class FileAppender : Appender {
  private let filePath : String;
  private var fileHandler: NSFileHandle?;

  init(identifier: String, filePath: String) throws {
    self.fileHandler = nil;
    self.filePath = filePath;

    super.init(identifier: identifier);
  }
  
  override func performLog(var log: String) {
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

