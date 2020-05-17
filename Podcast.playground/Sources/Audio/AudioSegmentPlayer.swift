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

public class AudioSegmentPlayer: NSObject, ObservableObject {
  private let player: AVAudioPlayer
  private let synthesizer = AVSpeechSynthesizer()
  public init(url: URL = defaultAudioURL) {
    player = try! AVAudioPlayer(contentsOf: url)
    super.init()
    player.prepareToPlay()
    synthesizer.delegate = self
  }

  public typealias CompletionHandler = () -> Void


  public func play(
    segments: [AudioSegment],
    onIndex: ((Int) -> Void)? = nil,
    onComplete: CompletionHandler? = nil
  ) {
    var processed = segments
    for i in processed.indices.dropLast().reversed() {
      let j = i + 1
      if processed[i].originalIndex + 1 == processed[j].originalIndex {
        processed[i] = AudioSegment(
          text: "\(processed[i].text) \(processed[j].text)",
          alternatives: ["COMBINED SEGMENT"],
          originalIndex: processed[i].originalIndex,
          start: processed[i].start,
          duration: processed[j].end - processed[i].start
        )
        processed.remove(at: j)
      }
    }
    play(partialSegments: processed, onIndex: onIndex, onComplete: onComplete)
  }

  private func play<S: Collection>(
    partialSegments segments: S,
    onIndex: ((S.Index) -> Void)? = nil,
    onComplete: CompletionHandler? = nil
  ) where S.Element == AudioSegment {
    guard !segments.isEmpty else {
      onComplete?()
      return
    }
    onIndex?(segments.startIndex)
    play(segment: segments.first!) {
      DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
        guard let self = self else { onComplete?(); return }
        self.play(
          partialSegments: segments.dropFirst(),
          onIndex: onIndex,
          onComplete: onComplete
        )
      }
    }
  }

  public func play(segment: AudioSegment,
                   onComplete: CompletionHandler? = nil) {
    guard segment.isTranscribed else {
      return generateSegment(segment, onComplete: onComplete)
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
      guard let self = self else {
        timer.invalidate()
        onComplete?()
        return
      }
      if self.player.currentTime > end {
        timer.invalidate()
        self.player.pause()
        #if !os(macOS)
        try? AVAudioSession.sharedInstance()
          .setActive(false, options: .notifyOthersOnDeactivation)
        #endif
        onComplete?()
      }
    }
    player.currentTime = start
    player.play()
  }
  var onComplete: [AVSpeechUtterance: CompletionHandler] = [:]
}

import NaturalLanguage

extension AudioSegmentPlayer: AVSpeechSynthesizerDelegate {
  private func generateSegment(_ segment: AudioSegment, onComplete: CompletionHandler?) {
    let toSpeak = AVSpeechUtterance(string: segment.text)
    toSpeak.voice
      = segment.alternatives.first.flatMap(AVSpeechSynthesisVoice.init(identifier:))
      ?? segment.text.dominantLanguage.flatMap(AVSpeechSynthesisVoice.init(language:))
    if synthesizer.isSpeaking {
      synthesizer.stopSpeaking(at: .word)
    }
    self.onComplete[toSpeak] = onComplete
    synthesizer.speak(toSpeak)
  }

  public func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer,
                                didFinish utterance: AVSpeechUtterance) {
    let handler = onComplete[utterance]
    onComplete[utterance] = nil
    handler?()
  }
}

fileprivate let tagger = NLTagger(tagSchemes: [.language])
extension String {
  var dominantLanguage: String? {
    tagger.string = self
    return tagger.dominantLanguage?.rawValue
  }
}
