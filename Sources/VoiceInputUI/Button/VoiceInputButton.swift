#if canImport(Speech)
import SwiftUI
import DesignSystem
import VoiceInput

/// 音声入力トグルボタン
///
/// タップで音声認識の開始/停止を切り替える。
/// リスニング中はパルスアニメーションと赤色表示に変化する。
/// 権限拒否時はアラートで設定画面への誘導を表示する。
///
/// ```swift
/// @State private var session = VoiceInputSession()
///
/// VoiceInputButton(session: session)
/// ```
public struct VoiceInputButton: View {

    private let session: VoiceInputSession

    @State private var isPulsing = false
    @State private var showPermissionAlert = false

    @Environment(\.colorPalette) private var colors
    @Environment(\.motion) private var motion

    public init(session: VoiceInputSession) {
        self.session = session
    }

    public var body: some View {
        Button {
            session.toggle()
        } label: {
            Image(systemName: iconName)
                .font(.system(size: 20))
                .foregroundStyle(iconColor)
                .frame(width: 36, height: 36)
                .scaleEffect(isPulsing ? 1.2 : 1.0)
                .animation(
                    isListening
                        ? .easeInOut(duration: 0.6).repeatForever(autoreverses: true)
                        : .default,
                    value: isPulsing
                )
        }
        .buttonStyle(.plain)
        .onChange(of: session.state) { _, newState in
            switch newState {
            case .listening:
                isPulsing = true
            case .idle, .processing:
                isPulsing = false
            case .error(let error) where error == .microphoneDenied || error == .speechRecognitionDenied:
                isPulsing = false
                showPermissionAlert = true
            default:
                isPulsing = false
            }
        }
        .alert(permissionAlertTitle, isPresented: $showPermissionAlert) {
            Button("設定を開く") {
                openSettings()
            }
            Button("キャンセル", role: .cancel) {
                session.reset()
            }
        } message: {
            Text(permissionAlertMessage)
        }
    }

    // MARK: - Computed

    private var isListening: Bool {
        session.state == .listening
    }

    private var iconName: String {
        switch session.state {
        case .listening: "mic.fill"
        case .error(.microphoneDenied), .error(.speechRecognitionDenied): "mic.slash"
        default: "mic"
        }
    }

    private var iconColor: Color {
        switch session.state {
        case .listening: colors.error
        case .error(.microphoneDenied), .error(.speechRecognitionDenied): colors.outlineVariant
        default: colors.onSurfaceVariant
        }
    }

    private var permissionAlertTitle: String {
        if case .error(let error) = session.state {
            switch error {
            case .microphoneDenied: return "マイクの使用が許可されていません"
            case .speechRecognitionDenied: return "音声認識が許可されていません"
            default: break
            }
        }
        return "権限が必要です"
    }

    private var permissionAlertMessage: String {
        if case .error(let error) = session.state {
            switch error {
            case .microphoneDenied:
                return "音声入力を使用するには、設定アプリでマイクへのアクセスを許可してください。"
            case .speechRecognitionDenied:
                return "音声をテキストに変換するには、設定アプリで音声認識を許可してください。"
            default: break
            }
        }
        return "設定アプリで必要な権限を許可してください。"
    }

    private func openSettings() {
        #if os(iOS)
        guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
        UIApplication.shared.open(url)
        #endif
    }
}
#endif
