import AVFoundation
#if canImport(PlaygroundSupport)
import PlaygroundSupport
#endif
import Combine

public class AudioRecorder: NSObject, AVAudioRecorderDelegate, ObservableObject {
  #if !os(macOS)
  private let session = AVAudioSession.sharedInstance()
  #endif
  private var audioRecorder: AVAudioRecorder?
  public static let defaultFileName = "recording.m4a"
  public enum State {
    case started
    case finished
    case errored(Error)
  }
  @Published
  public private(set) var state: State = .finished
  @Published
  public private(set) var transcript: String = ""

  private func setState(_ newState: State) {
    DispatchQueue.main.async {
      self.state = newState
    }
  }

  public func start(fileName: String = defaultFileName) {
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
        self?.startRecording(to: fileName)
      } else {
        self?.setState(.errored("Please grant us permission to record"))
      }
    }
  }


  private func startRecording(to file: String) {
    #if canImport(PlaygroundSupport)
    let folder = playgroundSharedDataDirectory
    #else
    let folder = FileManager.default
      .urls(for: .documentDirectory, in: .userDomainMask)[0]
    #endif
    let fileURL = folder.appendingPathComponent(file)

    let config = [
      AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
      AVSampleRateKey: 44100,
      AVNumberOfChannelsKey: 2,
      AVEncoderAudioQualityKey: AVAudioQuality.max.rawValue
    ]

    do {
      audioRecorder = try AVAudioRecorder(url: fileURL, settings: config)
      audioRecorder?.delegate = self
      audioRecorder?.record()
      setState(.started)

    } catch {
      setState(.errored(error))
    }
  }

  func stop(_ state: State = .finished) {
    audioRecorder?.stop()
    audioRecorder = nil
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

  public func audioRecorderEncodeErrorDidOccur(_ recorder: AVAudioRecorder, error: Error?) {
    if let error = error {
      stop(.errored(error))
    } else {
      stop(.errored("Recording failed due to encoding error"))
    }
  }

  public func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
    if flag {
      stop()
    } else {
      stop(.errored("Recording failed."))
    }
  }
}
