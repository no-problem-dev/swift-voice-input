#if canImport(Speech)
import SwiftUI
import DesignSystem
import VoiceInput

/// The card that floats above an input field while the user is speaking.
///
/// Presentation only — it holds no state and decides nothing. Positioning is the
/// modifier's job, and this raises itself off the background with an elevation
/// token because it sits over content it does not own.
struct FloatingTranscriptOverlay: View {

    let session: VoiceInputSession
    let onConfirm: (String) -> Void
    let onCancel: () -> Void

    @Environment(\.colorPalette) private var colors
    @Environment(\.spacingScale) private var spacing
    @Environment(\.radiusScale) private var radius

    var body: some View {
        TranscriptContent(
            session: session,
            onConfirm: onConfirm,
            onCancel: onCancel
        )
        .padding(spacing.md)
        .background(colors.surfaceVariant)
        .clipShape(RoundedRectangle(cornerRadius: radius.lg))
        .elevation(.level3)
    }
}
#endif
