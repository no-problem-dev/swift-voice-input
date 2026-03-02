#if canImport(Speech)
import SwiftUI
import DesignSystem
import VoiceInput

/// インラインの音声認識プレビュー
///
/// レイアウトフロー内に直接配置され、フローティングオーバーレイとは異なり
/// 親ビューの bounds を超えない。`ScrollView` 内やシート内での使用に適している。
///
/// ```swift
/// @State private var session = VoiceInputSession()
/// @State private var text = ""
///
/// VStack {
///     TextField("入力...", text: $text)
///     InlineTranscriptView(session: session) { transcript in
///         text = transcript
///     }
/// }
/// ```
public struct InlineTranscriptView: View {

    private let session: VoiceInputSession
    private let onConfirm: (String) -> Void

    @Environment(\.colorPalette) private var colors
    @Environment(\.spacingScale) private var spacing
    @Environment(\.radiusScale) private var radius

    public init(
        session: VoiceInputSession,
        onTranscript: @escaping (String) -> Void
    ) {
        self.session = session
        self.onConfirm = onTranscript
    }

    public var body: some View {
        if session.isActive {
            TranscriptContent(
                session: session,
                onConfirm: onConfirm,
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
