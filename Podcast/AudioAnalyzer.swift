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
    case finished(String)
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
  

  private let fileURL: URL
  private let speechRecognizer: SFSpeechRecognizer!

  public init(analyzing file: URL? = nil) {
    fileURL = file
      ?? playgroundSharedDataDirectory
        .appendingPathComponent(AudioRecorder.defaultFileName + ".caf")
    speechRecognizer = SFSpeechRecognizer()
      ?? SFSpeechRecognizer(locale: Locale(identifier: "en-US"))
    super.init()
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
    let finished = result?.isFinal == true
    let transcription = result?.bestTranscription.formattedString ?? ""
    if finished {
      setState(.finished(transcription))
    } else {
      setState(.processing(transcription))
    }
    if let error = error {
      setState(.errored(error))
    }
    //    print(result?.bestTranscription.formattedString)
    //    print(error)
  }
  
  public func speechRecognizer(_ speechRecognizer: SFSpeechRecognizer,
                               availabilityDidChange available: Bool) {
    if !available {
      setState(.canNotTranscribe(.temporary))
    }
  }
}
