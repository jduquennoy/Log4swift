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
    super.init(identifier: identifier);

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
    super.init(identifier: identifier);
    
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

  deinit {
    LoggerStop(nil);
  }
  
  override func performLog(log: String, level: LogLevel) {
    LogMessageRaw(log);
  }
}