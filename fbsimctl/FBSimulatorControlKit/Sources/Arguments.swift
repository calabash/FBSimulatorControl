/**
 * Copyright (c) 2015-present, Facebook, Inc.
 * All rights reserved.
 *
 * This source code is licensed under the BSD-style license found in the
 * LICENSE file in the root directory of this source tree. An additional grant
 * of patent rights can be found in the PATENTS file in the same directory.
 */

import Foundation

struct Arguments {
  static func fromString(_ string: String) -> [String] {
    let characterSet = NSMutableCharacterSet()
    characterSet.formUnion(with: CharacterSet.alphanumerics)
    characterSet.formUnion(with: CharacterSet.symbols)
    characterSet.formUnion(with: CharacterSet.punctuationCharacters)
    characterSet.invert()

    return string
      .trimmingCharacters(in: characterSet as CharacterSet)
      .components(separatedBy: CharacterSet.whitespaces)
  }
}
