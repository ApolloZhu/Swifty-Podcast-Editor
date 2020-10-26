//
//  TranscribeDocument.swift
//  Transcribe
//
//  Created by Apollo Zhu on 10/26/20.
//  Copyright © 2020 Apollonyan. All rights reserved.
//

import SwiftUI
import UniformTypeIdentifiers

struct AudioDocument { }

extension AudioDocument: FileDocument {
  static var readableContentTypes: [UTType] { [.audio] }
  static var writableContentTypes: [UTType] { [] }

  init(configuration: ReadConfiguration) throws { }

  func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
    throw "Not supported"
  }
}

struct TextDocument {
  let text: String
}

extension TextDocument: FileDocument {
  static var readableContentTypes: [UTType] { [.text] }
  init(configuration: ReadConfiguration) throws {
    guard let text = configuration.file.regularFileContents
            .flatMap({ String(data: $0, encoding: .utf8) })
            else { throw CocoaError(.fileReadCorruptFile) }
    self.init(text: text)
  }
  func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
    guard let data = text.data(using: .utf8) else {
      throw CocoaError(.fileWriteInapplicableStringEncoding)
    }
    return FileWrapper(regularFileWithContents: data)
  }
}
