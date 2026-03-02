#if canImport(Speech)
import SwiftUI
import DesignSystem
import VoiceInput

/// 音声認識テキスト表示の共通コンテンツ（内部用）
///
/// `FloatingTranscriptOverlay` と `InlineTranscriptView` で共有される。
struct TranscriptContent: View {

    let session: VoiceInputSession
    let onConfirm: (String) -> Void
    let onCancel: () -> Void

    @Environment(\.colorPalette) private var colors
    @Environment(\.spacingScale) private var spacing

    var body: some View {
        VStack(alignment: .leading, spacing: spacing.sm) {
            // リアルタイム認識テキスト
            Text(displayText)
                .typography(.bodyLarge)
                .foregroundStyle(hasText ? colors.onSurface : colors.onSurfaceVariant)
                .lineLimit(4)
                .multilineTextAlignment(.leading)
                .fixedSize(horizontal: false, vertical: true)
                .frame(maxWidth: .infinity, alignment: .leading)
                .contentTransition(.numericText())
                .animation(.easeOut(duration: 0.15), value: session.partialText)

            // 下部: ウェーブフォーム + アクションボタン
            HStack(spacing: spacing.sm) {
                WaveformIndicator(isListening: session.state == .listening)

                Spacer()

                // キャンセル
                Button {
                    onCancel()
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 22))
                        .foregroundStyle(colors.onSurfaceVariant)
                }
                .buttonStyle(.plain)

                // 確認
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
        return "聴いています..."
    }

    private var hasText: Bool {
        !session.partialText.isEmpty || !session.transcript.isEmpty
    }
}
#endif
