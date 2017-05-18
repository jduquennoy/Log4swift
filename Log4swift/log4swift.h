//
//  log4swift.h
//  log4swift
//
//  Created by Jérôme Duquennoy on 14/06/2015.
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

#import <Foundation/Foundation.h>

//! Project version number for log4swift.
FOUNDATION_EXPORT double log4swiftVersionNumber;

//! Project version string for log4swift.
FOUNDATION_EXPORT const unsigned char log4swiftVersionString[];

// In this header, you should import all the public headers of your framework using statements like #import <log4swift/PublicHeader.h>
#if !TARGET_OS_WATCH
#import "NSLogger.h"
#import "LoggerClient.h"
#import "LoggerCommon.h"
#endif
#import "ASLWrapper.h"
