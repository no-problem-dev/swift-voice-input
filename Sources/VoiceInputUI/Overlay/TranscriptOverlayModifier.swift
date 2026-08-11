#if canImport(Speech)
import SwiftUI
import DesignSystem
import VoiceInput

/// Positions the floating preview above the view it is applied to.
///
/// It measures the host view rather than assuming a height, because the preview
/// has to clear an input field that grows as the user types. The measurement is
/// why this is a modifier and not a plain overlay.
struct TranscriptOverlayModifier: ViewModifier {

    let session: VoiceInputSession
    let onConfirm: (String) -> Void

    @Environment(\.spacingScale) private var spacing
    @State private var contentHeight: CGFloat = 0

    func body(content: Content) -> some View {
        let overlayGap = spacing.md

        content
            .background {
                GeometryReader { proxy in
                    Color.clear
                        .onAppear {
                            contentHeight = proxy.size.height
                        }
                        .onChange(of: proxy.size.height) { _, newValue in
                            contentHeight = newValue
                        }
                }
            }
            .overlay(alignment: .bottom) {
                if session.isActive {
                    FloatingTranscriptOverlay(
                        session: session,
                        onConfirm: onConfirm,
                        onCancel: {
                            session.reset()
                        }
                    )
                    .padding(.horizontal, overlayGap)
                    .padding(.bottom, contentHeight + overlayGap)
                    .transition(.asymmetric(
                        insertion: .scale(scale: 0.95).combined(with: .opacity),
                        removal: .opacity
                    ))
                }
            }
            .animation(.spring(response: 0.3, dampingFraction: 0.8), value: session.isActive)
    }
}

// MARK: - View Extension

extension View {

    /// Floats a transcript preview above this view while the session is running.
    ///
    /// The cheapest way to add voice input to an existing screen: nothing in the
    /// layout moves, because the preview is drawn over the content rather than
    /// inside it. That also means it will be clipped inside a `ScrollView` or a
    /// sheet — reach for ``InlineTranscriptView`` there instead.
    ///
    /// - Parameters:
    ///   - session: The session to follow. The preview appears and disappears
    ///     with it, so the same instance must be the one the mic button drives.
    ///   - onTranscript: Called with the final text when the user accepts it.
    ///     Cancelling discards the text without calling this.
    ///
    /// ```swift
    /// @State private var session = VoiceInputSession()
    /// @State private var text = ""
    ///
    /// TextField("Type here…", text: $text)
    ///     .voiceInputOverlay(session: session) { transcript in
    ///         text = transcript
    ///     }
    /// ```
    public func voiceInputOverlay(
        session: VoiceInputSession,
        onTranscript: @escaping (String) -> Void
    ) -> some View {
        modifier(TranscriptOverlayModifier(
            session: session,
            onConfirm: onTranscript
        ))
    }
}
#endif
