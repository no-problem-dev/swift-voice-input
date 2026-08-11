# Getting started

Add the package, declare two `Info.plist` keys, and put a live transcript on screen.

## Add the package

Add the repository to your `Package.swift` dependencies, then add the product to
the target that needs it.

```swift
.target(
    name: "MyApp",
    dependencies: [
        .product(name: "VoiceInput", package: "swift-voice-input"),
    ]
)
```

Add `VoiceInputUI` as well if you want the ready-made SwiftUI controls; skip it
if you are drawing your own.

## Declare the usage descriptions

The host app must declare both keys in its `Info.plist`:

- `NSMicrophoneUsageDescription` — why the app records audio
- `NSSpeechRecognitionUsageDescription` — why that audio is transcribed

This is not paperwork that can be deferred. iOS terminates the app at the moment
the matching permission is requested if the key is absent, so the symptom of
forgetting one is a crash the first time a user taps the microphone — not a
denied permission, and not an error you can catch.

## Ask before you listen

``VoiceInputSession/startListening()`` requests both permissions and then starts.
The system prompts once per permission per install; after that the standing
answer comes back with no UI, so there is nothing to cache.

A refusal is not a transient failure. The system will not ask again, so retrying
in-app cannot help — read ``VoiceInputSession/isPermissionDenied`` and send the
user to Settings instead.

```swift
if session.isPermissionDenied {
    // Only Settings can undo this.
    openURL(URL(string: UIApplication.openSettingsURLString)!)
}
```

## Show the text as it arrives

Hold the session in `@State` and bind to it. `toggle()` is the whole behaviour of
a microphone button — it starts, or stops if already running.

```swift
struct DictationField: View {
    @State private var session = VoiceInputSession()
    @State private var text = ""

    var body: some View {
        VStack {
            TextField("Type here…", text: $text)
            Text(session.partialText)
            Button("Speak") { session.toggle() }
        }
    }
}
```

``VoiceInputSession/partialText`` is replaced wholesale on every update, not
appended to: the recogniser revises words it has already reported as it hears
more of the utterance. Render it, but do not treat it as committed input.

## Take the result

``VoiceInputSession/confirm()`` returns the recognised text and clears the
session in one step.

```swift
let text = session.confirm()
```

Prefer it over reading the properties yourself. ``VoiceInputSession/transcript``
is only set when the recogniser settles on a final result, and a session that
ends because the user stopped or fell silent — the common case — never gets
there. `confirm()` already falls back to the partial text, which by then is the
more complete of the two.

## Know why it stopped

``VoiceInputSession/state`` distinguishes waiting on permission from listening
from stopping, which is what a button needs to render itself honestly.

```swift
switch session.state {
case .idle:       EmptyView()
case .requesting: ProgressView()          // the system prompt may be up
case .listening:  RecordingIndicator()
case .processing: ProgressView()          // last words still landing
case .error(let error):
    Text(error.localizedDescription)
}
```

A session that stops has not necessarily failed. Silence, an explicit stop, a
phone call taking the audio session — all of them simply end the stream and
return the session to `.idle`, keeping whatever text had been recognised.

## Clean up

Nothing tears a session down on its own. One left in `.listening` holds the
microphone, so a view that can disappear mid-utterance should call
``VoiceInputSession/reset()`` on its way out.

## Substitute an engine

Pass any actor conforming to ``SpeechRecognizer`` — a different backend, or a
mock that replays scripted results so the state machine can be tested without a
microphone.

```swift
let session = VoiceInputSession(
    recognizer: WhisperRecognizer(),
    locale: Locale(identifier: "en-US")
)
```

Both are fixed for the session's lifetime; to recognise another language, make
another session.
