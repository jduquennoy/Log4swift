//: Playground - noun: a place where people can play

// This playground demonstrates how to build a log configuration in software.
// This can be useful to provide a default configuration without embedding a configuration file, or if you want to provide a GUI to change the logging levels

import Log4swift

// Create formatters
// PatternFormater init can throw an error if the pattern is not valid. Those errors are not handled in that exemple (but it should be in your code ;-) )
let rootFormatter = try! PatternFormatter(pattern: "[Root formatter][%l] - %m");
let consoleFormatter = try! PatternFormatter(pattern: "[%n][%l] - %m");
let errorFileFormatter = try! PatternFormatter(pattern: "[%d][%n] - %m");

// Create appenders
let consoleAppender = ConsoleAppender(identifier: "consoleAppender");
consoleAppender.formatter = consoleFormatter;

let errorFileAppender = FileAppender(identifier: "errorFileAppender", filePath: NSTemporaryDirectory().stringByAppendingPathComponent("log4swiftDemoPlayground-error.log"))
errorFileAppender.thresholdLevel = .Debug;
errorFileAppender.formatter = errorFileFormatter;

// Create loggers
let rootLogger = LoggerFactory.sharedInstance.rootLogger;
rootLogger.thresholdLevel = .Warning;
rootLogger.appenders[0].formatter = rootFormatter

let packageLogger = Logger(identifier: "package1", level: .Info, appenders: [consoleAppender, errorFileAppender]);
packageLogger.thresholdLevel = .Debug;

// Register additional loggers
try! LoggerFactory.sharedInstance.registerLogger(packageLogger);

// Use the loggers
var logger1 = Logger.getLogger("package1.feature1"); // This logger will be based on the "package1" logger
logger1.info("first log message");

var logger2 = Logger.getLogger("package2.feature1"); // This logger will be based on the root logger
logger2.warn("second log message");
