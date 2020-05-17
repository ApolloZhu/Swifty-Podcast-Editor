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
    self.padding(.horizontal)
      .padding(.vertical, 5)
      .background(backgroundColor.opacity(0.3))
      .cornerRadius(5)
  }
}

let player = AudioSegmentPlayer()

struct SegmentView: View {
  @Binding var segment: AutoTranscriptionSegment
  @State private var offset: CGSize = .zero

  var showNoSuggestions: Bool {
    return segment.alternatives.isEmpty
    || segment.modified
  }

  var body: some View {
    HStack {
      Button(action: {
        player.play(start: self.segment.start, end: self.segment.end)
      }) {
        Image(systemName: "play.circle.fill")
      }

      if showNoSuggestions {
        TextField("", text: $segment.text)
          .fixedSize()
      } else {
        HStack {
          TextField("", text: $segment.text)
            .fixedSize()
          Image(systemName: "doc.plaintext")
        }
        .contextMenu {
            ForEach(segment.alternatives, id: \.self) { alternative in
              Button(alternative) {
                self.segment.text = alternative
              }
            }
        }
      }
    }
    .styledTextSegment(backgroundColor: showNoSuggestions ? .gray : .purple)
    .offset(offset)
    .gesture(
      DragGesture()
        .onChanged { info in
          self.offset = info.translation
      }.onEnded { info in
        self.offset = info.translation
      }
    )
  }
}

struct PodcastTranscriptionView: View {
  @ObservedObject var analyzer = AudioAnalyzer()
  @State private var editMode = EditMode.active

  var body: some View {
    switch analyzer.state {
    case .processing(let text):
      return AnyView(Text(text + " ... (still processing)").padding())
    case .finished:
      return AnyView(
        CollectionView(data: self.analyzer.segments.indices) { i in
          SegmentView(segment: self.$analyzer.segments[i])
        }
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
