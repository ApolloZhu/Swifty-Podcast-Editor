# Swifty Podcast Editor

> Tell us about the features and technologies you used in your Swift playground.

- `SwiftUI`: using SwiftUI (and platform detection compiler directives), I'm able t create a universal app from my single code base that runs on macOS (native), Mac Catalyst, and on iOS devices as well!
- SF Symbols: on platforms supporting SFSymbols, I use `Image(systemName:)`. Otherwise, I fall back to using emojis :P
- `Combine`: managing data flow between the objects and updating the UI state when transcriptions become available.
- `SFSpeechRecognizer`: this empowers me to get the automatic transcription for audio files ON DEVICE, a new feature introduced last year at WWDC19.
- `AVSpeechSynthesizer`: to generate synthesized audio for including in podcast.
- `NaturalLanguage`: finding the dominant language of the user input text so I can filter the synthesizer voices, splitting long paragraphs into sentences before insertion, and sentiment analysis for fun.
- `AVAudioEngine`, `AVAudioPlayer`: for recording and playing sound.
- Swift: `Codable` for serialization (cache recognition result and edits), using higher-order functions for simplified data transformations, proper ARC using `weak` references.

## Acknowledgements

> List the open source software you used and explain why you used it.

1. I used "Binary Search Depiction" by AlwaysAngry under CC BY-SA License from [Wikipedia](https://commons.wikimedia.org/wiki/File:Binary_Search_Depiction.svg) in the "Behind the Scene"/"Technical Details" page. It is a good depiction in addition to the videos I made using Keynote animations (those blue bars and red star blinking and disappearing). Appropriate attribution has been given on the playground page as well.
2. I used the SwiftUI [collection view (flow layout) by Chris Eidhof](https://gist.github.com/chriseidhof/3c6ea3fb2102052d1898d8ea27fbee07) file for my editor layout, which I appreciate deeply. However, as described in the same playground page mentioned above, such code does not support rearranging elements. As that is a major feature of my own editor, I  modified the "library" to support drag & drop element organization using binary search. It was also designed only for use in iOS/UIKit (as it depended on `UIOffset`), so I added support for it to compile against macOS.

## License

    A SwiftUI app that allows you to edit audio podcast swiftly.
    Copyright (C) 2020 Apollo/Zhiyu Zhu/@ApolloZhu

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <https://www.gnu.org/licenses/>.
