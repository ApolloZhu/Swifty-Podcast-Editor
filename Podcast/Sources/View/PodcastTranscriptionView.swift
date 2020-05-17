//
//  PodcastTranscriptionView.swift
//  Podcast
//
//  Created by Apollo Zhu on 5/16/20.
//  Copyright © 2020 Apollonyan. All rights reserved.
//

import SwiftUI

fileprivate func anyTextView(_ text: String) -> AnyView {
  return AnyView(Text(text).padding())
}

import AVFoundation

public struct PodcastTranscriptionView: View {
  public init(reTranscribe: Bool = false) {
    analyzer = AudioAnalyzer(loadIfAvailable: !reTranscribe)
  }

  @ObservedObject
  private var analyzer: AudioAnalyzer
  @ObservedObject
  private var player = AudioSegmentPlayer()
  @State private var newText: String = ""
  @State private var showVoiceChooser: Bool = false
  @State private var voices = AVSpeechSynthesisVoice.speechVoices()


  var inputTextField: some View {
    TextField(
      "Enter new text to be spoken", text: self.$newText,
      onCommit: {
        if let language = self.newText.dominantLanguage {
          self.voices = AVSpeechSynthesisVoice.speechVoices()
            .filter { $0.language.hasPrefix(language)
              || $0.language.hasPrefix(language.split(separator: "-")[0]) }
            .sorted { $0.quality.rawValue >= $1.quality.rawValue
              || $0.name < $1.name }
          if self.voices.count < 2 {
            self.appendAudioSegment()
          } else {
            self.showVoiceChooser = true
          }
        } else {
          self.appendAudioSegment()
        }
    })
      .padding()
      .background(Color.purple.opacity(0.5))
  }

  var inputNew: some View {
    #if os(macOS)
    return VStack {
      Spacer()
      if showVoiceChooser {
        Group {
          Text("Select a \(Locale.displayName(for: self.newText.dominantLanguage ?? "")) Voice")
            .font(.title)
          .frame(maxWidth: .infinity)
          Text("Choose a voice to speak this text")
            .frame(maxWidth: .infinity)
          ScrollView(.horizontal, showsIndicators: false) {
            HStack {
              Button("Use Default") {
                self.showVoiceChooser = false
                self.appendAudioSegment()
              }
              ForEach(voices, id: \.identifier) { voice in
                Button(voice.name) {
                  self.showVoiceChooser = false
                  self.appendAudioSegment(voice: voice)
                }
              }
            }
          }
        }
        .padding()
        .background(Color.white)
      } else {
        inputTextField
      }
    }
    #else
    return VStack {
      Spacer()
      inputTextField
        .actionSheet(isPresented: self.$showVoiceChooser) {
          return ActionSheet(
            title: Text("Select a \(Locale.displayName(for: self.newText.dominantLanguage ?? "")) Voice"),
            message: Text("Choose a voice to speak this text"),
            buttons: self.voices.map { voice in
              ActionSheet.Button.default(Text(voice.name)) {
                self.appendAudioSegment(voice: voice)
              }
              } + [
                ActionSheet.Button.default(Text("Use Default")) {
                  self.appendAudioSegment()
                }
            ]
          )
      }
    }
    #endif
  }

  public var body: some View {
    switch analyzer.state {
    case .finished:
      return AnyView(
        GeometryReader { geo in
          ZStack {
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
                  self.analyzer.cacheSegments()
              })
                .frame(maxWidth: geo.size.width)
                .fixedSize()
            }
            .padding()

            self.inputNew
          }
        }
        .environmentObject(player)
      )
    case .errored(let error):
      return AnyView(VStack {
        Text("Failed to transcribe.")
          .font(.title)
        Text(error.localizedDescription)
          .foregroundColor(Color.red)
      }.padding())
    case .processing(let text):
      return anyTextView("\(text) ... (still processing)")
    case .canNotTranscribe(let reason):
      return anyTextView(reason.localizedDescription)
    }
  }

  func appendAudioSegment(voice: AVSpeechSynthesisVoice? = nil) {
    if self.newText.isEmpty { return }
    self.analyzer.segments.append(AudioSegment(
      text: self.newText,
      voiceIdentifier: voice?.identifier
    ))
    self.analyzer.cacheSegments()
    self.newText = ""
  }

  func setVoices(forLanguage language: String) {
    voices = AVSpeechSynthesisVoice.speechVoices()
      .sorted {
        $0.language == language
          || $0.language < $1.language
          || $0.quality.rawValue < $1.quality.rawValue
          || $0.name < $1.name
    }
  }
}

extension Locale {
  static func displayName(for localeIdentifier: String) -> String {
    return (Locale.current as NSLocale)
      .displayName(forKey: .identifier, value: localeIdentifier)
      ?? localeIdentifier
  }
}

struct PodcastTranscriptionView_Previews: PreviewProvider {
  static var previews: some View {
    PodcastTranscriptionView()
  }
}
