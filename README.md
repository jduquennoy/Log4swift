# Log4Swift
[![License](https://img.shields.io/badge/License-Apache%20v2.0-blue.svg?style=flat
            )](http://mit-license.org)
![Platform](http://img.shields.io/badge/platform-macOS,iOS,tvOS-lightgrey.svg?style=flat)
[![Language](http://img.shields.io/badge/language-swift-orange.svg?style=flat
             )](https://developer.apple.com/swift)
[![Cocoapod](http://img.shields.io/cocoapods/v/Log4swift.svg?style=flat)](http://cocoadocs.org/docsets/Log4swift/)
[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)
[![Travis-ci Build Status](https://travis-ci.org/jduquennoy/Log4swift.svg)](https://travis-ci.org/jduquennoy/Log4swift)

Log4Swift is a logging library for swift projects, that will allow you to log in a very flexible way.

Its ultimate goal is to be the tool you need to make your logs as valuable as possible, both in your developpment environment and in production.

## Compatibility
Current version requires Xcode 9 and swift 4.1.

- For swift 3, use version 1.0.2 ([tag v1.0.2](https://github.com/jduquennoy/Log4swift/releases/tag/v1.0.2))
- For swift 2.3, use version 1.0.0b5 ([tag v1.0.0b5](https://github.com/jduquennoy/Log4swift/releases/tag/v1.0.0b5))

It can be used in projects targetting either OS X (>= 10.10), iOS (>= iOS 8) or appleTV, and written either in swift or objective-C (or a mix of those two).

## How to use

### Manually
Clone the repo on your machine, and compile the target that feets your need (OS X, iOS, ...). It will produce a library that you can use in your project.
As long as the swift ABI is not stable, you will need to recompile the library if you change the version of the compiler used for your project. Because of that, you should rather consider one of the other methods (see bellow).

### CocoaPod
Add those lines to your Podfile to embed this library in an iOS project (with the versions you want for the lib and the target):

```
platform :ios, '8'
pod 'Log4swift', '1.0.4'
use_frameworks!
```
And in an OS X project :

```
platform :osx, '10.10'
pod 'Log4swift', '1.0.4'
use_frameworks!
```

### Carthage
Add this line to your Cartfile (with the version you want):

```
github "jduquennoy/Log4swift" ~> 1.0.4
```

## Features
Here are the main features you can expect from Log4swift :

* straightforward to use for simple cases : default configuration should just work, one-line configuration for typical uses like logging to IDE console or to system logs
* flexible for more complexe cases, with multi-destination logging, hierarchic loggers configuration, ...
* multiple destinations available, including network logging, using NSLogger
  * file logging
  * network logging using NSLogger
  * Xcode console logging, including colorized logs (with the XcodeColors plugin installed)
* dynamically configurable by code
* configurable by file, with auto-reload on update possibility (opt-in feature)
* asynchronous logging, performed on a secondary thread (opt-in feature). Async behavior can be activated per logger.


Another goal, that I think we all share, is to have readable and tested code.

* The code coverage of Log4swift's code (excluding third party code) is 100% for most of the source files, and very close to it for others.
* Feel free to send feedbacks or contribute if you find the code not readable enough, or if you have ideas to highen the quality of that code !

## Concepts
The three main concepts of this library are borrowed from log4j :

### Loggers
Loggers are the objects to which logs are send at the first place.
They are identified by a UTI identifier (like "project.module.function") that are hierachical. When a log message is sent, the logger with the longest matching UTI will be responsible for dealing the log.
A root logger will deal with logs that matches no specific logger.

A logger defines a threshold level. Logs bellow this level will be ignored. Non ignored levels are sent to the appenders associated to the logger.

### Appenders
Appenders are attached to loggers. They are responsible for writing the logs to their destination. They are identified by an identifier, that is used when loading configuration to attache appenders to their loggers. One appender might be attached to multiple loggers.

Appenders also have a threshold to filter out messages.

### Formatters
Formatters are attached to appenders. Their job is to modify the message to apply it a specific formatting before it is sent to its final destination. One formatter might be attached to multiple appenders.

## Some more details on features
### Mutliple appenders per logger
One logger can have multiple appenders. You can for exemple define a logger that will log everything to the console, but that will also log error messages to a file for latter use.

```
let logger = Logger.getLogger("test.logger");
let stdOutAppender = StdOutAppender("console");
let fileAppender = FileAppender(identifier: "errorFile", filePath: "/var/log/error.log");

stdOutAppender.thresholdLevel = .Debug;
fileAppender.thresholdLevel = .Error;
logger.appenders = [stdOutAppender, fileAppender];

logger.debug ("This message will go to the console");
logger.error ("This message will go to the console and the error log file");  }
```

(this code compiles on Xcode 7.3, using swift 2.2)

### Formatters associated to appenders
Formatters allows you to apply a specific formatting to your log message, either adding information to the logged message or modifying the message to have it complying to some constraintes.

Formatters are associated to appenders. This way, you can log human readable logs to Xcode's console, while logging with more info regexp friendly format in a file.

### Log with closures
Providing a closure instead of a string is pretty handy if the code that generates the message is heavy : the closure will only be executed if the logs are to be issued. No need to encapsulate the code in an if structure.

```
Logger.debug { someHeavyCodeThatGeneratesTheLogMessage() }
```

Note that creating the bloc is not completely free (some magic happen behind the scene, like variable capture). But for most uses, the cost should be negligible.

### Log asynchronously
Loggers can be configured individualy to log asynchronously. Asynchronous logging will return almost immediately when a log is requested, while the real log will be issued in background on a low priority thread.

Order of messages logged to asynchronous loggers is guaranteed.

Note that if asychronous loggers will execute logged closures later in time, and on an external thread.

### Flexible configuration
Loggers can be configured from a file, or using the library's API.

Using the API, you can use a dictionary, that can be stored and loaded from anywhere you want (a web service, a database, a preference file, ...).

Using a configuration file, you can request the configuration to be auto-reloaded each time the file is modified:

```
LoggerFactory.sharedInstance.readConfiguration(fromPlistFile: "/some/file.plist", autoReload: true)
```

Configuration can be modified at run time.

## Provided appenders

### The stdout appender
This appender will write log messages to stdout or stderr. It has two thresholds : the regular threshold, available on all appenders, and an error threshold.

* If the log level is bellow the general threshold, the message is ignored
* If the log level is above the general threshold but bellow the error threshold, the message is issued on stdout
* If the log level is above both the general and the error threshold, the message is issued on stderr

By default, the stdout appender is configured to send Error and Fatal messages to stderr, and all other levers to stdout.

This appender is a good choice for CLI tools.

### The file appender
This appender will write log messages to a file, specified by its path. It will create the file if needed (and possible), and will re-create it if it disapears. This allows log rotation scripts to avoid having to restart the process to ensure logs are recorded in a new file after rotation.

### The NSLogger appender
This appender uses NSLogger (https://github.com/fpillet/NSLogger) to send log messages over the network.
Not all capabilities of NSLogger are accessibles yet : only text messages can be logged.

### The ASL appender
The ASL appender sends log messages to the system logging service, provided by Apple. Your messages will we visible in the Console.app application if the ASL configuration has not been customized.

This appender is a good choice for release versions of softwares targetting exclusively systems that does not have the Unified Logging System.

**Note:** ASL has been deprecated by Apple starting with MacOS 10.12. The unified logger appender should be used instead of ASL for those platforms.

### The Unified Logging System appender
The unified logging system is the replacement of ASL starting with MacOS 10.12. This logger will log messages to this facility. Your messages will be visible in the Console.app application.

This appender is a good choice for release versions of software targetting 10.12 and latter.

### The system appender
This meta-appender will use the most appropriate system appender for the current system.

* for MacOS < 10.12, it will use the ASLAppender
* for MacOS >= 10.12, it will use the Unified Logging System appender.

This appender is the best choice for release versions of software targetting multiple versions of the system (most common case).


## Provided formatters

### The PatternFormatter

The PatternFormatter uses a simple textual pattern with marker identified by a '%' prefix to render the log messages.

As an exemple, this pattern :  
```
[%d][%l][%n] %m
```  
will produce this kind of log:  
```
[2015-02-02 12:45:23 +0000][Debug][logger.name] The message that was sent to the logger
```

See [this page](https://github.com/jduquennoy/Log4swift/wiki/Provided-Formatters) for more details, including a full list of available markers.
