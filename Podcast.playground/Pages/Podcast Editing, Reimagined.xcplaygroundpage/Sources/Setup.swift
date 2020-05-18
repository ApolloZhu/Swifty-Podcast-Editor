import PlaygroundSupport
import SwiftUI

public func showPodcastEditor(
  reTranscribe: Bool,
  width: CGFloat,
  height: CGFloat
) {
  if defaultAudioURL.fileExists {
    let view = PodcastTranscriptionView(reTranscribe: reTranscribe)
    let controller = NSHostingController(rootView: view)
    controller.view.frame = CGRect(
      x: 0, y: 0, width: width, height: height
    )
    PlaygroundPage.current.liveView = controller
  } else {
    PlaygroundPage.current.liveView = NSHostingController(rootView:
      Text("Please record audio first")
        .foregroundColor(.red)
    )
  }
}
