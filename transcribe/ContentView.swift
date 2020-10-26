//
//  ContentView.swift
//  Transcribe
//
//  Created by Apollo Zhu on 10/26/20.
//  Copyright © 2020 Apollonyan. All rights reserved.
//

import SwiftUI
import Foundation
import UniformTypeIdentifiers

struct ContentView: View {
  @EnvironmentObject var analyzer: AudioAnalyzer
  @State var isExporting: Bool = false

  var body: some View {
    Group {
      switch analyzer.state {
      case .processing(let text):
        ScrollView {
          Text(text)
        }
      case .finished:
        VStack {
        Button("Export", action: { isExporting = true })
          .fileExporter(isPresented: $isExporting,
                        document: TextDocument(text: analyzer.segments
                                                .reduce("") { $0 + $1.text + " " }),
                        contentType: .text) { result in
            switch result {
            case .success(let url):
              print("Exported to \(url)")
            case .failure(let error):
              print("Error: \(error)")
            }
          }
          List(analyzer.segments) { segment in
            HStack {
              Text("\(segment.start.formatted) - \(segment.end.formatted)")
                .font(.system(.body, design: .monospaced))
              Text(segment.text)
            }
          }
        }
      case .errored(let error):
        Text(error.localizedDescription)
      case .canNotTranscribe(let reason):
        Text(reason.localizedDescription)
      }
    }
    .padding()
    .frame(maxWidth: .infinity, maxHeight: .infinity)
  }
}

struct ContentView_Previews: PreviewProvider {
  static var previews: some View {
    ContentView()
  }
}
