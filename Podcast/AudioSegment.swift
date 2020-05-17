//
//  AudioSegment.swift
//  Podcast
//
//  Created by Apollo Zhu on 5/16/20.
//  Copyright © 2020 Apollonyan. All rights reserved.
//

import Foundation

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
  
  var end: TimeInterval {
    return start + duration
  }
}

import AVFoundation

public class AudioSegmentPlayer {
  private let player: AVAudioPlayer
  public init(url: URL = defaultURL) {
    player = try! AVAudioPlayer(contentsOf: url)
    player.prepareToPlay()
  }
  
  func play(start: TimeInterval, end: TimeInterval) {
    #if !os(macOS)
    try? AVAudioSession.sharedInstance()
      .setCategory(.playback, mode: .default)
    try? AVAudioSession.sharedInstance()
      .setActive(true, options: .notifyOthersOnDeactivation)
    #endif
    
    let interval = min(end, 0.05)
    Timer.scheduledTimer(withTimeInterval: interval, repeats: true) {
      [weak self] timer in
      
      guard let self = self else { return timer.invalidate() }
      if self.player.currentTime > end {
        self.player.pause()
        timer.invalidate()
        #if !os(macOS)
        try? AVAudioSession.sharedInstance()
          .setActive(false, options: .notifyOthersOnDeactivation)
        #endif
      }
    }
    player.currentTime = start
    player.play()
  }
}
