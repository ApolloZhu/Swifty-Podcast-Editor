//
//  Extensions.swift
//  Transcribe
//
//  Created by Apollo Zhu on 10/26/20.
//  Copyright © 2020 Apollonyan. All rights reserved.
//

import Foundation

extension TimeInterval {
  var timestamp: (hour: Int, minute: Int, seconds: Int, milliseconds: Int) {
    let h = Int(self / 3600)
    var interval = self.remainder(dividingBy: 3600)
    if interval < 0 { interval += 3600 }

    let m = Int(interval / 60)
    interval = interval.remainder(dividingBy: 60)
    if interval < 0 { interval += 60 }

    let s = Int(interval)
    interval = interval.remainder(dividingBy: 1)
    if interval < 0 { interval += 1 }

    let c = Int((interval * 1000).rounded())
    return (h, m, s, c)
  }

  var formatted: String {
    let (h, m, s, ms) = timestamp
    return String(format: "%02d:%02d:%02d.%03d", h, m, s, ms)
  }
}
