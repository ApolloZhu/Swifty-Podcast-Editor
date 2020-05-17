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

let player = AudioSegmentPlayer()

struct SegmentView: View {
  @Binding var segment: TranscribedSegment
  @State private var offset: CGSize = .zero
  var locator: CollectionViewElementLocator
  var base: CGSize
  var moveTo: (Int) -> Void
  
  private var showNoSuggestions: Bool {
    return segment.alternatives.isEmpty
      || segment.modified
  }
  
  var body: some View {
    HStack {
      Button(action: {
        player.play(start: self.segment.start, end: self.segment.end)
      }) {
        #if os(macOS)
        Text("▶️")
        #else
        Image(systemName: "play.circle.fill")
        #endif
      }
      
      if showNoSuggestions {
        TextField("", text: $segment.text)
          .fixedSize()
      } else {
        HStack {
          TextField("", text: $segment.text)
            .fixedSize()
          #if os(macOS)
          Text("📝")
          #else
          Image(systemName: "doc.plaintext")
          #endif
        }
        .contextMenu {
          Button(segment.text) {
            self.segment.modified = true
          }
          ForEach(segment.alternatives, id: \.self) { alternative in
            Button(alternative) {
              self.segment.text = alternative
            }
          }
        }
      }
    }
    .styledTextSegment(backgroundColor:
      offset == .zero ? showNoSuggestions ? .gray : .purple : .green
    )
      .zIndex(offset == .zero ? 0 : 999)
      .offset(offset)
      .gesture(
        DragGesture()
          .onChanged { info in
            self.offset = info.translation
        }.onEnded { info in
          let point = CGPoint(
            x: self.base.width + info.translation.width + info.startLocation.x,
            y: self.base.height + info.translation.height + info.startLocation.y
          )
          if let index = self.locator(point) {
            self.moveTo(index)
          }
          self.offset = .zero
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
        .coordinateSpace(name: "CollectionView")
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
