# ``VoiceInputUI``

SwiftUI controls that bind to a voice input session, so an existing text field gains a microphone.

## Overview

Three pieces, each solving a problem that is tedious to redo by hand: a
microphone button that handles refused permissions, and two ways to show the
transcript as it arrives.

`VoiceInput` has no dependency on this library. Depend on the core alone if you
draw your own controls.

### The button

``VoiceInputButton`` starts and stops the session, turns red and pulses while
listening, and — the part worth not rewriting — raises an alert routing the user
to Settings when a permission is refused. Because it follows the session's state
rather than its own taps, that alert can appear without the button being touched
again.

### Choosing a preview

Both previews show the same content and differ only in how they take up space.

``InlineTranscriptView`` sits in the layout, so surrounding content moves when it
appears. Use it inside a `ScrollView`, a sheet, or anywhere else a child cannot
draw outside its parent's bounds.

`voiceInputOverlay(session:onTranscript:)` floats above the view instead, so
nothing in the layout shifts. Cheaper to adopt, but it will be clipped in exactly
the containers the inline view exists for.

Either way, the transcript reaches your model through the callback and only when
the user accepts it. Cancelling discards the text silently, so that callback is
the single point where recognised text enters the app.

```swift
struct VoiceTextField: View {
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

Swap the modifier for ``InlineTranscriptView`` inside the container where an
overlay would be clipped:

```swift
VStack(alignment: .leading) {
    HStack {
        TextField("Type here…", text: $text)
        VoiceInputButton(session: session)
    }
    InlineTranscriptView(session: session) { transcript in
        text = transcript
    }
}
```

## Topics

### Starting and stopping

- ``VoiceInputButton``

### Showing the transcript

- ``InlineTranscriptView``
- ``SwiftUICore/View/voiceInputOverlay(session:onTranscript:)``
