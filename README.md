English | [日本語](./README.ja.md)

# swift-voice-input

A Swift package for voice input on iOS / macOS. Protocol-oriented design allows you to swap in multiple speech recognition backends including Apple Speech.

[![Swift 6.2](https://img.shields.io/badge/Swift-6.2-orange.svg)](https://swift.org)
[![Platforms](https://img.shields.io/badge/Platforms-iOS%2017%20|%20macOS%2014-blue.svg)](https://developer.apple.com)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)

## Features

- **Protocol-oriented** — Abstracts the recognition engine behind the `SpeechRecognizer` protocol. Plug in Apple Speech, Whisper, local LLMs, and more
- **Real-time streaming** — Partial results delivered incrementally via `AsyncStream`. Use `partialText` for live display
- **Floating preview** — An Aqua Voice-style overlay shows recognized text in real time above the input field
- **DesignSystem compliant** — UI components fully follow the token system of [swift-design-system](https://github.com/no-problem-dev/swift-design-system)
- **Two-target layout** — `VoiceInput` (Core) and `VoiceInputUI` (SwiftUI) are separated. Depend on Core alone when you don't need UI
- **Swift Concurrency** — Actor-based audio engine and `@Observable` state management for safe concurrent access

## Installation

Add the dependency to `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/no-problem-dev/swift-voice-input.git", .upToNextMajor(from: "2.0.0")),
]
```

Add to your target:

```swift
// Core only (no UI needed)
.product(name: "VoiceInput", package: "swift-voice-input"),

// Core + SwiftUI components
.product(name: "VoiceInputUI", package: "swift-voice-input"),
```

## Quick Start

### Basic Usage

```swift
import VoiceInput
import VoiceInputUI

struct MyView: View {
    @State private var session = VoiceInputSession()
    @State private var text = ""

    var body: some View {
        VStack {
            TextField("Type here...", text: $text)

            VoiceInputButton(session: session)
        }
        .voiceInputOverlay(session: session) { transcript in
            text = transcript
        }
    }
}
```

### Inline Transcript Preview

Embed a transcript preview directly in the layout flow using `InlineTranscriptView`:

```swift
import VoiceInput
import VoiceInputUI

struct MyView: View {
    @State private var session = VoiceInputSession()
    @State private var text = ""

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                TextField("Type here...", text: $text)
                VoiceInputButton(session: session)
            }
            InlineTranscriptView(session: session) { transcript in
                text = transcript
            }
        }
    }
}
```

### Custom Recognition Engine

Implement an Actor conforming to `SpeechRecognizer`:

```swift
actor WhisperRecognizer: SpeechRecognizer {
    let displayName = "Whisper"
    var isAvailable: Bool { true }

    func requestPermissions() async -> Result<Void, SpeechRecognitionError> {
        // Request microphone permission
        .success(())
    }

    func start(locale: Locale) throws -> AsyncStream<SpeechRecognitionResult> {
        // Start recognition with Whisper model
        AsyncStream { _ in }
    }

    func stop() {
        // Stop recognition
    }
}

// Inject at session creation
@State private var session = VoiceInputSession(
    recognizer: WhisperRecognizer()
)
```

### Session API

```swift
let session = VoiceInputSession()

session.toggle()           // Toggle start/stop
session.startListening()   // Start
session.stopListening()    // Stop

session.state              // .idle, .requesting, .listening, .processing, .error
session.partialText        // Real-time partial text
session.transcript         // Finalized text

let text = session.confirm() // Confirm text + reset
session.reset()              // Reset
```

## Architecture

```
VoiceInput (Core)
├── Protocol/
│   ├── SpeechRecognizer         # Recognition engine abstraction protocol (Actor)
│   ├── SpeechRecognitionResult  # .partial / .final result type
│   └── SpeechRecognitionError   # Error type
├── Engine/
│   ├── AppleSpeechRecognizer    # Default Apple Speech implementation
│   └── PermissionRequester      # Microphone & speech recognition permissions
└── Session/
    └── VoiceInputSession        # @Observable state management

VoiceInputUI (SwiftUI + DesignSystem)
├── Button/
│   └── VoiceInputButton         # Microphone toggle button
├── Inline/
│   └── InlineTranscriptView     # Inline transcript preview
└── Overlay/
    └── TranscriptOverlayModifier # .voiceInputOverlay() modifier
```

## Requirements

| Requirement | Version |
|-------------|---------|
| iOS | 17.0+ |
| macOS | 14.0+ |
| Swift | 6.2+ |
| Xcode | 26.0+ |

## License

MIT License — see [LICENSE](LICENSE) for details.

## Links

- [Issues](https://github.com/no-problem-dev/swift-voice-input/issues)
