# Log4swift changelog

## 1.0

This is the first verison to drop the "beta" flag. After using it in different projects for a while, with no problem, it seems safe to advertise it as non beta now.

### Bug fixes
- Fixed a problem causing the FileAppender to erase log file on all new sessions (Thanks to josealobato for this fix)

### Pattern formatter enhancements (thanks to Darkdah for those improvements)
- Added a new marker to the pattern formatter:
  - %D: the date of the log using NSDateFormatter format (defined by [Unicode Technical Standard #35](http://www.unicode.org/reports/tr35/tr35-31/tr35-dates.html#Date_Format_Patterns)). This notably allows logging of miliseconds

## 1.0b5 (2016-03-22)

### General changes
- Code base updated to remove use of features deprecated as of swift 2.2

### Appenders enhancements
- TTY type for coloration can be forced if auto-detection does not work. This can be useful when debugging a module that will be loaded by another application (such as sytem extensions).

### Pattern formatter enhancements (thanks to Darkdah for those improvements)

- Added two markers to the pattern formatter :
  - %f: displays the name of the file where the log was issued (%F displays the full path)
  - %M: the name of the method in which the log message was sent

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
