//
//  AudioSegment.swift
//  Podcast
//
//  Created by Apollo Zhu on 5/16/20.
//  Copyright © 2020 Apollonyan. All rights reserved.
//

import Foundation

public struct AudioSegment: Codable {
  var text: String
  var start: TimeInterval
  var duration: TimeInterval
}
