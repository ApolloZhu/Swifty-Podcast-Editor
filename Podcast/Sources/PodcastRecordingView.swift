//
//  PodcastRecordingView.swift
//  Podcast
//
//  Created by Apollo Zhu on 5/16/20.
//  Copyright © 2020 Apollonyan. All rights reserved.
//

import SwiftUI

public struct PodcastRecordingView: View {
  public init() { }

  @ObservedObject public var recorder = AudioRecorder()
  public var body: some View {
    VStack {
      Spacer()
      Button(buttonText) {
        switch self.recorder.state {
        case .started:
          self.recorder.stop()
        case .errored, .finished, .canNotTranscribe:
          self.recorder.start()
        }
      }
      .disabled(buttonDisabled)
      .foregroundColor(.white)
      .padding()
      .background(buttonColor)
      .cornerRadius(10)

      ScrollView {
        Text(recorder.transcript)
          .font(.body)
          .frame(maxWidth: .infinity, maxHeight: .infinity)
      }
    }
    .padding()
  }

  var buttonDisabled: Bool {
    switch recorder.state {
    case .canNotTranscribe(.localeNotSupported), .canNotTranscribe(.noOnDevice):
      return true
    default:
      return false
    }
  }

  var buttonText: String {
    switch recorder.state {
    case .finished:
      return "Start Recording"
    case .started:
      return "Stop Recording"
    case .errored(let error):
      return """
      Something Went Wrong. Try Again?
      \(error.localizedDescription)
      """
    case .canNotTranscribe(let reason):
      return reason.localizedDescription
    }
  }

  var buttonColor: Color {
    switch recorder.state {
    case .finished:
      return Color.blue
    case .started:
      return Color.green
    case .errored, .canNotTranscribe:
      return Color.red
    }
  }
}

struct PodcastRecordingView_Previews: PreviewProvider {
  static var previews: some View {
    PodcastRecordingView()
  }
}
