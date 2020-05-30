//
//  MultithreadingUtilities.swift
//  Log4swift
//
//  Created by Jérôme Duquennoy on 07/08/2018.
//  Copyright © 2018 jerome. All rights reserved.
//

import Foundation

internal final class PThreadMutex {
  public typealias MutexPrimitive = pthread_mutex_t
  
  public enum PThreadMutexType {
    case normal // PTHREAD_MUTEX_NORMAL
    case recursive // PTHREAD_MUTEX_RECURSIVE
  }
  
  public var unsafeMutex = pthread_mutex_t()
  
  /// - parameter type: wether the mutex is a normal or recursive one. Default value is normal.
  public init(type: PThreadMutexType = .normal) {
    var attr = pthread_mutexattr_t()
    guard pthread_mutexattr_init(&attr) == 0 else {
      preconditionFailure()
    }
    switch type {
    case .normal:
      pthread_mutexattr_settype(&attr, Int32(PTHREAD_MUTEX_NORMAL))
    case .recursive:
      pthread_mutexattr_settype(&attr, Int32(PTHREAD_MUTEX_RECURSIVE))
    }
    guard pthread_mutex_init(&unsafeMutex, &attr) == 0 else {
      preconditionFailure()
    }
    pthread_mutexattr_destroy(&attr)
  }
  
  deinit {
    pthread_mutex_destroy(&unsafeMutex)
  }
  
  public func unbalancedLock() {
    pthread_mutex_lock(&unsafeMutex)
  }
  
  public func unbalancedTryLock() -> Bool {
    return pthread_mutex_trylock(&unsafeMutex) == 0
  }
  
  public func unbalancedUnlock() {
    pthread_mutex_unlock(&unsafeMutex)
  }
}

internal extension PThreadMutex {
  /// Executes a closure as a critical section (not executable concurrently by different threads).
  func sync<R>(execute: () throws -> R) rethrows -> R {
    self.unbalancedLock()
    defer { self.unbalancedUnlock() }
    return try execute()
  }
}
