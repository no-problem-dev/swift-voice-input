English | [日本語](./README.ja.md)

# swift-voice-input

Let people speak instead of type in an iOS or macOS app, with permission refusals, streaming partial text and start/stop state already handled.

[![Swift 6.2](https://img.shields.io/badge/Swift-6.2-orange.svg)](https://swift.org)
[![Platforms](https://img.shields.io/badge/Platforms-iOS%2017%20|%20macOS%2014-blue.svg)](https://developer.apple.com)

## Overview

- **The engine is a seam, not a commitment** — Apple's recogniser is the default, not the design. Anything conforming to `SpeechRecognizer` drops in, which is also what makes the state machine testable without a microphone.
- **Text as it is spoken** — partial results stream in and are published as a plain observable string, so a view binds to a property instead of managing a stream.
- **Refused permissions handled** — the one path most voice features get wrong. A denial is not retryable in-app, and the supplied button says so and routes the user to Settings.
- **UI is optional** — `VoiceInput` carries the recogniser and session; `VoiceInputUI` carries the SwiftUI controls. Depend on the first alone and SwiftUI never enters the build.

## Usage

The host app must declare both usage descriptions in its `Info.plist`:

- `NSMicrophoneUsageDescription` — why the app records audio
- `NSSpeechRecognitionUsageDescription` — why that audio is transcribed

Missing either one terminates the app the moment that permission is requested, so
the symptom is a crash on first tap rather than a denied permission.

```swift
import VoiceInput
import VoiceInputUI

struct DictationField: View {
    @State private var session = VoiceInputSession()
    @State private var text = ""

    var body: some View {
        HStack {
            TextField("Type here…", text: $text)
            VoiceInputButton(session: session)
        }
        .voiceInputOverlay(session: session) { transcript in
            text = transcript
        }
    }
}
```

## Documentation

[**API reference and guides**](https://no-problem-dev.github.io/swift-voice-input/documentation/voiceinput/) —
including [Getting Started](https://no-problem-dev.github.io/swift-voice-input/documentation/voiceinput/gettingstarted/),
substituting a recognition engine, and what separates a partial result from a final one.

## Requirements

| iOS | macOS | Swift |
|-----|-------|-------|
| 17.0+ | 14.0+ | 6.2+ |

## Installation

```swift
dependencies: [
    .package(url: "https://github.com/no-problem-dev/swift-voice-input.git", from: "3.0.0"),
]
```

Then take one or both products — `VoiceInput` for the session and recogniser,
`VoiceInputUI` for the SwiftUI controls:

```swift
.product(name: "VoiceInput", package: "swift-voice-input"),
.product(name: "VoiceInputUI", package: "swift-voice-input"),
```

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md).

## License

MIT — see [LICENSE](LICENSE).
