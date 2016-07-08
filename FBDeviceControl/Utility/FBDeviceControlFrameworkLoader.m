/**
 * Copyright (c) 2015-present, Facebook, Inc.
 * All rights reserved.
 *
 * This source code is licensed under the BSD-style license found in the
 * LICENSE file in the root directory of this source tree. An additional grant
 * of patent rights can be found in the PATENTS file in the same directory.
 */

#import "FBDeviceControlFrameworkLoader.h"

#import <FBControlCore/FBControlCore.h>

#import <DVTFoundation/DVTDeviceManager.h>
#import <DVTFoundation/DVTDeviceType.h>
#import <DVTFoundation/DVTLogAspect.h>
#import <DVTFoundation/DVTPlatform.h>

#import <IDEFoundation/IDEFoundationTestInitializer.h>

#import "FBAMDevice.h"

@implementation FBDeviceControlFrameworkLoader

#pragma mark - Public

#pragma mark Essential Frameworks

+ (void)initializeEssentialFrameworks
{
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    [self loadEssentialFrameworksOrAbort];
    if (FBControlCoreGlobalConfiguration.debugLoggingEnabled) {
      [FBAMDevice enableDebugLogging];
    }
  });
}

+ (void)loadEssentialFrameworksOrAbort
{
  NSError *error = nil;
  id<FBControlCoreLogger> logger = FBControlCoreGlobalConfiguration.defaultLogger;
  BOOL success = [self loadEssentialFrameworks:logger error:&error];
  if (success) {
    [FBAMDevice loadFBAMDeviceSymbols];
    return;
  }

  [logger.error logFormat:@"Failed to load the essential frameworks for FBDeviceControl with error %@", error];
  abort();
}

+ (BOOL)loadEssentialFrameworks:(id<FBControlCoreLogger>)logger error:(NSError **)error
{
  NSArray<FBWeakFramework *> *frameworks = @[
    FBWeakFramework.MobileDevice,
  ];
  return [FBWeakFrameworkLoader loadPrivateFrameworks:frameworks logger:logger error:error];
}

#pragma mark Xcode Frameworks

+ (void)initializeXCodeFrameworks
{
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    [self loadXcodeFrameworksOrAbort];
    [self confirmExistenceOfClasses];
    [self initializePrincipalClasses];
  });
}

+ (void)loadXcodeFrameworksOrAbort
{
  NSArray<FBWeakFramework *> *frameworks = @[
    FBWeakFramework.DTXConnectionServices,
    FBWeakFramework.DVTFoundation,
    FBWeakFramework.IDEFoundation,
    FBWeakFramework.IDEiOSSupportCore,
    FBWeakFramework.IBAutolayoutFoundation,
    FBWeakFramework.IDEKit,
    FBWeakFramework.IDESourceEditor,
  ];

  NSError *error = nil;
  id<FBControlCoreLogger> logger = FBControlCoreGlobalConfiguration.defaultLogger;
  BOOL success = [FBWeakFrameworkLoader loadPrivateFrameworks:frameworks logger:logger error:&error];
  if (success) {
    return;
  }

  [logger.error logFormat:@"Failed to load the xcode frameworks for FBDeviceControl with error %@", error];
  abort();
}

+ (void)confirmExistenceOfClasses
{
  NSArray<NSString *> *classNames = @[
    @"DVTDeviceManager",
    @"DVTDeviceType",
    @"DVTiOSDevice",
    @"DVTPlatform",
    @"DVTDeviceType",
  ];
  for (NSString *className in classNames) {
    Class class = NSClassFromString(className);
    NSAssert(class, @"Expected %@ to have been loaded", class);
  }
}

+ (void)initializePrincipalClasses
{
  NSError *error = nil;
  NSCAssert([NSClassFromString(@"IDEFoundationTestInitializer") initializeTestabilityWithUI:NO error:&error], @"Failed to initialize Testability %@", error);
  NSCAssert([NSClassFromString(@"DVTPlatform") loadAllPlatformsReturningError:&error], @"Failed to load all platforms: %@", error);
  NSCAssert([NSClassFromString(@"DVTPlatform") platformForIdentifier:@"com.apple.platform.iphoneos"] != nil, @"DVTPlatform hasn't been initialized yet.");
  NSCAssert([NSClassFromString(@"DVTDeviceType") deviceTypeWithIdentifier:@"Xcode.DeviceType.Mac"], @"Failed to load Xcode.DeviceType.Mac");
  NSCAssert([NSClassFromString(@"DVTDeviceType") deviceTypeWithIdentifier:@"Xcode.DeviceType.iPhone"], @"Failed to load Xcode.DeviceType.iPhone");
  [[NSClassFromString(@"DVTDeviceManager") defaultDeviceManager] startLocating];
}

+ (void)enableDVTDebugLogging
{
  [[NSClassFromString(@"DVTLogAspect") logAspectWithName:@"iPhoneSupport"] setLogLevel:10];
  [[NSClassFromString(@"DVTLogAspect") logAspectWithName:@"iPhoneSimulator"] setLogLevel:10];
  [[NSClassFromString(@"DVTLogAspect") logAspectWithName:@"DVTDevice"] setLogLevel:10];
  [[NSClassFromString(@"DVTLogAspect") logAspectWithName:@"Operations"] setLogLevel:10];
  [[NSClassFromString(@"DVTLogAspect") logAspectWithName:@"Executable"] setLogLevel:10];
  [[NSClassFromString(@"DVTLogAspect") logAspectWithName:@"CommandInvocation"] setLogLevel:10];
}

@end
