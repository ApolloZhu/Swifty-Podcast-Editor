/*:
 # Final Words

 




 Before you go, I want to introduce you
 */
import NaturalLanguage
/*:
 It helped us tokenizing sentences when you insert new synthesized audio segments. But it can also analyze sentiments:
 */
func analyze(_ text: String) -> Double {
  let tagger = NLTagger(tagSchemes: [.sentimentScore])
  tagger.string = text
  let scores = tagger
//: find the sentiment tag for each paragraph
    .tags(in: text.startIndex..<text.endIndex,
          unit: .paragraph, scheme: .sentimentScore)
//: then find their numeric average
    .compactMap { $0.0?.rawValue }
    .compactMap(Double.init)
  return scores.reduce(0, +) / Double(scores.count)
}
//: So let me know how you think of my playground ;)
let iThinkThisPlaygroundIs = """

Loved it, great work!

"""

visualizeSentiment(
  scored: analyze(iThinkThisPlaygroundIs)
)
/*:
 By the way, because the project is written entirely in SwiftUI, it's fully cross platform! Here's a screenshot of it running on my phone:

 ![Swifty Podcast Editor on iPhone X](iOS.png)

 ## `deinit`

 Anyways, thank you for your time, hope you have learned and discovered something new, and have a nice day!
 */
