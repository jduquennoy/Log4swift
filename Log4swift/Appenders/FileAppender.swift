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
    case MaxFileAge = "MaxFileAge"
    case MaxFileSize = "MaxFileSize"
  }
  
  @objc
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
  
  /// The rotation policies to apply. The file will be rotated if at least
  /// one of the registered policies requests it.
  /// If none are registered, the file will never be rotated.
  public var rotationPolicies = [FileAppenderRotationPolicy]()
  public var maxFileSize: UInt64?
  
  /// The maximum number of rotated log files kept.
  /// Files exceeding this limit will be deleted during rotation.
  public var maxRotatedFiles: UInt?
  
  private var fileHandler: FileHandle?
  private var currentFileSize: UInt64?
  private var didLogFailure = false
  private var loggingMutex = PThreadMutex()

  @objc
  public init(identifier: String, filePath: String) {
    self.fileHandler = nil
    self.currentFileSize = nil
    self.filePath = (filePath as NSString).expandingTildeInPath

    super.init(identifier)
  }
  
  /// - Parameter identifier: the identifier of the appender.
  /// - Parameter filePath: the path to the logfile. If possible and needed, the directory
  /// structure will be created when creating the log file.
  /// - Parameter maxFileSize: the maximum size of the file in octets before rotation is triggered.
  /// Nil or zero disables the file size trigger for rotation. Default value is nil.
  /// - Parameter maxFileAge: the maximum age of the file in seconds before rotation is triggered.
  /// Nil or zero disables the file age trigger for rotation. Default value is nil.
  public convenience init(identifier: String, filePath: String, rotationPolicies: [FileAppenderRotationPolicy]? = nil) {
    self.init(identifier: identifier, filePath: filePath)
    if let rotationPolicies = rotationPolicies {
      self.rotationPolicies.append(contentsOf: rotationPolicies)
    }
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
    if let maxFileAge = (dictionary[DictionaryKey.MaxFileAge.rawValue] as? Int) {
      let existingRotationPolicy = self.rotationPolicies.find { ($0 as? DateRotationPolicy) != nil  } as? DateRotationPolicy
      
      if let existingRotationPolicy = existingRotationPolicy {
        existingRotationPolicy.maxFileAge = TimeInterval(maxFileAge)
      } else {
        self.rotationPolicies.append(DateRotationPolicy(maxFileAge: TimeInterval(maxFileAge)))
      }
    }
    if let maxFileSize = (dictionary[DictionaryKey.MaxFileSize.rawValue] as? Int) {
      let existingRotationPolicy = self.rotationPolicies.find { ($0 as? SizeRotationPolicy) != nil  } as? SizeRotationPolicy
      if let existingRotationPolicy = existingRotationPolicy {
        existingRotationPolicy.maxFileSize = UInt64(maxFileSize)
      } else {
        self.rotationPolicies.append(SizeRotationPolicy(maxFileSize: UInt64(maxFileSize)))
      }
    }
  }
  
  /// This is the only entry point to log.
  /// It is thread safe, calling that method from multiple threads will not
  // cause logs to interleave, or mess with the rotation mechanism.
  public override func performLog(_ log: String, level: LogLevel, info: LogInfoDictionary) {

    var normalizedLog = log
    if(!normalizedLog.hasSuffix("\n")) {
      normalizedLog = normalizedLog + "\n"
    }
    
    loggingMutex.sync {
      try? rotateFileIfNeeded()
      guard createFileHandlerIfNeeded() else {
        return
      }
      if let dataToLog = normalizedLog.data(using: String.Encoding.utf8, allowLossyConversion: true) {
        self.fileHandler?.write(dataToLog)
        self.rotationPolicies.forEach { $0.appenderDidAppend(data: dataToLog)}
      }
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
        self.currentFileSize = 0
      }
      if self.fileHandler == nil {
        self.fileHandler = FileHandle(forWritingAtPath: self.filePath)
        self.fileHandler?.seekToEndOfFile()
      }
      self.rotationPolicies.forEach { $0.appenderDidOpenFile(atPath: self.filePath) }
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
  
  private func rotateFileIfNeeded() throws {
    let shouldRotate = self.rotationPolicies.contains { $0.shouldRotate() }
    guard shouldRotate else { return }

    self.fileHandler?.closeFile()
    self.fileHandler = nil
    
    let fileManager = FileManager.default
    let fileUrl = URL(fileURLWithPath: self.filePath)
    let logFileName = fileUrl.lastPathComponent
    let logFileDirectory = fileUrl.deletingLastPathComponent()
    
    let files = try fileManager.contentsOfDirectory(atPath: logFileDirectory.path)
      .filter { $0.hasPrefix(logFileName) }
      .sorted {$0.localizedStandardCompare($1) == .orderedAscending }
      .reversed()
    
    var currentFileIndex = UInt(files.count)
    try files.forEach { currentFileName in
      let newFileName = logFileName.appending(".\(currentFileIndex)")
      let currentFilePath = logFileDirectory.appendingPathComponent(currentFileName)
      let rotatedFilePath = logFileDirectory.appendingPathComponent(newFileName)
      
      if let maxRotatedFiles = self.maxRotatedFiles, currentFileIndex > maxRotatedFiles {
        try fileManager.removeItem(at: currentFilePath)
      } else {
        try fileManager.moveItem(at: currentFilePath,
                           to: rotatedFilePath)
      }
      currentFileIndex -= 1
    }
  }
}
