//
//  AudioComposer.swift
//  Podcast
//
//  Created by Apollo Zhu on 5/17/20.
//  Copyright © 2020 Apollonyan. All rights reserved.
//

import Foundation
import AVFoundation
import Combine

class AudioComposer: ObservableObject {
  enum State {
    case processing
    case canNotTranscribe(AudioAnalyzer.NoTranscription)
    case errored(Error)
  }

  @Published
  public private(set) var state: State = .processing
  private func setState(_ newState: State) {
    DispatchQueue.main.async { [weak self] in
      self?.state = newState
    }
  }
  private let analyzer: AudioAnalyzer

  convenience init(fileURL: URL = defaultAudioURL) {
    self.init(analyzer: AudioAnalyzer(analyzing: fileURL))
  }

  private lazy var subscription: AnyCancellable =
    analyzer.publisher(for: \.segments)
      .receive(on: DispatchQueue.main)
      .sink(receiveValue: composeAudio)

  deinit {
    subscription.cancel()
  }

  init(analyzer: AudioAnalyzer) {
    self.analyzer = analyzer
    _ = subscription
    let composition = AVMutableComposition()
    let asset = AVAsset(url: analyzer.fileURL)
    do {
      try composition.insertTimeRange(
        CMTimeRange(start: .zero, duration: asset.duration),
        of: asset, at: .zero
      )
    } catch {
      setState(.errored(error))
    }


    //
    //    // now edit as required, e.g. delete a time range
    //    let startTime = CMTime(seconds: endTimeOfRange1, preferredTimescale: 100)
    //    let endTime = CMTime(seconds: startTimeOfRange2, preferredTimescale: 100)
    //    composition.removeTimeRange( CMTimeRangeFromTimeToTime( startTime, endTime))
    //
    //    // since AVMutableComposition is an AVAsset subclass, it can be exported with AVAssetExportSession (or played with an AVPlayer(Item))
    //    if let exporter = AVAssetExportSession(asset: composition, presetName: AVAssetExportPresetAppleM4A)
    //    {
    //        // configure session and exportAsynchronously as above.
    //        // You don't have to set the timeRange of the exportSession
    //    }
  }

  private func composeAudio(_ segments: [AudioSegment]) {
    for segment in segments {
      
    }
  }
}
