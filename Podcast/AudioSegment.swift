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

public struct AutoTranscriptionSegment: Codable, Equatable, Identifiable {
  public let id = UUID()
  var text: String {
    didSet {
      modified = true
    }
  }
  var modified: Bool = false
  let alternatives: [String]
  let start: TimeInterval
  let duration: TimeInterval
}
