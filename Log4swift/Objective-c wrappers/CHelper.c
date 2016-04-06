//
//  CHelper.c
//  Log4swift
//
//  Created by Markus Arndt on 05.04.16.
//  Copyright © 2016 jerome. All rights reserved.
//

#include <mach/mach.h>
#include <pthread.h>


uint64_t GetThreadID(pthread_t thread) {
  mach_port_name_t port = pthread_mach_thread_np(thread);
  thread_identifier_info_data_t info;
  mach_msg_type_number_t info_count = THREAD_IDENTIFIER_INFO_COUNT;
  kern_return_t kr = thread_info(port, THREAD_IDENTIFIER_INFO, (thread_info_t) &info, &info_count);
  
  if (kr != KERN_SUCCESS) {
    /* you can get a description of the error by calling
     * mach_error_string(kr)
     */
    return 0;
  } else {
    return info.thread_id;
  }
}
