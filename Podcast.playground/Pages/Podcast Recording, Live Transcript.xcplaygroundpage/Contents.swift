/*:
 # Podcasts

 “欢迎收听 Untectled，华盛顿大学华大华声为您带来的科技类播客节目，请跟随我们一起走进科技趣闻背后的故事...”

 I'm a show host at HUA Voice Radio under University of Washington, producing weekly podcast covering tech news, explaining the details behind them, such as the specification of Apple x Google contact tracing platform.

 One thing we do is typing out the transcript of our show episodes to convenience those audiences who can't hear because of *hearing loss, time constraint, the environment, and many other reasons*. But the problem is, we do this **by hand**.

 Right, that doesn't sound like very efficient. And especially for interviews that are longer than an hour, it's almost an impossible task. How I wish computers can do this for us...

 Wait, it can!
 */
import SwiftUI
//: - Note:
//: (Optionally) set the width and height of the app.
let previewWidth: CGFloat = 400
let previewHeight: CGFloat = 1000
/*:
 - Experiment:
 Now record a short podcast (or a few sentences of anything), and see the transcript been generated live!
 */
showPodcastRecorder(
  width: previewWidth,
  height: previewHeight
)
//: Once you're done, move on to [edit the podcast](@next)
