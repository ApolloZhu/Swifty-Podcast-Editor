//
//  PodcastTranscriptionView.swift
//  Podcast
//
//  Created by Apollo Zhu on 5/16/20.
//  Copyright © 2020 Apollonyan. All rights reserved.
//

import SwiftUI

extension View {
  func styledTextSegment(backgroundColor: Color) -> some View {
    self.padding(.leading, 20)
      .padding(.trailing)
      .padding(.vertical, 5)
      .background(backgroundColor.opacity(0.3))
      .cornerRadius(5)
  }
}

struct PodcastTranscriptionView: View {
  @ObservedObject private var analyzer = AudioAnalyzer()
  @ObservedObject private var player = AudioSegmentPlayer()
  @State private var editMode = EditMode.active
  
  var body: some View {
    switch analyzer.state {
    case .processing(let text):
      return AnyView(Text(text + " ... (still processing)").padding())
    case .finished:
      return AnyView(
        CollectionView(data: self.analyzer.segments.indices) { i, base, locator in
          SegmentView(
            segment: self.$analyzer.segments[i],
            locator: locator,
            base: base,
            moveTo: { newIndex in
              self.analyzer.segments.insert(
                self.analyzer.segments.remove(at: i),
                at: max(min(newIndex, self.analyzer.segments.count), 0)
              )
          })
        }
        .environmentObject(player)
        .padding()
      )
    case .errored(let error):
      return AnyView(VStack {
        Text("Failed to transcribe.")
          .font(.title)
        Text(error.localizedDescription)
          .foregroundColor(Color.red)
      }.padding())
    case .canNotTranscribe(let reason):
      return AnyView(Text(reason.localizedDescription).padding())
    }
  }
}

struct PodcastTranscriptionView_Previews: PreviewProvider {
  static var previews: some View {
    PodcastTranscriptionView()
  }
}
