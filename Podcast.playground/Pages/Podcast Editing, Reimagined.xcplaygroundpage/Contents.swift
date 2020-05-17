/*:
 # Editing Podcast

 But actually, the harder part of podcasting is editing the audio:

 1. People (almost) always make mistakes and we'll need to cut that out.
 2. Sometimes, especially interviews, there're no clear flow of content. We have to rearrange the audio so it's easier to follow and make sense of.
 3. To quote other people or news, you'll need to change your voice and mimic another person. Professional voice actors are quite good at this, but I'm not one of them.
 4. And, most frustrating of all, this is what you'll see in your editor, where audio segments show their *wave forms*:

 ![I don't know what each person is saying in each part](./Traditional.png)

 Wouldn't it be nice if I can **see what people are saying** in each part, and moving those text around will change the audio as well? Well, let me introduce to you,

 ## Swifty Podcast Editor
 The editor will load the audio you recorded in the [previous page](@previous), and you can use it for

1. **Auto Punctuation:** in addition to transcription, the editor will try to infer them based on the natural pauses.
2. **Updating Transcript:** while transcribing works for most of the times, you can manually fix them by changing the text.
    1. *Alternatives:* if there's a 📝 or 􀉆 icon, click it to see and apply possible alternative transcriptions.
    2. *Audio Preview*: not sure which part of the audio is the transcription for? Click the ▶️ or 􀊖 button.
3. **Synthesize Audio:** At the bottom of the screen, try to type (or paste) something to include in your podcast. Press enter, then the editor will detect the language it is in and generate an audio for you to use!
4. **Rearranging:**
    1. *Delete* all the text in a segment to delete that segment of recorded/generated audio.
    2. *Drag and drop* the audio segments around to rearrange them.
 */
import SwiftUI

let previewWidth: CGFloat = 1000
let previewHeight: CGFloat = 700
//: > If set `alwaysReTranscribe` to true, you'll lose your edits, but we'll regenerate the transcript to give you a fresh start.
let alwaysReTranscribe: Bool = false
showPodcastEditor(
  reTranscribe: alwaysReTranscribe,
  width: previewWidth,
  height: previewHeight
)
//: Once your are done, click on the "*Listen to My Podcast*" button to enjoy your (first) podcast episode 🎊!
//:
//: ---
//:
//: That's cool, but [how is this made possible](@next)?
//:
