//
//  TranscribeApp.swift
//  Transcribe
//
//  Created by Apollo Zhu on 10/26/20.
//  Copyright © 2020 Apollonyan. All rights reserved.
//

import SwiftUI

let note = ""

@main
struct TranscribeApp: App {
  var body: some Scene {
    DocumentGroup(newDocument: AudioDocument()) { file in
      if let url = file.fileURL {
        ContentView()
          .environmentObject(
            AudioAnalyzer(
              analyzing: url,
              loadIfAvailable: false,
              contextualStrings: Array(Set(note
                .components(separatedBy: .whitespacesAndNewlines)
                .flatMap({ $0.components(separatedBy: .punctuationCharacters) })
              ))
            ))
      } else {
        Text("Select File")
          .frame(maxWidth: .infinity, maxHeight: .infinity)
      }
    }
  }
}
