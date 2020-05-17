import PlaygroundSupport
import SwiftUI

public func showPodcastRecorder(width: CGFloat, height: CGFloat) {
  let view = PodcastRecordingView()
  let controller = NSHostingController(rootView: view)
  controller.view.frame = CGRect(
    x: 0, y: 0, width: width, height: height
  )
  PlaygroundPage.current.liveView = controller
}
