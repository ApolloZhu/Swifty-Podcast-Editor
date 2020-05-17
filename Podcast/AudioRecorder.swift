import AVFoundation
#if canImport(PlaygroundSupport)
import PlaygroundSupport
#endif
import Combine
import Speech

public class AudioRecorder: NSObject, ObservableObject, SFSpeechRecognizerDelegate {
  // MARK: - State
  public enum State {
    case started
    case finished
    case errored(Error)
    case canNotTranscribe(AudioAnalyzer.NoTranscription)
  }

  @Published
  public private(set) var state: State = .finished
  
  private func setState(_ newState: State) {
    dump(newState)
    switch state {
    case .canNotTranscribe(let reason):
      switch reason {
      case .temporary, .noPermission:
        break
      default:
        return
      }
    default:
      break
    }
    DispatchQueue.main.async {
      self.state = newState
    }
  }

  // MARK: - Transcription

  @Published
  public private(set) var transcript: String = ""

  private let speechRecognizer: SFSpeechRecognizer!
  private let audioEngine = AVAudioEngine()

  private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest!
  private var recognitionTask: SFSpeechRecognitionTask?

  public override init() {
    speechRecognizer = SFSpeechRecognizer()
      ?? SFSpeechRecognizer(locale: Locale(identifier: "en-US"))
    super.init()
    speechRecognizer?.delegate = self
  }

  public func speechRecognizer(_ speechRecognizer: SFSpeechRecognizer,
                               availabilityDidChange available: Bool) {
    if available {
      if case .canNotTranscribe(.temporary) = state {
        setState(.finished)
      }
    } else {
      stop(.canNotTranscribe(.temporary))
    }
  }

  // MARK: - Recording

  #if !os(macOS)
  private let session = AVAudioSession.sharedInstance()
  #endif

  public static let defaultFileName = "recording"

  public func start(fileName: String = defaultFileName) {
    if speechRecognizer == nil {
      setState(.canNotTranscribe(.localeNotSupported))
    }
    if !speechRecognizer.supportsOnDeviceRecognition {
      setState(.canNotTranscribe(.noOnDevice))
    }
    do {
      #if !os(macOS)
      try session.setCategory(.record, mode: .default)
      try session.setActive(true, options: .notifyOthersOnDeactivation)
      #endif
    } catch {
      setState(.errored(error))
    }
    session.requestRecordPermission { [weak self] canRecord in
      if canRecord {
        SFSpeechRecognizer.requestAuthorization { authStatus in
          switch authStatus {
          case .authorized, .notDetermined:
            self?.startRecording(to: fileName)
          case .denied, .restricted:
            fallthrough
          @unknown default:
            self?.setState(.canNotTranscribe(.noPermission))
          }
        }
      } else {
        self?.setState(.errored("Please grant us permission to record"))
      }
    }
  }

  private func startRecording(to file: String) {
    let file = file.hasSuffix(".caf") ? file : file + ".caf"
    let fileURL = playgroundSharedDataDirectory.appendingPathComponent(file)
    print(fileURL.absoluteString)

    // Create and configure the speech recognition request.
    recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
    recognitionRequest.shouldReportPartialResults = true
    recognitionRequest.requiresOnDeviceRecognition = true
    recognitionTask = speechRecognizer
      .recognitionTask(with: recognitionRequest,
                       resultHandler: handleTranscription)

    do {
      let inputNode = audioEngine.inputNode
      let format = inputNode.inputFormat(forBus: 0)
      let file = try AVAudioFile(
        forWriting: fileURL,
        settings: format.settings
      )
      inputNode.removeTap(onBus: 0)
      inputNode.installTap(onBus: 0, bufferSize: 1024, format: format)
      { [weak self] (buffer: AVAudioPCMBuffer, when: AVAudioTime) in
        guard let self = self else { return }
        self.recognitionRequest?.append(buffer)
        do {
          try file.write(from: buffer)
        } catch {
          self.stop(.errored(error))
        }
      }
      audioEngine.prepare()
      try audioEngine.start()
      setState(.started)
    } catch {
      setState(.errored(error))
    }
  }

  private var transcriptions = [AutoTranscriptionSegment]()

  func handleTranscription(result: SFSpeechRecognitionResult?, error: Error?) {
    if let result = result {
      let best = result.bestTranscription
      var transcription = best.formattedString
      if result.isFinal || (best.segments.first?.timestamp != 0) {
        if !transcript.hasSuffix(".") {
          transcription += "."
        }
      }
      DispatchQueue.main.async {
        self.transcript = transcription
      }
    }
    if let error = error, audioEngine.isRunning {
      stop(.errored(error))
    }
  }

  public func stop(_ state: State = .finished) {
    guard audioEngine.isRunning else {
      return setState(state)
    }
    audioEngine.stop()
    recognitionRequest?.endAudio()
    recognitionRequest = nil
    recognitionTask = nil

    #if !os(macOS)
    do {
      try session.setActive(false, options: .notifyOthersOnDeactivation)
    } catch {
      setState(.errored(error))
      return
    }
    #endif
    setState(state)
  }
}
