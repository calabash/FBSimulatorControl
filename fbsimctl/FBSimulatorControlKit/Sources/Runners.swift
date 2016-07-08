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
import FBControlCore

/**
 Some work, yielding a result.
 */
protocol Runner {
  func run() -> CommandResult
}

/**
 Joins multiple Runners together.
 */
struct SequenceRunner : Runner {
  let runners: [Runner]

  func run() -> CommandResult {
    var output = CommandResult.Success
    for runner in runners {
      output = output.append(runner.run())
      switch output {
      case .Failure: return output
      default: continue
      }
    }
    return output
  }
}

/**
 Wraps a CommandResult in a runner
 */
struct CommandResultRunner : Runner {
  let result: CommandResult

  func run() -> CommandResult {
    return self.result
  }

  static var unimplemented: Runner { get {
    return CommandResultRunner(result: CommandResult.Failure("Unimplemented"))
  }}
}

extension CommandResult {
  func asRunner() -> Runner {
    return CommandResultRunner(result: self)
  }
}

/**
 Wraps a Synchronous Relay in a Runner.
 */
struct RelayRunner : Runner {
  let relay: SynchronousRelay

  func run() -> CommandResult {
    do {
      try relay.start()
      try relay.stop()
      return .Success
    } catch let error as CustomStringConvertible {
      return .Failure(error.description)
    } catch {
      return .Failure("An unknown error occurred running the server")
    }
  }
}
