//
//  AppDelegate.m
//  Log4swift-objCTest
//
//  Created by Jérôme Duquennoy on 27/10/2015.
//  Copyright © 2015 duquennoy. All rights reserved.
//

#import "AppDelegate.h"

@import Log4swift;

@interface AppDelegate ()

@property (weak) IBOutlet NSWindow *window;
@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
  NSError *error = nil;
  
  NSDictionary *configDictionary = @{
                                     @"RootLogger": @"ping"
                                     };
  
  if(![LoggerFactory.sharedInstance readConfigurationFromDictionary:configDictionary error:&error]) {
    NSLog(@"Failed to load dictionary : %@", error);
  } else {
    NSLog(@"Successfully loaded dictionary");
  }
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
  // Insert code here to tear down your application
}

@end
