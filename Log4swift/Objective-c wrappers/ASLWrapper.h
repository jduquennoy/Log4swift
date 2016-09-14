//
//  ASLWrapper.h
//  Log4swift
//
//  Created by Jérôme Duquennoy on 29/07/15.
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

@import Foundation;

/**
 This wrapper makes it possible to use ASL in the swift code.
 That is not possible otherwise because the asl.h header is not modular, and thus cannot be imported in the log4swift.h file.
 This wrapper will delegate all log operations to a serial queue to avoid concurrency problems with ASL.
*/
@interface ASLWrapper : NSObject 

- (nonnull instancetype)init;

- (void)logMessage:(nonnull NSString *)log level:(int)level category:(nonnull NSString *)category;

- (int)getLevelOfMessageMatchingText:(nonnull NSString *)message;
- (nullable NSString *)getFacilityOfMessageMatchingText:(nonnull NSString *)message;
@end
