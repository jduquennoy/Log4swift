//
//  NSLoggerAppender.swift
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
The NSLogger appender relies on the NSLogger project (see https://github.com/fpillet/NSLogger) to send log messages over the network.  
*/
@available(iOS 8.0, *)
public class NSLoggerAppender : Appender {
  public enum DictionaryKey: String {
    case BonjourServiceName = "BonjourServiceName"
    case UseLocalCache = "UseLocalCache"
    case UseSSL = "UseSSL"
    case RemoteHost = "RemoteHost"
    case RemotePort = "RemotePort"
  }

  let logger: UnsafeMutablePointer<NSLogger>
  
  /// This initializer will configure the NSLogger client to send the messages to a specific host, with a specific port.
  /// Parameters are :
  /// * remoteHost : the remote host address, as an IP or a resolable host name. Default value is 127.0.0.1.
  /// * remotePort : the number of the TCP port to which the client will connect Default value is 50 000.
  /// * useLocalCache : keep messages in memory as long as the remote viewer is not reachable Default value is true.
  /// * useSSL: as you can expect, the client will initiate an SSL connection. Default value is true.
  public convenience init(identifier: String, remoteHost: String = "127.0.0.1", remotePort: UInt32 = 50000, useLocalCache: Bool = true, useSSL: Bool = true) {
    self.init(identifier)
		setupTcpLogger(remoteHost: remoteHost, remotePort: remotePort, useLocalCache: useLocalCache, useSSL: useSSL)
  }
  
  /// This initializer will configure the NSLogger client to send the message to a Bonjour service provider.
  /// * bonjourServiceName : the name of the bonjour service
  /// * useLocalCache : keep messages in memory as long as the remote viewer is not reachable Default value is true.
  /// * useSSL: as you can expect, the client will initiate an SSL connection. Default value is true.
  public convenience init(identifier: String, bonjourServiceName: String, useLocalCache: Bool = true, useSSL: Bool = true) {
    self.init(identifier)
		setupBonjourLogger(bonjourServiceName: bonjourServiceName, useLocalCache: useLocalCache, useSSL: useSSL)
  }

  public required init(_ identifier: String) {
    self.logger = LoggerInit()
    super.init(identifier)
  }

  public override func update(withDictionary dictionary: Dictionary<String, Any>, availableFormatters: Array<Formatter>) throws {
		try super.update(withDictionary: dictionary, availableFormatters: availableFormatters)
    
    let bonjourMode = (dictionary[DictionaryKey.BonjourServiceName.rawValue] != nil)

    let useLocalCache: Bool
    let useSSL: Bool

		try super.update(withDictionary: dictionary, availableFormatters: availableFormatters)
    
    if let safeUseLocalCache = (dictionary[DictionaryKey.UseLocalCache.rawValue] as? String) {
      useLocalCache = Bool(safeUseLocalCache)
    } else {
      useLocalCache = true
    }
    
    if let safeUseSSLString = (dictionary[DictionaryKey.UseSSL.rawValue] as? String) {
      useSSL = Bool(safeUseSSLString)
    } else {
      useSSL = true
    }
    
    if(bonjourMode) {
      let serviceName: String

      if let safeServiceName = (dictionary[DictionaryKey.BonjourServiceName.rawValue] as? String) {
        serviceName = safeServiceName
      } else {
				throw NSError.Log4swiftError(description: "Missing 'BonjourServiceName' parameter for NSLogger appender '\(self.identifier)'")
      }

			setupBonjourLogger(bonjourServiceName: serviceName, useLocalCache: useLocalCache, useSSL: useSSL)
    } else {
      let remoteHost: String
      let remotePort: UInt32

      if let safeRemoteHost = (dictionary[DictionaryKey.RemoteHost.rawValue] as? String) {
        remoteHost = safeRemoteHost
      } else {
        remoteHost = "placeholder"
        throw NSError.Log4swiftError(description: "Missing 'RemoteHost' parameter for NSLogger appender '\(self.identifier)'")
      }

      if let safeRemotePort = dictionary[DictionaryKey.RemotePort.rawValue] as? Int {
        remotePort = UInt32(safeRemotePort)
      } else if let safeRemotePortString = (dictionary[DictionaryKey.RemotePort.rawValue] as? String) {
        if let safeRemotePort = UInt32(safeRemotePortString) {
          remotePort = safeRemotePort
        } else {
          remotePort = 0
          throw NSError.Log4swiftError(description: "Non numeric string 'RemotePort' parameter for NSLogger appender '\(self.identifier)'")
        }
      } else {
        remotePort = 50000
      }
      if(remotePort < 1024 || remotePort > 65535) {
        throw NSError.Log4swiftError(description: "RemotePort should be between 1024 and 65535 for NSLogger appender '\(self.identifier)'")
      }
      
			setupTcpLogger(remoteHost: remoteHost, remotePort: remotePort, useLocalCache: useLocalCache, useSSL: useSSL)
    }
  }
  
  deinit {
    LoggerStop(self.logger)
  }
  
  public override func performLog(_ log: String, level: LogLevel, info: LogInfoDictionary) {
    var loggerId = ""
    if let safeLoggerId = info[LogInfoKeys.LoggerName] {
      loggerId = safeLoggerId.description
    }
    LogMessageRawToF(self.logger, nil, 0, nil, loggerId, Int32(level.rawValue), log)
  }
  
  private func setupBonjourLogger(bonjourServiceName: String, useLocalCache: Bool, useSSL: Bool) {
    var options = UInt32(kLoggerOption_BrowseBonjour)
    if(useLocalCache) {
      options |= UInt32(kLoggerOption_BufferLogsUntilConnection)
    }
    if(useSSL) {
      options |= UInt32(kLoggerOption_UseSSL)
    }
    LoggerSetOptions(self.logger, options)
    
    LoggerSetupBonjour(self.logger, nil, bonjourServiceName as NSString)

    LoggerStart(self.logger)
}
  
  private func setupTcpLogger(remoteHost: String, remotePort: UInt32, useLocalCache: Bool, useSSL: Bool) {
    var options = UInt32(0)
    if(useLocalCache) {
      options |= UInt32(kLoggerOption_BufferLogsUntilConnection)
    }
    if(useSSL) {
      options |= UInt32(kLoggerOption_UseSSL)
    }
    LoggerSetOptions(self.logger, options)
    
    LoggerSetViewerHost(self.logger, remoteHost as NSString, remotePort)
    
    LoggerStart(self.logger)
  }
}
