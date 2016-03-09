# Log4swift versions changelog

## 1.0 (not yet released)

### Appenders enhancements
- TTY type for coloration can be forced if auto-detection does not work. This can be useful when debugging a module that will be loaded by another application (such as sytem extensions).

### Pattern formatter enhancements (thanks to Darkdah for those improvements)

- Added two marker to the pattern formatter :
  - %f : displays the name of the file where the log was issued (%F displays the full path)
  - %M : the name of the method in which the log message was sent

### Log configuration

- Added log levels (thanks to Darkdah for those)
 - Off log level added. No messages can be logged with that level, it can only be used as a threshold level in the configuration, to mute a logger or an appender
 - Trace level added bellow debug
- Added possibility to automatically reload configuration file when modified

## 1.0b4 (2015-11-03)

### Loggers enhancements
- Loggers can log asynchronously. This new behavior is opt-in, using the configuration key *Asynchronous* in a configuration dictionary or the property *asynchronous* in code

### Pattern formatter enhancements (thanks to RegalMedia for those improvements)
- Markers now receives json-formatted options (**This can break your existing configuration**)
- New padding option is added to all markers

###  Misc Enhancements
- When configuring loggers with a dictionary (or a file), appenders class name are no longer case sensitive.
- Errors are reported with description in Objective-C. The use of a custom error type was causing all helpful informations to be lost when catching them in the objective-c world (as of swift 2.1, this has been reported to Apple as rdar://23287003)
- Some convenience one-line configuration method are added to LoggerFactory (*configureFor...* methods). This is available in swift only, because of the use of default values for parameters.

## 1.0b3 (2015-10-01)

### Misc Enhancements
- Origin file and line number markers added to the PatternFormatter. When logging from Objective-C, this requires the use of specific methods with file and line arguments.
- StdOutAppender can now colorize both the text and its background, for Xcode with the Xcodecolors (https://github.com/robbiehanson/XcodeColors) and XTerm-color. Colors can be set using configuration dictionary, and in swift code. It is not possible in objective-c code, due to the use of unsupported features (advanced enums).
- PatternFormatter now uses returns unmodified messages when initialized without a pattern.
 
## 1.0b2 (2015-08-15)
- First version 
