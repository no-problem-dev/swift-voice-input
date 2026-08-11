#if canImport(Speech)
import SwiftUI
import DesignSystem
import VoiceInput

/// A transcript preview that takes up space in the layout instead of floating over it.
///
/// Use this rather than `voiceInputOverlay(session:onTranscript:)` wherever an
/// overlay would be clipped — inside a `ScrollView`, a sheet, or any container
/// whose bounds a child cannot escape. The cost is that surrounding content
/// shifts when it appears, so leave room for it or accept the reflow.
///
/// Renders nothing at all while the session is idle.
///
/// ```swift
/// @State private var session = VoiceInputSession()
/// @State private var text = ""
///
/// VStack {
///     TextField("Type here…", text: $text)
///     InlineTranscriptView(session: session) { transcript in
///         text = transcript
///     }
/// }
/// ```
public struct InlineTranscriptView: View {

    private let session: VoiceInputSession
    private let onTranscript: (String) -> Void

    @Environment(\.colorPalette) private var colors
    @Environment(\.spacingScale) private var spacing
    @Environment(\.radiusScale) private var radius

    /// Creates a preview for one session.
    ///
    /// - Parameters:
    ///   - session: The session to display. Pass the same instance the
    ///     microphone button drives.
    ///   - onTranscript: Called with the final text only when the user accepts
    ///     it. Cancelling discards the text and does not call this, so treat it
    ///     as the single point where recognised text enters your model.
    public init(
        session: VoiceInputSession,
        onTranscript: @escaping (String) -> Void
    ) {
        self.session = session
        self.onTranscript = onTranscript
    }

    public var body: some View {
        if session.isActive {
            TranscriptContent(
                session: session,
                onConfirm: onTranscript,
                onCancel: { session.reset() }
            )
            .padding(spacing.md)
            .background(colors.surfaceVariant)
            .clipShape(RoundedRectangle(cornerRadius: radius.lg))
            .transition(.asymmetric(
                insertion: .scale(scale: 0.95).combined(with: .opacity),
                removal: .opacity
            ))
        }
    }
}
#endif
