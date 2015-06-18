# Log4Swift
Log4Swift2 is a logging library written in swift 2. Therefore, **it requires xCode 7**.

**Note that is still a work in progress. It is by no mean full featured as of today.**

As long as it is not ready for use, no binary version will be available. You will have to download the source and compile it yourself. The good thing is that it is also the first step to contribute :-).


## Goal
The goal of this project is to propose a logging library with (at least) those caracteristics :

* straitforward to use for simple cases : default configuration should just work.
* powerful for more complexe cases, with multi-destination logging for exemple.
* configurable in multiple ways
    * by file : configuration can be stored in a plist file
    * by software : at init time or while running the program
* asynchronous by default to avoid slowing down the application, but with the ability to request a synchronous behavior if needed.
* it should be useable on linux once Apple releases Swift for that OS.

As stated above, the work is in progress, not all those goals are acheived, or even started.

## Concepts
The two main concepts of this library are borrowed from log4j :

### Loggers
Loggers are the objects to which logs are send at the first place.
They are identified by a UTI identifier (like "project.module.function") that are hierachical. When a log message is sent, the logger with the longest matching UTI will be responsible for dealing the log.
A root logger will deal with logs that matches no specific logger.

A logger defines a threshold level. Logs bellow this level will be ignored. Non ignored levels are sent to the appenders associated to the logger.

### Appenders
Appenders are responsible for writing the logs to their destination. They also have a threshold to filter out messages.

## Features
### Mutliple appenders per logger
One logger can have multiple appenders. You can for exemple define a logger that will log everything to the console, but that will also send error messages to a file for latter use.

```
let logger = Logger.getLogger("test.logger");
let consoleAppender = ConsoleAppender(identifier: "console");
let fileAppender = try FileAppender(identifier: "errorFile", filePath: "/var/log/error.log");

consoleAppender.thresholdLevel = .debug;
fileAppender.thresholdLevel = .error;
logger.appenders = [consoleAppender, fileAppender];

logger.debug ("This message will go to the console");
logger.error ("This message will go to the console and the error log file");
```

### Log with closures
Providing a closure instead of a string is pretty handy if the code that generates the message is heavy : the closure will only be executed if the logs are to be issued. No need to encapsulate the code in an if structure.

```
Logger.debug { someHeavyCodeThatGeneratesTheLogMessage() }
```