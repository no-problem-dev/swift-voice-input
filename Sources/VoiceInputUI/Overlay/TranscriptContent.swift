#if canImport(Speech)
import SwiftUI
import DesignSystem
import VoiceInput

/// The transcript text plus its accept and cancel controls, shared by both presentations.
///
/// Owns the one decision in the preview: accepting calls `confirm()`, which both
/// reads the text and resets the session, so the callback fires exactly once and
/// only when there is something to hand over.
struct TranscriptContent: View {

    let session: VoiceInputSession
    let onConfirm: (String) -> Void
    let onCancel: () -> Void

    @Environment(\.colorPalette) private var colors
    @Environment(\.spacingScale) private var spacing

    var body: some View {
        VStack(alignment: .leading, spacing: spacing.sm) {
            Text(displayText)
                .typography(.bodyLarge)
                .foregroundStyle(hasText ? colors.onSurface : colors.onSurfaceVariant)
                .lineLimit(4)
                .multilineTextAlignment(.leading)
                .fixedSize(horizontal: false, vertical: true)
                .frame(maxWidth: .infinity, alignment: .leading)
                .contentTransition(.numericText())
                .animation(.easeOut(duration: 0.15), value: session.partialText)

            HStack(spacing: spacing.sm) {
                WaveformIndicator(isListening: session.state == .listening)

                Spacer()

                Button {
                    onCancel()
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 22))
                        .foregroundStyle(colors.onSurfaceVariant)
                }
                .buttonStyle(.plain)

                Button {
                    let text = session.confirm()
                    if !text.isEmpty {
                        onConfirm(text)
                    }
                } label: {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 22))
                        .foregroundStyle(hasText ? colors.primary : colors.outlineVariant)
                }
                .buttonStyle(.plain)
                .disabled(!hasText)
            }
        }
    }

    // MARK: - Computed

    private var displayText: String {
        if !session.partialText.isEmpty {
            return session.partialText
        }
        if !session.transcript.isEmpty {
            return session.transcript
        }
        return "Listening…"
    }

    private var hasText: Bool {
        !session.partialText.isEmpty || !session.transcript.isEmpty
    }
}
#endif
