#!/bin/bash

# Clean before building
rm -rf DerivedData 2>/dev/null
rm -rf Pods 2>/dev/null
rm Podfile.lock 2>/dev/null

pod install
xcodebuild build -workspace Log4swiftTestApp.xcworkspace -scheme Log4swiftTestApp
