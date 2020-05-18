//: # Technical Details
import SwiftUI
/*:
 For those curious minds, we used SwiftUI for the user interface; AVFoundation for the audio recording, processing, and playback; SFSpeechRecognizer for transcription; and AVSpeechSynthesizer for generation. But I also used an algorithm called

 ## Binary Search

 I used
 [collection view flow layout by Chris Eidhof](https://gist.github.com/chriseidhof/3c6ea3fb2102052d1898d8ea27fbee07), which does a great job in laying out the segments. However, it doesn't know how to rearrange the items when dragged around. From a drag gesture recognizer, we could get the current cursor position. But how do we translate that to the new index of the dragged segment?

 When laying out the segments, we now save all their frame rectangles (which is their location and size) in order.

 ### Linear Search

 The "simplest way" to locate it would be checking against them one by one until found the appropriate location. However, this has an `O(n)` runtime, which means if you have X number of segments in your podcast, it needs to check X number of times.

 ![searching for insertion position, one by one](LinearSearch.m4v poster="LinearSearchCover.png" width="960" height="540")

 While this is acceptable for short podcasts, it will be a disaster for long interviews since it will have thousands of segments.

 ### 2D Binary Search

 Since our frames are sorted, there's faster way called binary search, which is conventionally applied to a sequence of sorted numbers. You compare the number with the middle point, if it's the same, you found the point. If your number is smaller, do this again on the left side; otherwise (if larger), try this again on the other side. Here's an example from [Wikipedia](https://commons.wikimedia.org/wiki/File:Binary_Search_Depiction.svg):

 ![searching by dividing in half](BinarySearchWiki.png)

 But since our frames are 2D -- having Xs and Ys, we can't just copy over the binary search code for one dimensional sequence of numbers. What we have to do instead is combing 2 binary searches: first binary search along the vertical axis, then among the horizontal axis:
 */
func insertionIndex(for point: CGPoint, into frames: [CGRect]) -> Int? {
//: Special case: there's not a single element at all -- which doesn't make sense. So we return `nil`
  if frames.isEmpty { return nil }
  let (x, y) = (point.x, point.y)
//: Special case: if it's before all the elements, I think you dragged to a wrong position, so we return `nil`.
//: However, you could argue that this means to the beginning. If you think so, you could return 0 instead.
  if y < frames.first!.minY {
    return nil
  }
//: Special case: if it's after all the elements, I think you want to drag to the end.
  if y > frames.last!.maxY {
    return frames.count
  }
  var i = 0, j = frames.count

//: While we have not found the insertion point
  while i < j {
//: Now we find the middle of the frame rectangles, which supposedly would also be (somewhat) in the middle of screen
    let mid = (i + j - 1) / 2
//: If it's higher on the screen, we only look for the portions above
    if y < frames[mid].minY {
      j = mid - 1
//: If it's lower on the screen, we only look for the portions below
    } else if y > frames[mid].maxY {
      i = mid + 1
//: Now if we found the appropriate row to insert into, let's check where in the row exactly.
//:
//: If the point we dragged to is on the left of current frame we are checking
    } else if x <= frames[mid].minX {
      if mid == 0 // if this is for the first frame
        || x >= frames[mid - 1].maxX // or if the point is between two frames
        || 0 == frames[mid].minX { // or the frame is the first in the row
        return mid // that's where it should go!
      } else {
        j = mid - 1 // look for the left hand side
      }
//: If the point we dragged to is on the right of current frame we are checking
    } else if x >= frames[mid].maxX {
      if mid + 1 == frames.count // if this is for the last frame
        || x <= frames[mid + 1].minX // or if the point is between two frames
        || 0 == frames[mid + 1].minX { // or the frame is the last in the row
        return mid + 1 // that's where it should go!
      } else {
        i = mid + 1 // look for the right hand side
      }
//:  Else, we found inside another segment, which you could return `nil` instead.
    } else {
      return mid
    }
  }
//: Now we searched for where exactly it should go, return it.
  return j
}
/*:
And that's how you would binary search in a 2D space! Since time is almost up, let's [summarize what we have seen](@next).

---

 By the way, because the project is written entirely in SwiftUI, it's fully cross platform! Here's a screenshot of it running on my phone:

![Swifty Podcast Editor on iPhone X](iOS.png)

*/
