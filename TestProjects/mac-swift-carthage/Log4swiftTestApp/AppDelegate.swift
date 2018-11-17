//
//  AppDelegate.swift
//  Log4SwiftTestApp
//
//  Created by Jérôme Duquennoy on 22/03/2016.
//  Copyright © 2016 dxo. All rights reserved.
//

import Cocoa
import Log4swift

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

  @IBOutlet weak var window: NSWindow!
  let timer: Timer

  override init() {
    try! LoggerFactory.sharedInstance.readConfiguration(fromPlistFile: "~/log4swift-testFile.plist", autoReload: true, reloadInterval: 5.0)
    
    self.timer = Timer.repeating(interval: 2.0) { (timer: Timer, executionCount: Int) in
      LoggerFactory.sharedInstance.getLogger("test.logger1").trace("trace log of test.logger1 #\(executionCount)")
      LoggerFactory.sharedInstance.getLogger("test.logger1").error("error log of test.logger1 #\(executionCount)")
      LoggerFactory.sharedInstance.getLogger("test.logger1").warning("warn log of test.logger1 #\(executionCount)")
      LoggerFactory.sharedInstance.getLogger("test.logger1").info("info log of test.logger1 #\(executionCount)")
      LoggerFactory.sharedInstance.getLogger("test.logger1").debug("debug log of test.logger1 #\(executionCount)")
      
      LoggerFactory.sharedInstance.getLogger("test.logger2").trace("trace log of test.logger2 #\(executionCount)")
      LoggerFactory.sharedInstance.getLogger("test.logger2").error("error log of test.logger2 #\(executionCount)")
      LoggerFactory.sharedInstance.getLogger("test.logger2").warning("warn log of test.logger2 #\(executionCount)")
      LoggerFactory.sharedInstance.getLogger("test.logger2").info("info log of test.logger2 #\(executionCount)")
      LoggerFactory.sharedInstance.getLogger("test.logger2").debug("debug log of test.logger2 #\(executionCount)")
    }
  }
  
  func applicationDidFinishLaunching(aNotification: NSNotification) {
    // Insert code here to initialize your application
  }

  func applicationWillTerminate(aNotification: NSNotification) {
    // Insert code here to tear down your application
  }


}

