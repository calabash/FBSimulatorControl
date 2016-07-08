/**
 * Copyright (c) 2015-present, Facebook, Inc.
 * All rights reserved.
 *
 * This source code is licensed under the BSD-style license found in the
 * LICENSE file in the root directory of this source tree. An additional grant
 * of patent rights can be found in the PATENTS file in the same directory.
 */

import Foundation
import FBSimulatorControl

public class SimulatorReporter : NSObject, FBSimulatorEventSink, iOSReporter {
  unowned public let simulator: FBSimulator
  public let reporter: EventReporter
  public let format: FBiOSTargetFormat

  init(simulator: FBSimulator, format: FBiOSTargetFormat, reporter: EventReporter) {
    self.simulator = simulator
    self.reporter = reporter
    self.format = format
    super.init()
    simulator.userEventSink = self
  }

  public var target: FBiOSTarget { get {
    return self.simulator
  }}

  public func containerApplicationDidLaunch(applicationProcess: FBProcessInfo) {
    self.reportValue(EventName.Launch, EventType.Discrete, applicationProcess)
  }

  public func containerApplicationDidTerminate(applicationProcess: FBProcessInfo, expected: Bool) {
    self.reportValue(EventName.Terminate, EventType.Discrete, applicationProcess)
  }

  public func connectionDidConnect(connection: FBSimulatorConnection) {
    self.reportValue(EventName.Launch, EventType.Discrete, connection)
  }

  public func connectionDidDisconnect(connection: FBSimulatorConnection, expected: Bool) {
    self.reportValue(EventName.Terminate, EventType.Discrete, connection)
  }

  public func testmanagerDidConnect(testManager: FBTestManager) {

  }

  public func testmanagerDidDisconnect(testManager: FBTestManager) {

  }

  public func simulatorDidLaunch(launchdProcess: FBProcessInfo) {
    self.reportValue(EventName.Launch, EventType.Discrete, launchdProcess)
  }

  public func simulatorDidTerminate(launchdProcess: FBProcessInfo, expected: Bool) {
    self.reportValue(EventName.Terminate, EventType.Discrete, launchdProcess)
  }

  public func agentDidLaunch(launchConfig: FBAgentLaunchConfiguration, didStart agentProcess: FBProcessInfo, stdOut: NSFileHandle, stdErr: NSFileHandle) {
    self.reportValue(EventName.Launch, EventType.Discrete, agentProcess)
  }

  public func agentDidTerminate(agentProcess: FBProcessInfo, expected: Bool) {
    self.reportValue(EventName.Terminate, EventType.Discrete, agentProcess)
  }

  public func applicationDidLaunch(launchConfig: FBApplicationLaunchConfiguration, didStart applicationProcess: FBProcessInfo) {
    self.reportValue(EventName.Launch, EventType.Discrete, applicationProcess)
  }

  public func applicationDidTerminate(applicationProcess: FBProcessInfo, expected: Bool) {
    self.reportValue(EventName.Terminate, EventType.Discrete, applicationProcess)
  }

  public func diagnosticAvailable(log: FBDiagnostic) {
    self.reportValue(EventName.Diagnostic, EventType.Discrete, log)
  }

  public func didChangeState(state: FBSimulatorState) {
    self.reportValue(EventName.StateChange, EventType.Discrete, state.description as NSString)
  }

  public func terminationHandleAvailable(terminationHandle: FBTerminationHandleProtocol) {

  }
}
