//
//  AppendersRepository.swift
//  Log4swift
//
//  Created by Jérome Duquennoy on 29/03/2020.
//  Copyright © 2020 jerome. All rights reserved.
//

import Foundation

/// A registry that contains the list of appender types that can be used when loading
/// a configuration from a file.
public struct AppendersRegistry {
  /// The actual list of appenders available
  internal static var appenders: [Appender.Type] = {
    var appenders = [
      StdOutAppender.self,
      FileAppender.self,
      NSLogAppender.self,
      ASLAppender.self,
      SystemAppender.self
    ]
    #if !os(watchOS)
      appenders.append(NSLoggerAppender.self)
    #endif
    if #available(iOS 10.0, macOS 10.12, watchOS 3, *) {
      appenders.append(AppleUnifiedLoggerAppender.self)
    }
    return appenders
  } ()
  
  /// Returns an appender type for a class name.
  /// The search is case insensitive.
  internal static func appenderForClassName(_ className: String) -> Appender.Type? {
    let classNameLowercased = className.lowercased()
    
    for appenderType in Appender.availableAppenderTypes {
      if String(describing: appenderType).lowercased() == classNameLowercased  {
        return appenderType
      }
    }
    
    return nil
  }


  /// Add an appender type to the registry.
  /// That appender can then be created from configuration file, specifying its class name in the Class parameter.
  /// You do not need to register custom appenders used to configure your system programmatically.
  public static func registerAppender(_ newAppender: Appender.Type) {
    self.appenders.append(newAppender)
  }
}
