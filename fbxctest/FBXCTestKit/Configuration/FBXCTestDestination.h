/**
 * Copyright (c) 2015-present, Facebook, Inc.
 * All rights reserved.
 *
 * This source code is licensed under the BSD-style license found in the
 * LICENSE file in the root directory of this source tree. An additional grant
 * of patent rights can be found in the PATENTS file in the same directory.
 */

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol FBControlCoreConfiguration_Device;
@protocol FBControlCoreConfiguration_OS;
@class FBSimulatorConfiguration;

/**
 The Base Destination.
 */
@interface FBXCTestDestination : NSObject

/**
 The Path to the xctest executable.
 */
@property (nonatomic, copy, readonly) NSString *xctestPath;

@end

/**
 A MacOSX Destination
 */
@interface FBXCTestDestinationMacOSX : FBXCTestDestination

@end

/**
 An iPhoneSimulator Destination
 */
@interface FBXCTestDestinationiPhoneSimulator : FBXCTestDestination

/**
 The Designated Initializer

 @param device the device to use. If nil the default will be used.
 @param version the version to use. If nil the default will be used.
 @return a new iPhoneSimulator Destination.
 */
- (instancetype)initWithDevice:(nullable id<FBControlCoreConfiguration_Device>)device version:(nullable id<FBControlCoreConfiguration_OS>)version;

/**
 The Device Type, if provided.
 */
@property (nonatomic, strong, nullable, readwrite) id<FBControlCoreConfiguration_Device> device;

/**
 The Device OS, if provided.
 */
@property (nonatomic, strong, nullable, readwrite) id<FBControlCoreConfiguration_OS> version;

/**
 The Simulator Configuration.
 */
@property (nonatomic, strong, readwrite) FBSimulatorConfiguration *simulatorConfiguration;

@end

NS_ASSUME_NONNULL_END
