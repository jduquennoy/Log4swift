//
//  FileObserver.swift
//  Log4swift
//
//  Created by Jérôme Duquennoy on 29/12/2015.
//  Copyright © 2015 jerome. All rights reserved.
//

import Foundation

/**
This protocol should be implemented to register as a delegate of a FileObserver object.
*/
public protocol FileObserverDelegate {
  func fileChanged(atPath: String)
}

/**
This class is a simple observer for a file. It will notify a delegate when a change is detected.
It does not use FSEvent, to keep the complexity low while being compatible with both OS X and Linux.
It only observes a single file, which will make the cost of pooling for changes very low.
*/
public class FileObserver {
  public var delegate: FileObserverDelegate?
  public let filePath: String
  public let poolInterval: Double
  private var lastModificationTime = timespec(tv_sec: 0, tv_nsec: 0)
  
  init(filePath: String, poolInterval: Double = 2.0) {
    self.filePath = filePath
    self.poolInterval = poolInterval
    self.lastModificationTime = self.getFileModificationDate()
    self.scheduleNextPooling()
  }
  
  private func getFileModificationDate() -> timespec {
    var fileStat = stat()
    let statResult = stat(filePath, &fileStat)
    
    var modificationTimestamp = timespec(tv_sec: 0, tv_nsec: 0)
    if statResult == 0 {
      modificationTimestamp = fileStat.st_mtimespec
    }
    
    return modificationTimestamp
  }
  
  func poolForChange() {
    let modificationDate = self.getFileModificationDate()
    if modificationDate > self.lastModificationTime {
			delegate?.fileChanged(atPath: self.filePath)
      self.lastModificationTime = modificationDate
    }
    self.scheduleNextPooling()
  }
  
  private func scheduleNextPooling() {
    let nextPoolingTime = DispatchTime.now() + self.poolInterval
    let poolClosure:@convention(block) () -> Void = {[weak self] in
      self?.poolForChange()
    }
    
    if #available(OSX 10.10, *) {
      DispatchQueue.main.asyncAfter(deadline: nextPoolingTime, qos: .background, execute: poolClosure)
    } else {
      DispatchQueue.main.asyncAfter(deadline: nextPoolingTime, execute: poolClosure)
    }
  }
}

private func >(left: timespec, right: timespec) -> Bool {
  if left.tv_sec > right.tv_sec {
    return true
  } else if left.tv_sec == right.tv_sec && left.tv_nsec > right.tv_nsec {
    return true
  }
  
  return false
}
