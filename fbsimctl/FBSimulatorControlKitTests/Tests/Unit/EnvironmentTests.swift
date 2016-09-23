/**
 * Copyright (c) 2015-present, Facebook, Inc.
 * All rights reserved.
 *
 * This source code is licensed under the BSD-style license found in the
 * LICENSE file in the root directory of this source tree. An additional grant
 * of patent rights can be found in the PATENTS file in the same directory.
 */

import XCTest
import FBSimulatorControl
@testable import FBSimulatorControlKit

class EnvironmentTests : XCTestCase {
  let testEnvironment = [
    "FBSIMCTL_CHILD_FOO" : "BAR",
    "PATH" : "IGNORE",
    "FBSIMCTL_CHILD_BING" : "BONG",
  ]

  func testAppendsEnvironmentToLaunchConfiguration() {
    let launchConfig = FBApplicationLaunchConfiguration(application: Fixtures.application, arguments: [], environment: [:], options: FBProcessLaunchOptions())
    let actual = Action.launchApp(launchConfig).appendEnvironment(testEnvironment)
    let expected  = Action.launchApp(launchConfig.withEnvironmentAdditions([
      "FOO" : "BAR",
      "BING" : "BONG",
    ]))
    XCTAssertEqual(expected, actual)
  }

  func testAppendsEnvironmentToXCTestLaunchConfiguration() {
    let launchConfig = FBApplicationLaunchConfiguration(application: Fixtures.application, arguments: [], environment: [:], options: FBProcessLaunchOptions())
    let actual = Action.launchXCTest(launchConfig, "com.example.App", nil).appendEnvironment(testEnvironment)
    let expected  = Action.launchXCTest(launchConfig.withEnvironmentAdditions([
      "FOO" : "BAR",
      "BING" : "BONG",
    ]), "com.example.App", nil)
    XCTAssertEqual(expected, actual)
  }
}
