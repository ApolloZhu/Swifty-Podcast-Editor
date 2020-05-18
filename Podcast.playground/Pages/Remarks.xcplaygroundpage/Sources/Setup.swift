import SwiftUI
import PlaygroundSupport

public func visualizeSentiment(scored score: Double) {
  PlaygroundPage.current.liveView = NSHostingController(rootView:
    HStack {
      Text(emoji(forSentimentScore: score))
        .font(.largeTitle)
      Text(score <= 0 ? "I'll try my best next time!" : "Thank you very much!")
    }
  )
}

func emoji(forSentimentScore score: Double) -> String {
  switch score {
  case ...(-0.6): return "😭"
  case ...(-0.2): return "🥴"
  case ...0.2: return "🙃"
  case ...0.6: return "🙂"
  default: return "😃"
  }
}
