//
//  ASLWrapper.m
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

#import "ASLWrapper.h"
#import <asl.h>
#import <Log4swift/Log4swift-Swift.h>

@implementation ASLWrapper {
  aslclient logClient;
  dispatch_queue_t loggingQueue;
}

- (instancetype)init {
  self = [super init];
  if (self) {
    logClient = asl_open(NULL, NULL, 0);
    char filter = ASL_FILTER_MASK_UPTO(ASL_LEVEL_DEBUG);
    asl_set_filter(logClient, filter); // We don't want ASL to filter messages
    loggingQueue = dispatch_queue_create("Log4swift.ASLLoggingQueue", DISPATCH_QUEUE_SERIAL);
  }
  return self;
}

- (void)dealloc {
  if(logClient != NULL) {
    asl_close(logClient);
    logClient = NULL;
    
    loggingQueue = NULL;
  }
}

- (void)logMessage:(NSString *)log level:(int)level category:(NSString *)category {
  dispatch_sync(loggingQueue, ^{
    aslmsg aslMessage = asl_new(ASL_TYPE_MSG);
    asl_set(aslMessage, ASL_KEY_FACILITY, [category UTF8String]);
    
    int aslLogLevel = [self _logLevelToAslLevel:level];
    
    if(logClient != NULL) {
      va_list empty_va_list;
      asl_vlog(logClient, aslMessage, aslLogLevel, [log UTF8String], empty_va_list);
    }
    
    asl_free(aslMessage);
  });
}

- (int)getLevelOfMessageMatchingText:(NSString *)message {
  aslmsg query = asl_new(ASL_TYPE_QUERY);
  asl_set_query(query, ASL_KEY_MSG, [message UTF8String], ASL_QUERY_OP_EQUAL);
  aslresponse response = asl_search(logClient, query);
  asl_free(query);
  
  int foundLevel = -1;
  aslmsg foundMessage = asl_next(response);
  if (foundMessage != NULL) {
    const char *level = asl_get(foundMessage, ASL_KEY_LEVEL);
    if (level != NULL) {
      foundLevel = [[NSString stringWithCString:level encoding:NSUTF8StringEncoding] intValue];
    }
  }

  asl_release(response);
  
  return [self _aslLevelToLogLevel:foundLevel];
}

- (NSString *)getFacilityOfMessageMatchingText:(NSString *)message {
  aslmsg query = asl_new(ASL_TYPE_QUERY);
  asl_set_query(query, ASL_KEY_MSG, [message UTF8String], ASL_QUERY_OP_EQUAL);
  aslresponse response = asl_search(logClient, query);
  asl_free(query);
  
  NSString *foundFacility = nil;
  aslmsg foundMessage = asl_next(response);
  if (foundMessage != NULL) {
    const char *level = asl_get(foundMessage, ASL_KEY_FACILITY);
    if (level != NULL) {
      foundFacility = [NSString stringWithCString:level encoding:NSUTF8StringEncoding];
    }
  }
  
  asl_release(response);
  
  return foundFacility;
}

- (int)_logLevelToAslLevel:(LogLevel)logLevel {
  int aslLogLevel = ASL_LEVEL_DEBUG;
  switch(logLevel) {
    case LogLevelDebug:
      aslLogLevel = ASL_LEVEL_DEBUG;
      break;
    case LogLevelInfo:
      aslLogLevel = ASL_LEVEL_INFO;
      break;
    case LogLevelWarning:
      aslLogLevel = ASL_LEVEL_WARNING;
      break;
    case LogLevelError:
      aslLogLevel = ASL_LEVEL_ERR;
      break;
    case LogLevelFatal:
      aslLogLevel = ASL_LEVEL_CRIT;
      break;
  }
  return aslLogLevel;
}

- (int)_aslLevelToLogLevel:(int)aslLevel {
  int aslLogLevel = ASL_LEVEL_DEBUG;
  switch(aslLevel) {
    case ASL_LEVEL_DEBUG:
      aslLogLevel = LogLevelDebug;
      break;
    case ASL_LEVEL_INFO:
    case ASL_LEVEL_NOTICE:
      aslLogLevel = LogLevelInfo;
      break;
    case ASL_LEVEL_WARNING:
      aslLogLevel = LogLevelWarning;
      break;
    case ASL_LEVEL_ERR:
      aslLogLevel = LogLevelError;
      break;
    case ASL_LEVEL_CRIT:
    case ASL_LEVEL_ALERT:
    case ASL_LEVEL_EMERG:
      aslLogLevel = LogLevelFatal;
      break;
  }
  return aslLogLevel;
}
@end
