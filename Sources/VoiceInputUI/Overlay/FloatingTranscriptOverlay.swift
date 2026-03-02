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
