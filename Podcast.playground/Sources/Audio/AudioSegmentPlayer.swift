//
//  AudioSegmentPlayer.swift
//  Podcast
//
//  Created by Apollo Zhu on 5/17/20.
//  Copyright © 2020 Apollonyan. All rights reserved.
//

import Foundation
import AVFoundation
import Combine

public class AudioSegmentPlayer: ObservableObject {
  private let player: AVAudioPlayer
  private let synthesizer = AVSpeechSynthesizer()
  public init(url: URL = defaultAudioURL) {
    player = try! AVAudioPlayer(contentsOf: url)
    player.prepareToPlay()
  }

  func play(segment: AudioSegment) {
    guard segment.isTranscribed else {
      return generateSegment(segment)
    }
    #if !os(macOS)
    try? AVAudioSession.sharedInstance()
      .setCategory(.playback, mode: .default)
    try? AVAudioSession.sharedInstance()
      .setActive(true, options: .notifyOthersOnDeactivation)
    #endif

    let (start, end) = (segment.start, segment.end)
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

import NaturalLanguage

extension AudioSegmentPlayer {
  private func generateSegment(_ segment: AudioSegment) {
    let toSpeak = AVSpeechUtterance(string: segment.text)
    toSpeak.voice
      = segment.alternatives.first.flatMap(AVSpeechSynthesisVoice.init(identifier:))
      ?? segment.text.dominantLanguage.flatMap(AVSpeechSynthesisVoice.init(language:))
    synthesizer.stopSpeaking(at: .word)
    synthesizer.speak(toSpeak)
  }
}

fileprivate let tagger = NLTagger(tagSchemes: [.language])
extension String {
  var dominantLanguage: String? {
    tagger.string = self
    return tagger.dominantLanguage?.rawValue
  }
}