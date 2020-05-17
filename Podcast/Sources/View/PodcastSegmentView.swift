//
//  PodcastSegmentView.swift
//  Podcast
//
//  Created by Apollo Zhu on 5/17/20.
//  Copyright © 2020 Apollonyan. All rights reserved.
//

import SwiftUI

extension View {
  fileprivate func styledTextSegment(backgroundColor: Color) -> some View {
    self.padding(.leading, 20)
      .padding(.trailing)
      .padding(.vertical, 5)
      .background(backgroundColor.opacity(0.3))
      .cornerRadius(5)
  }
}

struct SegmentView: View {
  @EnvironmentObject var player: AudioSegmentPlayer
  @Binding var segment: AudioSegment
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
        self.player.play(segment: self.segment)
      }) {
        #if os(macOS)
        Text(segment.isTranscribed ? "▶️" : "🗣")
        #else
        Image(systemName: "play.circle.fill")
          .foregroundColor(segment.isTranscribed ? .accentColor : .green)
        #endif
      }
      .buttonStyle(PlainButtonStyle())

      if showNoSuggestions {
        TextField("", text: $segment.text)
          .textFieldStyle(PlainTextFieldStyle())
          .fixedSize()
      } else {
        HStack {
          TextField("", text: $segment.text)
            .textFieldStyle(PlainTextFieldStyle())
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
