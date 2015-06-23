//
//  MemoryAppender.swift
//  Log4swift
//
//  Created by jerome on 14/06/2015.
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

@testable import Log4swift

/**
This test appender will store logs in memory for latter validation.
*/
class MemoryAppender: Appender {
  
  var logMessages = [(message: String, level: LogLevel)]();
  
  init() {
    super.init(identifier: "test.memoryAppender");
  }
  
  override func performLog(log: String, level: LogLevel) {
    logMessages.append((message: log, level: level));
  }
  
}
