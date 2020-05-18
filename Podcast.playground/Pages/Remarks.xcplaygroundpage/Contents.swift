/*:
 # Summary

 You've seen that we can automatically convert spoken audio to written text:

 ![real time transcription](Transcription.mov)

 as well as the innovative editor that makes it a lot easier to work with audio:

 ![editing audio by editing text](Editor.mov)

 Because the project is written entirely in SwiftUI, it's fully cross platform! Here's a screenshot of it running on my phone:

 ![Swifty Podcast Editor on iPhone X](iOS.png)

 You've also seen:
*/
import NaturalLanguage
/*:
 helping us tokenizing sentences when you insert new synthesized audio segments, detecting their language so we can pick a relevant synthesizer.

 > But interestingly though, it understands our emotions as well:
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
//: With that, we could potentially pick synthetic voices based on the sentiment of the text we are about to insert. But for today,
//: - Example:
//: let me know how you think of my playground ;)
let iThinkThisPlaygroundIs = """

Loved it, great work!

"""

visualizeSentiment(
  scored: analyze(iThinkThisPlaygroundIs)
)
/*:
 ## `deinit`

 Anyways, thank you for your time, hope you have learned and discovered something new, and have a nice day!
 */
