//
//  ContentView.swift
//  Podcast
//
//  Created by Apollo Zhu on 5/17/20.
//  Copyright © 2020 Apollonyan. All rights reserved.
//

import SwiftUI

struct ContentView: View {
  @State var recording: Bool = false
  var body: some View {
    Group {
      if recording {
        PodcastRecordingView()
      } else {
        PodcastTranscriptionView(reTranscribe: true)
      }
    }
  }
}

struct ContentView_Previews: PreviewProvider {
  static var previews: some View {
    ContentView()
  }
}
