# Log4swift versions changelog

## 1.0b3 (2015-10-01)

### Enhancements
- Origin file and line number markers added to the PatternFormatter. When logging from Objective-C, this requires the use of specific methods with file and line arguments.
- StdOutAppender can now colorize both the text and its background, for Xcode with the Xcodecolors (https://github.com/robbiehanson/XcodeColors) and XTerm-color. Colors can be set using configuration dictionary, and in swift code. It is not possible in objective-c code, due to the use of unsupported features (advanced enums).
- PatternFormatter now uses returns unmodified messages when initialized without a pattern.
 
## 1.0b2 (2015-08-15)
- First version 
