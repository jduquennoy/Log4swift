//: Playground - noun: a place where people can play

import Log4swift

// This playground demonstrates the simplest possible use of Log4Swift.
// This approach is only interesting if you are working on a project that is not meant to grow big :
// logs cannot be sorted by categories, which might make them much less usefull if you have lots of them.

// You can issue a log in one simple line.
// This uses the default root logger, that will print your log message to the standard output using NSLog.
Logger.info("Hello world !")

// You can change the threshold level when using this simple method by accessing the root logger :
LoggerFactory.sharedInstance.rootLogger.thresholdLevel = .Warning
Logger.info("This log will be ignored")
Logger.warning("This log will be issued to stdout")
Logger.error("This log will be issued to stderr")

// Log with closures allow you to avoid running message composition code if log is blocked by thresholds
LoggerFactory.sharedInstance.rootLogger.thresholdLevel = .Warning
Logger.info {
  return "This closure will not be executed"
}
Logger.warning {
  return "This closure will be executed"
}
