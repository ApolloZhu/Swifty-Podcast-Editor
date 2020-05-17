import PlaygroundSupport
import SwiftUI

public func showPodcastEditor(
  reTranscribe: Bool,
  width: CGFloat,
  height: CGFloat
) {
  let view = PodcastTranscriptionView(reTranscribe: reTranscribe)
  let controller = NSHostingController(rootView: view)
  controller.view.frame = CGRect(
    x: 0, y: 0, width: width, height: height
  )
  PlaygroundPage.current.liveView = controller
}
