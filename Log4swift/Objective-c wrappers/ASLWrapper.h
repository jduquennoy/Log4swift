//
//  ASLWrapper.h
//  Log4swift
//
//  Created by Jérôme Duquennoy on 29/07/15.
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

@import Foundation;

/**
 This wrapper makes it possible to use ASL in the swift code.
 That is not possible otherwise because the asl.h header is not modular, and thus cannot be imported in the log4swift.h file.
 This wrapper will delegate all log operations to a serial queue to avoid concurrency problems with ASL.
*/
@interface ASLWrapper : NSObject 

- (instancetype)init;

- (void)logMessage:(NSString *)log level:(int)level category:(NSString *)category;

- (int)getLevelOfMessageMatchingText:(NSString *)message;
- (NSString *)getFacilityOfMessageMatchingText:(NSString *)message;
@end
