/**
 * Copyright (c) 2015-present, Facebook, Inc.
 * All rights reserved.
 *
 * This source code is licensed under the BSD-style license found in the
 * LICENSE file in the root directory of this source tree. An additional grant
 * of patent rights can be found in the PATENTS file in the same directory.
 */

#import "FBXCTestRunStrategy.h"
#import <Foundation/Foundation.h>
#import <FBControlCore/FBControlCore.h>
#import "FBDeviceOperator.h"
#import "FBProductBundle.h"
#import "FBTestManager.h"
#import "FBTestManagerResult.h"
#import "FBTestManagerContext.h"
#import "FBTestRunnerConfiguration.h"
#import "FBXCTestPreparationStrategy.h"
#import "XCTestBootstrapError.h"
#import <CocoaLumberjack/CocoaLumberjack.h>

static const DDLogLevel ddLogLevel = DDLogLevelDebug;

@interface FBXCTestRunStrategy ()

@property (nonatomic, strong, readonly) id<FBDeviceOperator> deviceOperator;
@property (nonatomic, strong, readonly) id<FBXCTestPreparationStrategy> prepareStrategy;
@property (nonatomic, strong, readonly) id<FBTestManagerTestReporter> reporter;
@property (nonatomic, strong, readonly) id<FBControlCoreLogger> logger;

@end

@implementation FBXCTestRunStrategy

#pragma mark Initializers

+ (instancetype)strategyWithDeviceOperator:(id<FBDeviceOperator>)deviceOperator testPrepareStrategy:(id<FBXCTestPreparationStrategy>)testPrepareStrategy reporter:(nullable id<FBTestManagerTestReporter>)reporter logger:(nullable id<FBControlCoreLogger>)logger
{
  return [[self alloc] initWithDeviceOperator:deviceOperator testPrepareStrategy:testPrepareStrategy reporter:reporter logger:logger];
}

- (instancetype)initWithDeviceOperator:(id<FBDeviceOperator>)deviceOperator testPrepareStrategy:(id<FBXCTestPreparationStrategy>)prepareStrategy reporter:(nullable id<FBTestManagerTestReporter>)reporter logger:(nullable id<FBControlCoreLogger>)logger
{
  self = [super init];
  if (!self) {
    return nil;
  }

  _deviceOperator = deviceOperator;
  _prepareStrategy = prepareStrategy;
  _reporter = reporter;
  _logger = logger;

  return self;
}

#pragma mark Public

- (nullable FBTestManager *)startTestManagerWithAttributes:(NSArray<NSString *> *)attributes environment:(NSDictionary<NSString *, NSString *> *)environment error:(NSError **)error
{
  NSAssert(self.deviceOperator, @"Device operator is needed to perform meaningful test");
  NSAssert(self.prepareStrategy, @"Test preparation strategy is needed to perform meaningful test");

  NSError *innerError;
  FBTestRunnerConfiguration *configuration = [self.prepareStrategy prepareTestWithDeviceOperator:self.deviceOperator error:&innerError];
  if (!configuration) {
    return [[[XCTestBootstrapError
      describe:@"Failed to prepare test runner configuration"]
      causedBy:innerError]
      fail:error];
  }

  FBApplicationLaunchConfiguration *appLaunch = [FBApplicationLaunchConfiguration
    configurationWithBundleID:configuration.testRunner.bundleID
    bundleName:configuration.testRunner.bundleID
    arguments:[FBXCTestRunStrategy argumentsFromConfiguration:configuration attributes:attributes]
    environment:[FBXCTestRunStrategy environmentFromConfiguration:configuration environment:environment]
    options:0];

  if (![self.deviceOperator launchApplication:appLaunch error:&innerError]) {
    return [[[XCTestBootstrapError describe:@"Failed launch test runner"]
      causedBy:innerError]
      fail:error];
  }

  pid_t testRunnerProcessID = [self.deviceOperator processIDWithBundleID:configuration.testRunner.bundleID error:error];

  if (testRunnerProcessID < 1) {
    return [[XCTestBootstrapError
      describe:@"Failed to determine test runner process PID"]
      fail:error];
  }

  // Make the Context for the Test Manager.
  FBTestManagerContext *context = [FBTestManagerContext
    contextWithTestRunnerPID:testRunnerProcessID
    testRunnerBundleID:configuration.testRunner.bundleID
    sessionIdentifier:configuration.sessionIdentifier];

  // Attach to the XCTest Test Runner host Process.
  FBTestManager *testManager = [FBTestManager
    testManagerWithContext:context
    operator:self.deviceOperator
    reporter:self.reporter
    logger:self.logger];

  FBTestManagerResult *result = [testManager connectWithTimeout:FBControlCoreGlobalConfiguration.regularTimeout];
  if (result) {
    return[[[XCTestBootstrapError
      describeFormat:@"Test Manager Connection Failed: %@", result.description]
      causedBy:result.error]
      fail:error];
  }
  return testManager;
}


+ (FBTestManager *)startTestManagerForDeviceOperator:(id<FBDeviceOperator>)deviceOperator
                                      runnerBundleID:(NSString *)bundleID
                                           sessionID:(NSUUID *)sessionID
                                      withAttributes:(NSArray *)attributes
                                         environment:(NSDictionary *)environment
                                            reporter:(id<FBTestManagerTestReporter>)reporter
                                              logger:(id<FBControlCoreLogger>)logger
                                               error:(NSError *__autoreleasing *)error {
    NSAssert(bundleID, @"Must provide test runner bundle ID in order to run a test");
    NSAssert(sessionID, @"Must provide a test session ID in order to run a test");
    
    DDLogInfo(@"SessionID: %@", sessionID);
    DDLogInfo(@"BundleID: %@", bundleID);
    
    NSError *innerError;
    
    FBApplicationLaunchConfiguration *appLaunch = [FBApplicationLaunchConfiguration
                                                   configurationWithBundleID:bundleID
                                                   bundleName:bundleID
                                                   arguments:attributes ?: @[]
                                                   environment:environment ?: @{}
                                                   options:0];
    
    if (![deviceOperator launchApplication:appLaunch error:&innerError]) {
        return [[[XCTestBootstrapError describe:@"Failed launch test runner"]
                 causedBy:innerError]
                fail:error];
    }
    
    pid_t testRunnerProcessID = [deviceOperator processIDWithBundleID:bundleID error:error];
    
    if (testRunnerProcessID < 1) {
        return [[XCTestBootstrapError
                 describe:@"Failed to determine test runner process PID"]
                fail:error];
    }
    
    FBTestManagerContext *context =
        [FBTestManagerContext contextWithTestRunnerPID:testRunnerProcessID
                                    testRunnerBundleID:bundleID
                                     sessionIdentifier:sessionID];
    
    // Attach to the XCTest Test Runner host Process.
    FBTestManager *testManager = [FBTestManager testManagerWithContext:context
                                                              operator:deviceOperator
                                                              reporter:reporter
                                                                logger:logger];
    
    FBTestManagerResult *result = [testManager connectWithTimeout:FBControlCoreGlobalConfiguration.regularTimeout];
    if (result) {
        return [[[XCTestBootstrapError
                 describeFormat:@"Test Manager Connection Failed: %@", result.description]
                causedBy:result.error]
               fail:error];
    }
    return testManager;
}
#pragma mark Private

+ (NSArray<NSString *> *)argumentsFromConfiguration:(FBTestRunnerConfiguration *)configuration attributes:(NSArray<NSString *> *)attributes
{
    return [(configuration.launchArguments ?: @[]) arrayByAddingObjectsFromArray:(attributes ?: @[])];
}

+ (NSDictionary<NSString *, NSString *> *)environmentFromConfiguration:(FBTestRunnerConfiguration *)configuration environment:(NSDictionary<NSString *, NSString *> *)environment
{
  NSMutableDictionary<NSString *, NSString *> *mEnvironment = (configuration.launchEnvironment ?: @{}).mutableCopy;
  if (environment) {
    [mEnvironment addEntriesFromDictionary:environment];
  }
  return [mEnvironment copy];
}

@end
