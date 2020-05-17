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

  private var segments = [AudioSegment]() {
    didSet {
//      composeAudio(oldSegments: oldValue, newSegments: segments)
    }
  }

  private lazy var subscription: AnyCancellable =
    analyzer.publisher(for: \.segments)
      .receive(on: DispatchQueue.main)
      .assign(to: \.segments, on: self)

  deinit {
    subscription.cancel()
  }

  let composition = AVMutableComposition()

  init(analyzer: AudioAnalyzer) {
    self.analyzer = analyzer
    _ = subscription
    let asset = AVAsset(url: analyzer.fileURL)
    do {
      try composition.insertTimeRange(
        CMTimeRange(start: .zero, duration: asset.duration),
        of: asset, at: .zero
      )
    } catch {
      setState(.errored(error))
    }

    // since AVMutableComposition is an AVAsset subclass, it can be exported with AVAssetExportSession (or played with an AVPlayer(Item))
    //    if let exporter = AVAssetExportSession(asset: composition, presetName: AVAssetExportPresetAppleM4A)
    //    {
    //        // configure session and exportAsynchronously as above.
    //        // You don't have to set the timeRange of the exportSession
    //    }
  }

//  private func composeAudio(oldSegments: [AudioSegment], newSegments: [AudioSegment]) {
//    let diff = newSegments.difference(from: oldSegments).inferringMoves()
//    for difference in diff {
//      switch difference {
//      case .insert(offset: let offset, element: let element, associatedWith: _):
//        try? composition.insertTimeRange(<#T##timeRange: CMTimeRange##CMTimeRange#>, of: <#T##AVAsset#>, at: <#T##CMTime#>)
//      case .remove(offset: let offset, element: let element, associatedWith: _):
//        composition.removeTimeRange(<#T##timeRange: CMTimeRange##CMTimeRange#>)
//      }
//    }
//  }
}
