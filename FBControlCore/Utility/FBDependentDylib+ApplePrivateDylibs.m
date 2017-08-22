/**
 * Copyright (c) 2015-present, Facebook, Inc.
 * All rights reserved.
 *
 * This source code is licensed under the BSD-style license found in the
 * LICENSE file in the root directory of this source tree. An additional grant
 * of patent rights can be found in the PATENTS file in the same directory.
 */

#import "FBDependentDylib+ApplePrivateDylibs.h"
#import "FBXcodeConfiguration.h"

@implementation FBDependentDylib (ApplePrivateDylibs)

+ (NSArray<FBDependentDylib *> *)SwiftDylibs
{

  // Starting in Xcode 8.3, IDEFoundation.framework requires Swift libraries to
  // be loaded prior to loading the framework itself.
  //
  // You can inspect what libraries are loaded and in what order using:
  //
  // $ xcrun otool -l Xcode.app/Contents/Frameworks/IDEFoundation.framework
  //
  // The minimum macOS version for Xcode 8.3 is Sierra 10.12 so there is no need
  // to branch on the macOS version.
  //
  // The order matters!  The first swift dylib loaded by IDEFoundation.framework
  // is AppKit.  However, AppKit requires CoreImage and QuartzCore to be loaded
  // first.

  NSDecimalNumber *xcodeVersion = FBXcodeConfiguration.xcodeVersionNumber;
  NSDecimalNumber *xcode83 = [NSDecimalNumber decimalNumberWithString:@"8.3"];
  BOOL atLeastXcode83 = [xcodeVersion compare:xcode83] != NSOrderedAscending;

  NSDecimalNumber *xcode90 = [NSDecimalNumber decimalNumberWithString:@"9.0"];
  BOOL atLeastXcode90 = [xcodeVersion compare:xcode90] != NSOrderedAscending;

  if (atLeastXcode83) {
    NSArray *dylibs =
    @[
      [FBDependentDylib dependentWithRelativePath:@"../Frameworks/libswiftCore.dylib"],
      [FBDependentDylib dependentWithRelativePath:@"../Frameworks/libswiftDarwin.dylib"],
      [FBDependentDylib dependentWithRelativePath:@"../Frameworks/libswiftObjectiveC.dylib"],
      [FBDependentDylib dependentWithRelativePath:@"../Frameworks/libswiftDispatch.dylib"],
      [FBDependentDylib dependentWithRelativePath:@"../Frameworks/libswiftIOKit.dylib"],
      [FBDependentDylib dependentWithRelativePath:@"../Frameworks/libswiftCoreGraphics.dylib"],
      [FBDependentDylib dependentWithRelativePath:@"../Frameworks/libswiftFoundation.dylib"],
      [FBDependentDylib dependentWithRelativePath:@"../Frameworks/libswiftXPC.dylib"],
      [FBDependentDylib dependentWithRelativePath:@"../Frameworks/libswiftCoreImage.dylib"],
      [FBDependentDylib dependentWithRelativePath:@"../Frameworks/libswiftQuartzCore.dylib"],
      [FBDependentDylib dependentWithRelativePath:@"../Frameworks/libswiftCoreData.dylib"],
      [FBDependentDylib dependentWithRelativePath:@"../Frameworks/libswiftAppKit.dylib"]
      ];
    if (atLeastXcode90) {
      NSMutableArray *mutable = [NSMutableArray arrayWithArray:dylibs];
      FBDependentDylib *dylib = [FBDependentDylib dependentWithRelativePath:@"../Frameworks/libswiftCoreFoundation.dylib"];
      [mutable insertObject:dylib atIndex:4];

      dylib = [FBDependentDylib dependentWithRelativePath:@"../Frameworks/libswiftMetal.dylib"];
      [mutable insertObject:dylib atIndex:7];

      dylib = [FBDependentDylib dependentWithRelativePath:@"../Frameworks/libswiftos.dylib"];
      [mutable insertObject:dylib atIndex:7];

      dylibs = [NSArray arrayWithArray:mutable];
    }
    return dylibs;
  } else {
    // No swift dylibs are required.
    return @[];
  }
}

@end
