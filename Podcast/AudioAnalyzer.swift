//
//  AudioAnalysis.swift
//  Podcast
//
//  Created by Apollo Zhu on 5/16/20.
//  Copyright © 2020 Apollonyan. All rights reserved.
//

import Foundation
import AVFoundation
import Speech
import NaturalLanguage

public let defaultURL = playgroundSharedDataDirectory
.appendingPathComponent(AudioRecorder.defaultFileName + ".caf")

public class AudioAnalyzer: NSObject, ObservableObject, SFSpeechRecognizerDelegate {
  public enum NoTranscription {
    case localeNotSupported
    case noOnDevice
    case noPermission
    case temporary

    public var localizedDescription: String {
      switch self {
      case .localeNotSupported:
        return "Your language is not supported for transcription"
      case .noOnDevice:
        return "On device transcription not supported"
      case .noPermission:
        return "We don't have permission from you to transcribe"
      case .temporary:
        return "Transcription service not available. Try again later."
      }
    }
  }

  public enum State {
    case processing(String = "")
    case finished
    case errored(Error)
    case canNotTranscribe(NoTranscription)
  }

  @Published
  var state: State = .processing()
  private func setState(_ newState: State) {
    dump(newState)
    DispatchQueue.main.async {
      self.state = newState
    }
  }
  @Published
  var segments: [AutoTranscriptionSegment] = [] {
    willSet {
      set("SEGMENTS", newValue)
    }
    didSet {
      if oldValue != segments {
        segments = segments.filter { !$0.text.isEmpty }
      }
    }
  }

  private let fileURL: URL
  private let speechRecognizer: SFSpeechRecognizer!

  public init(analyzing file: URL = defaultURL) {
    fileURL = file
    speechRecognizer = SFSpeechRecognizer()
      ?? SFSpeechRecognizer(locale: Locale(identifier: "en-US"))
    super.init()
 segments = get("SEGMENTS", ofType: [AutoTranscriptionSegment].self)!
 state = .finished
 return
    guard let speechRecognizer = speechRecognizer else {
      setState(.canNotTranscribe(.localeNotSupported))
      return
    }
    if !speechRecognizer.supportsOnDeviceRecognition {
      setState(.canNotTranscribe(.noOnDevice))
    }
    speechRecognizer.delegate = self
    SFSpeechRecognizer.requestAuthorization { [weak self] authStatus in
      guard let self = self else { return }
      switch authStatus {
      case .authorized, .notDetermined:
        let recognitionRequest = SFSpeechURLRecognitionRequest(url: self.fileURL)
        speechRecognizer
          .recognitionTask(with: recognitionRequest,
                           resultHandler: self.handleTranscription)
      case .denied, .restricted:
        fallthrough
      @unknown default:
        self.setState(.canNotTranscribe(.noPermission))
      }
    }
  }

  private func handleTranscription(result: SFSpeechRecognitionResult?,
                                   error: Error?) {
    if let result = result {
      if result.isFinal {
        print(result.bestTranscription.formattedString)
        var transcriptions = result.bestTranscription.segments.map {
          AutoTranscriptionSegment(
            text: $0.substring,
            alternatives: $0.alternativeSubstrings
              .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
              .filter { !$0.isEmpty },
            start: $0.timestamp,
            duration: $0.duration
          )
        }
        if !transcriptions.isEmpty {
          let average = max(result.bestTranscription.averagePauseDuration, 0.1)
          let threshold = average / 3
          print(threshold)

          // Add punctuations, not the smartest way though.
          for i in transcriptions.indices.dropLast() {
            let difference = transcriptions[i + 1].start - transcriptions[i].end
            if difference >= average {
              transcriptions[i].text += "."
              transcriptions[i + 1].text = transcriptions[i + 1].text.localizedCapitalized
            } else if difference >= threshold {
              transcriptions[i].text += ","
            }
          }

          if transcriptions.last!.text.hasSuffix(".") != true {
            transcriptions[transcriptions.indices.last!].text += "."
          }

        }
        segments = transcriptions
        setState(.finished)
      } else {
        dump(result.bestTranscription.segments)
        setState(.processing(result.bestTranscription.formattedString))
      }
    }
    if let error = error {
      setState(.errored(error))
    }
    // print(result?.bestTranscription.formattedString)
    // print(error)
  }
  
  public func speechRecognizer(_ speechRecognizer: SFSpeechRecognizer,
                               availabilityDidChange available: Bool) {
    if !available {
      setState(.canNotTranscribe(.temporary))
    }
  }
}
