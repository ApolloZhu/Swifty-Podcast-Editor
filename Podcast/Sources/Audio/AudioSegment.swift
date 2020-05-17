//
//  AudioSegment.swift
//  Podcast
//
//  Created by Apollo Zhu on 5/16/20.
//  Copyright © 2020 Apollonyan. All rights reserved.
//

import Foundation

/// For generated audio, store information in alternatives and set modified to true.
/// Set start to -2 and duration to -2 as special flag.
public struct AudioSegment: Codable, Hashable, Identifiable {
  public let id = UUID()
  var text: String {
    didSet {
      modified = true
    }
  }
  var modified: Bool = false
  let alternatives: [String]
  let originalIndex: Int
  let start: TimeInterval
  let duration: TimeInterval
  
  var end: TimeInterval {
    return start + duration
  }
}

import AVFoundation

extension AudioSegment {

  public var isTranscribed: Bool {
    return start != -2 && end != -2
  }

  init(text: String, voiceIdentifier: String? = nil) {
    self.init(
      text: text, modified: true,
      alternatives: voiceIdentifier.map { [$0] } ?? [],
      originalIndex: -2, start: -2, duration: -2
    )
  }

  init(text: String, voice: AVSpeechSynthesisVoice) {
    self.init(text: text, voiceIdentifier: voice.identifier)
  }
}
