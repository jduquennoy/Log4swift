//
//  log4swift.h
//  log4swift
//
//  Created by Jérôme Duquennoy on 14/06/2015.
//  Copyright © 2015 Jérôme Duquennoy. All rights reserved.
//
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

#import <Foundation/Foundation.h>

//! Project version number for log4swift.
FOUNDATION_EXPORT double log4swiftVersionNumber;

//! Project version string for log4swift.
FOUNDATION_EXPORT const unsigned char log4swiftVersionString[];

// In this header, you should import all the public headers of your framework using statements like #import <log4swift/PublicHeader.h>
#import <Log4swift/NSLogger.h>
#import <Log4swift/LoggerClient.h>
#import <Log4swift/LoggerCommon.h>

#import <Log4swift/ASLWrapper.h>
