/**
 * Copyright (c) 2015-present, Facebook, Inc.
 * All rights reserved.
 *
 * This source code is licensed under the BSD-style license found in the
 * LICENSE file in the root directory of this source tree. An additional grant
 * of patent rights can be found in the PATENTS file in the same directory.
 */

#import <XCTest/XCTest.h>

#import <FBControlCore/FBControlCore.h>
#import <XCTestBootstrap/XCTestBootstrap.h>
#import <FBDeviceControl/FBDeviceControl.h>

@interface FBDeviceControlLinkerTests : XCTestCase

@end

@interface Rep : NSObject<FBTestManagerTestReporter>
@end

@implementation FBDeviceControlLinkerTests

- (void)setUp {
    self.continueAfterFailure = NO;
}

- (void)testTheTest {
    NSError *err;
    FBDevice *device = [[FBDeviceSet defaultSetWithLogger:nil
                                                    error:&err] deviceWithUDID:@"718ab8dbee0173b3f9ebfb01c5688b89221702c6"];
    
    if (err) {
        DDLogError(@"Error creating device operator: %@", err);
        return;
    }

    
//    setenv("DEVELOPER_DIR", "/Users/chrisf/Xcodes/8.1/Xcode-beta.app/Contents/Developer", 1);
    
    Rep *rep = [Rep new];
    NSUUID *sessionID = [[NSUUID alloc] initWithUUIDString:@"AAAAAAAA-BBBB-CCCC-DDDD-EEEEEEEEEEEE"];
    [FBXCTestRunStrategy startTestManagerForDeviceOperator:device.deviceOperator
                                            runnerBundleID:@"com.apple.test.DeviceAgent-Runner"
                                                 sessionID:sessionID
                                            withAttributes:[FBTestRunnerConfigurationBuilder defaultBuildAttributes]
                                               environment:[FBTestRunnerConfigurationBuilder defaultBuildEnvironment]
                                                  reporter:rep
                                                    logger:FBControlCoreGlobalConfiguration.defaultLogger
                                                     error:&err];
     
    
    XCTAssertNil(err, @"%@", err);
    [[NSRunLoop mainRunLoop] run];
}

+ (void)initialize
{
  if (!NSProcessInfo.processInfo.environment[FBControlCoreStderrLogging]) {
    setenv(FBControlCoreStderrLogging.UTF8String, "YES", 1);
  }
  if (!NSProcessInfo.processInfo.environment[FBControlCoreDebugLogging]) {
    setenv(FBControlCoreDebugLogging.UTF8String, "NO", 1);
  }
}

- (void)testLinksPrivateFrameworks
{
  [FBDeviceControlFrameworkLoader initializeEssentialFrameworks];
  [FBDeviceControlFrameworkLoader initializeXCodeFrameworks];
}

- (void)testConstructsDeviceSet
{
  NSError *error = nil;
  FBDeviceSet *deviceSet = [FBDeviceSet defaultSetWithLogger:FBControlCoreGlobalConfiguration.defaultLogger error:&error];
  XCTAssertNil(error);
  XCTAssertNotNil(deviceSet);
  XCTAssertNotNil(deviceSet.allDevices);
}

- (void)testLazilyFetchesDVTClasses
{
  NSError *error = nil;
  FBDeviceSet *deviceSet = [FBDeviceSet defaultSetWithLogger:FBControlCoreGlobalConfiguration.defaultLogger error:&error];
  XCTAssertNil(error);
  XCTAssertNotNil([deviceSet.allDevices valueForKey:@"description"]);
  XCTAssertEqual(deviceSet.allDevices.count, [[[deviceSet.allDevices valueForKey:@"deviceOperator"] filteredArrayUsingPredicate:NSPredicate.notNullPredicate] count]);
}

- (void)testReadsFromMobileDevice
{
  NSArray<FBAMDevice *> *devices = [FBAMDevice allDevices];
  XCTAssertNotNil(devices);
}

@end

@implementation Rep

- (void)testManagerMediatorDidBeginExecutingTestPlan:(FBTestManagerAPIMediator *)mediator {
    DDLogInfo(@"%@", NSStringFromSelector(_cmd));
}

- (void)testManagerMediator:(FBTestManagerAPIMediator *)mediator testSuite:(NSString *)testSuite didStartAt:(NSString *)startTime {
    DDLogInfo(@"%@", NSStringFromSelector(_cmd));
}

- (void)testManagerMediator:(FBTestManagerAPIMediator *)mediator testCaseDidFinishForTestClass:(NSString *)testClass method:(NSString *)method withStatus:(FBTestReportStatus)status duration:(NSTimeInterval)duration {
    DDLogInfo(@"%@", NSStringFromSelector(_cmd));
}

- (void)testManagerMediator:(FBTestManagerAPIMediator *)mediator testCaseDidFailForTestClass:(NSString *)testClass method:(NSString *)method withMessage:(NSString *)message file:(NSString *)file line:(NSUInteger)line {
    DDLogInfo(@"%@", NSStringFromSelector(_cmd));
}

- (void)testManagerMediator:(FBTestManagerAPIMediator *)mediator testBundleReadyWithProtocolVersion:(NSInteger)protocolVersion minimumVersion:(NSInteger)minimumVersion {
    DDLogInfo(@"%@", NSStringFromSelector(_cmd));
}

- (void)testManagerMediator:(FBTestManagerAPIMediator *)mediator testCaseDidStartForTestClass:(NSString *)testClass method:(NSString *)method {
    DDLogInfo(@"%@", NSStringFromSelector(_cmd));
}

- (void)testManagerMediator:(FBTestManagerAPIMediator *)mediator finishedWithSummary:(FBTestManagerResultSummary *)summary {
    DDLogInfo(@"%@", NSStringFromSelector(_cmd));
}

- (void)testManagerMediatorDidFinishExecutingTestPlan:(FBTestManagerAPIMediator *)mediator {
    DDLogInfo(@"%@", NSStringFromSelector(_cmd));
}

@end
