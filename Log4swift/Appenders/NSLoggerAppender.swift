//
//  NSLoggerAppender.swift
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
The NSLogger appender relies on the NSLogger project (see https://github.com/fpillet/NSLogger) to send log messages over the network.  
*/
public class NSLoggerAppender : Appender {
  public enum DictionaryKey: String {
    case BonjourServiceName = "BonjourServiceName"
    case UseLocalCache = "UseLocalCacke"
    case UseSSL = "UseSSL"
    case RemoteHost = "RemoteHost"
    case RemotePort = "RemotePort"
  }

  let logger: UnsafeMutablePointer<NSLogger>;
  
  /// This initializer will configure the NSLogger client to send the messages to a specific host, with a specific port.  
  /// Parameters are :
  /// * remoteHost : the remote host address, as an IP or a resolable host name. Default value is 127.0.0.1.
  /// * remotePort : the number of the TCP port to which the client will connect Default value is 50 000.
  /// * useLocalCache : keep messages in memory as long as the remote viewer is not reachable Default value is true.
  /// * useSSL: as you can expect, the client will initiate an SSL connection. Default value is true.
  public init(identifier: String, remoteHost: String = "127.0.0.1", remotePort: UInt32 = 50000, useLocalCache: Bool = true, useSSL: Bool = true) {
    self.logger = LoggerGetDefaultLogger();
    LoggerSetDefaultLogger(self.logger);
    super.init(identifier);

    var options = UInt32(0);
    if(useLocalCache) {
      options |= UInt32(kLoggerOption_BufferLogsUntilConnection);
    }
    if(useSSL) {
      options |= UInt32(kLoggerOption_UseSSL);
    }
    LoggerSetOptions(self.logger, options);
    
    LoggerSetViewerHost(self.logger, remoteHost, remotePort);
  }
  
  /// This initializer will configure the NSLogger client to send the message to a Bonjour service provider.
  /// * bonjourServiceName : the name of the bonjour service
  /// * useLocalCache : keep messages in memory as long as the remote viewer is not reachable Default value is true.
  /// * useSSL: as you can expect, the client will initiate an SSL connection. Default value is true.
  public init(identifier: String, bonjourServiceName: String, useLocalCache: Bool = true, useSSL: Bool = true) {
    self.logger = LoggerGetDefaultLogger();
    LoggerSetDefaultLogger(self.logger);
    super.init(identifier);
    
    var options = UInt32(kLoggerOption_BrowseBonjour);
    if(useLocalCache) {
      options |= UInt32(kLoggerOption_BufferLogsUntilConnection);
    }
    if(useSSL) {
      options |= UInt32(kLoggerOption_UseSSL);
    }
    LoggerSetOptions(self.logger, options);
    
    
    LoggerSetupBonjour(self.logger, nil, bonjourServiceName);
  }

  public convenience required init(_ dictionary: Dictionary<String, AnyObject>, availableFormatters: Array<Formatter>) throws {
    var errorToThrow: Error? = nil;
    
    let bonjourMode = (dictionary[DictionaryKey.BonjourServiceName.rawValue] != nil);

    let identifier: String;
    var threshold = LogLevel.Debug;
    var formatter: Formatter? = nil;
    let useLocalCache: Bool;
    let useSSL: Bool;
    
    if let safeIdentifier = (dictionary[DictionaryKey.Identifier.rawValue] as? String) {
      identifier = safeIdentifier;
    } else {
      identifier = "placeholder";
      errorToThrow = Error.InvalidOrMissingParameterException(parameterName: DictionaryKey.Identifier.rawValue);
    }
    
    if let safeThresholdString = (dictionary[DictionaryKey.Threshold.rawValue] as? String) {
      if let safeThreshold = LogLevel(safeThresholdString) {
        threshold = safeThreshold;
      } else {
        errorToThrow = Error.InvalidOrMissingParameterException(parameterName: DictionaryKey.Threshold.rawValue);
      }
    }
    
    if let safeFormatterId = (dictionary[DictionaryKey.FormatterId.rawValue] as? String) {
      if let safeFormatter = availableFormatters.find({ $0.identifier == safeFormatterId }) {
        formatter = safeFormatter;
      } else {
        throw Error.InvalidOrMissingParameterException(parameterName: DictionaryKey.FormatterId.rawValue);
      }
    }
    
    if let safeUseLocalCache = (dictionary[DictionaryKey.UseLocalCache.rawValue] as? String) {
      useLocalCache = Bool(safeUseLocalCache);
    } else {
      useLocalCache = true;
    }
    
    if let safeUseSSLString = (dictionary[DictionaryKey.UseSSL.rawValue] as? String) {
      useSSL = Bool(safeUseSSLString);
    } else {
      useSSL = true;
    }
    
    if(bonjourMode) {
      let serviceName: String;

      if let safeServiceName = (dictionary[DictionaryKey.BonjourServiceName.rawValue] as? String) {
        serviceName = safeServiceName;
      } else {
        serviceName = "placeholder";
        errorToThrow = Error.InvalidOrMissingParameterException(parameterName: DictionaryKey.BonjourServiceName.rawValue)
      }

      self.init(identifier: identifier, bonjourServiceName: serviceName, useLocalCache: useLocalCache, useSSL: useSSL);
    } else {
      let remoteHost: String;
      let remotePort: UInt32;

      if let safeRemoteHost = (dictionary[DictionaryKey.RemoteHost.rawValue] as? String) {
        remoteHost = safeRemoteHost;
      } else {
        remoteHost = "placeholder";
        errorToThrow = Error.InvalidOrMissingParameterException(parameterName: DictionaryKey.RemoteHost.rawValue);
      }

      if let safeRemotePortString = (dictionary[DictionaryKey.RemotePort.rawValue] as? String) {
        if let safeRemotePort = UInt32(safeRemotePortString) {
          remotePort = safeRemotePort;
        } else {
          remotePort = 0;
          errorToThrow = Error.InvalidOrMissingParameterException(parameterName: DictionaryKey.RemotePort.rawValue);
        }
      } else {
        remotePort = 50000;
      }
      
      self.init(identifier: identifier, remoteHost: remoteHost, remotePort: remotePort, useLocalCache: useLocalCache, useSSL: useSSL);
    }
    self.thresholdLevel = threshold;
    self.formatter = formatter;

    if let errorToThrow = errorToThrow {
      throw errorToThrow;
    }
  }
  
  deinit {
    LoggerStop(nil);
  }
  
  override func performLog(log: String, level: LogLevel) {
    LogMessageRaw(log);
  }
}