#if canImport(Speech)
import SwiftUI
import DesignSystem
import VoiceInput

/// 音声認識のフローティングプレビューを付与する ViewModifier
///
/// 対象 View の上部にオーバーレイとして配置され、
/// `VoiceInputSession` がアクティブな間だけ表示される。
struct TranscriptOverlayModifier: ViewModifier {

    let session: VoiceInputSession
    let onConfirm: (String) -> Void

    @Environment(\.spacingScale) private var spacing

    func body(content: Content) -> some View {
        content
            .overlay(alignment: .top) {
                if session.isActive {
                    FloatingTranscriptOverlay(
                        session: session,
                        onConfirm: onConfirm,
                        onCancel: {
                            session.reset()
                        }
                    )
                    .padding(.horizontal, spacing.md)
                    .offset(y: -(spacing.xl))
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

    /// 音声入力のフローティングプレビューオーバーレイを追加する
    ///
    /// `VoiceInputSession` がアクティブな間、対象 View の上部に
    /// リアルタイム認識テキストのプレビューを表示する。
    ///
    /// ```swift
    /// @State private var session = VoiceInputSession()
    /// @State private var text = ""
    ///
    /// TextField("入力...", text: $text)
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
