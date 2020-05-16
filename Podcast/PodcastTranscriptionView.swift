//
//  PodcastTranscriptionView.swift
//  Podcast
//
//  Created by Apollo Zhu on 5/16/20.
//  Copyright © 2020 Apollonyan. All rights reserved.
//

import SwiftUI

struct PodcastTranscriptionView: View {
  @ObservedObject var analyzer = AudioAnalyzer()
  var body: some View {
    Group<Text> {
      switch analyzer.state {
      case .processing(let text):
        return Text(text + " ... (still processing)")
      case .finished(let final):
        return Text(final + ".")
      case .errored(let error):
        return Text("""
          Failed to transcribe.
          \(error.localizedDescription)
          """)
          .foregroundColor(Color.red)
          .fontWeight(.bold)
      case .canNotTranscribe(let reason):
        return Text(reason.localizedDescription)
      }
    }
  }
}

struct PodcastTranscriptionView_Previews: PreviewProvider {
  static var previews: some View {
    PodcastTranscriptionView()
  }
}
