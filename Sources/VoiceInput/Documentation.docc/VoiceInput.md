# ``VoiceInput``

Voice input for iOS and macOS, with the recognition engine behind a protocol so it can be replaced.

## Overview

`VoiceInput` turns a speech recogniser into two things a view can bind to: a
string that updates as the user speaks, and a state that says what the microphone
is doing. The engine behind them is a protocol, so Apple's recogniser is a
default rather than a commitment.

The core is deliberately small. ``VoiceInputSession`` owns the state machine and
the text; ``SpeechRecognizer`` is the seam an alternative engine plugs into.
SwiftUI components live in the separate `VoiceInputUI` library, so an app that
draws its own controls — or has no UI at all — does not pull SwiftUI in.

Start with <doc:GettingStarted>, which covers the `Info.plist` keys the first
line of code depends on.

### What the session gives a view

```swift
import VoiceInput

@State private var session = VoiceInputSession()

session.toggle()          // start, or stop if already listening

Text(session.partialText) // rewritten on every update while the user speaks

let text = session.confirm()
```

Two properties are easy to confuse. `partialText` is provisional — the recogniser
rewrites earlier words as it hears more, so display it but do not act on it.
`transcript` is only set when the recogniser settles, which often never happens
because the user stopped first. ``VoiceInputSession/confirm()`` picks whichever
is populated, which is why it is the method to reach for rather than reading
either directly.

### Substituting an engine

Conform an actor to ``SpeechRecognizer`` and pass it in. The requirement is
`Actor` rather than a plain protocol because an engine owns audio hardware, and
that isolation is what stops a double-tapped button from opening two sessions.

```swift
actor WhisperRecognizer: SpeechRecognizer {
    let displayName = "Whisper"
    var isAvailable: Bool { true }

    func requestPermissions() async -> Result<Void, SpeechRecognitionError> {
        .success(())
    }

    func start(locale: Locale) throws -> AsyncStream<SpeechRecognitionResult> {
        AsyncStream { _ in }
    }

    func stop() {}
}

let session = VoiceInputSession(recognizer: WhisperRecognizer())
```

The same seam is what makes the state machine testable: a mock recogniser replays
a scripted list of results in milliseconds, with no microphone and no permission
prompts.

## Topics

### Essentials

- <doc:GettingStarted>
- ``VoiceInputSession``

### Recognition results

- ``SpeechRecognitionResult``
- ``SpeechRecognitionError``

### Substituting an engine

- ``SpeechRecognizer``
- ``AppleSpeechRecognizer``
