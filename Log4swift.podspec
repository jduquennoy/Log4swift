Pod::Spec.new do |s|
  s.name         = "Log4swift"
  s.version      = "1.0.4"
  s.summary      = "A looging library written in swift."

  s.description  = <<-DESC
                   Log4swift is a logging library similar in philosophy to log4j.
                   It is meant to be :

                   * very simple to use for simple cases
                   * extensively configurable for less simple cases
                   * taking advantage of the swift 2 language

                   DESC

  s.homepage     = "http://github.com/jduquennoy/Log4swift"
  
  s.license      = { :type => "Apache v2.0", :file => "LICENSE" }

  s.author       = { "Jerome Duquennoy" => "jerome@duquennoy.fr" }

  s.ios.deployment_target = "8.0"
  s.watchos.deployment_target = "2.0"
  s.osx.deployment_target = "10.10"

  s.source       = { :git => "https://github.com/jduquennoy/Log4swift.git", :tag => "v1.0.4" }

  s.source_files = "Log4swift", "Log4swift/**/*.{swift,h,m}", "Third parties/**/*.{h,m}"

  s.public_header_files = ["Log4swift/log4swift.h", "Third Parties/NSLogger/*.h", "Log4swift/Objective-c wrappers/*.h"]

  s.watchos.exclude_files = ["Third Parties/NSLogger/*", "Log4swift/Appenders/NSLoggerAppender.swift"]
end
