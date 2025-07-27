#!/bin/bash

echo "Resetting Swift Package Manager dependencies..."

# Remove all SPM-related caches and files
rm -rf .swiftpm
rm -rf ~/Library/Caches/org.swift.swiftpm
rm -rf ~/Library/Developer/Xcode/DerivedData/PawsInUs-*
find . -name "Package.resolved" -delete

# Remove the xcuserdata which might contain package references
rm -rf PawsInUs.xcodeproj/project.xcworkspace/xcuserdata
rm -rf PawsInUs.xcodeproj/xcuserdata

echo "Cleaning complete. Please:"
echo "1. Close Xcode completely"
echo "2. Open PawsInUs.xcodeproj"
echo "3. Wait for packages to resolve"
echo "4. Build the project"