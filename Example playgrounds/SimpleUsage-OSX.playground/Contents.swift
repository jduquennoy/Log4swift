//: Playground - noun: a place where people can play

import Log4swift

// You can issue a log in one simple line.
// This uses the default root logger, that will print your log message to the standard output using NSLog.
Logger.info("Hello world !")

// You can change the threshold level when using this simple method by accessing the root logger :
LoggerFactory.sharedInstance.rootLogger.thresholdLevel = LogLevel.warning;
Logger.info("This log will be ignored")
Logger.warn("This log will be issued")