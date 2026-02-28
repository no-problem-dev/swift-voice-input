#if canImport(Speech)
import SwiftUI
import DesignSystem
import VoiceInput

/// フローティング音声認識プレビュー
///
/// 入力フィールドの上部に表示され、音声認識のリアルタイムテキストを
/// ストリーミング表示する。Aqua Voice 風の UX を提供する。
///
/// 確認ボタンでテキストを入力欄に反映、キャンセルボタンで破棄する。
struct FloatingTranscriptOverlay: View {

    let session: VoiceInputSession
    let onConfirm: (String) -> Void
    let onCancel: () -> Void

    @Environment(\.colorPalette) private var colors
    @Environment(\.spacingScale) private var spacing
    @Environment(\.radiusScale) private var radius

    var body: some View {
        VStack(alignment: .leading, spacing: spacing.sm) {
            // リアルタイム認識テキスト
            Text(displayText)
                .typography(.bodyLarge)
                .foregroundStyle(hasText ? colors.onSurface : colors.onSurfaceVariant)
                .lineLimit(4)
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
        .padding(spacing.md)
        .background(colors.surfaceVariant)
        .clipShape(RoundedRectangle(cornerRadius: radius.lg))
        .elevation(.level3)
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
