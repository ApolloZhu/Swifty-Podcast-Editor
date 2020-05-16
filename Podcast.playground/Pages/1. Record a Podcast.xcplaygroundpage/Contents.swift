import AVFoundation
#if canImport(PlaygroundSupport)
import PlaygroundSupport
#endif
import Combine

extension String: Error { }

extension Result where Success == Void {
    public static var success: Self {
        return .success(())
    }
}


public class AudioRecorder: NSObject, AVAudioRecorderDelegate, ObservableObject {
    private let session = AVAudioSession.sharedInstance()
    private var audioRecorder: AVAudioRecorder!
    public static let defaultFileName = "recording.m4a"
    public enum State {
        case started
        case finished
        case errored(Error)
    }
    @Published
    public private(set) var state: State = .finished

    public typealias Handler = (Result<Void, Error>) -> Void

    public func start(fileName: String = defaultFileName) {
        do {
            try session.setCategory(.playAndRecord, mode: .default)
            try session.setActive(true, options: .notifyOthersOnDeactivation)
        } catch {
            self.state = .errored(error)
        }
        session.requestRecordPermission { [weak self] canRecord in
            if canRecord {
                self?.startRecording(to: fileName)
            } else {
                self?.state = .errored("Please grant us permission to record")
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
            audioRecorder.delegate = self
            audioRecorder.record()
            state = .started
        } catch {
            state = .errored(error)
        }
    }

    func stop(_ state: State = .finished) {
        audioRecorder.stop()
        audioRecorder = nil
        self.state = state
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

import SwiftUI

public struct PodcastRecordingView: View {
    @State var recorder = AudioRecorder()
    public var body: some View {
        Button(action: {
            switch self.recorder.state {
            case .started: self.recorder.stop()
            case .errored, .finished: self.recorder.start()
            }
        }) {
            Text({
                switch recorder.state {
                case .finished: return "Start Recording"
                case .started: return "Stop Recording"
                case .errored(let error): return "Try Again? \(error.localizedDescription)"
                }
            }())
        }
    }
}

PlaygroundPage.current.liveView = NSHostingController(rootView: PodcastRecordingView())


