#if canImport(Speech)
import SwiftUI
import DesignSystem
import VoiceInput

/// A microphone button that starts and stops a session, and handles refused permissions for you.
///
/// The permission path is the reason to use this rather than a plain button: when
/// the session reports a denial, this raises an alert that takes the user to
/// Settings, since no amount of tapping will fix it. That means the alert can
/// appear without the button being tapped again — it follows the session's state.
///
/// While listening, the icon turns red and pulses. Nothing else is configurable;
/// build your own button against `VoiceInputSession` if you need a different
/// treatment.
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

    /// Creates a button driving one session.
    ///
    /// - Parameter session: The session to start and stop. The button reads its
    ///   state as well, so pass the same instance the transcript preview uses.
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
            Button("Open Settings") {
                openSettings()
            }
            Button("Cancel", role: .cancel) {
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
            case .microphoneDenied: return "Microphone Access Needed"
            case .speechRecognitionDenied: return "Speech Recognition Needed"
            default: break
            }
        }
        return "Permission Needed"
    }

    private var permissionAlertMessage: String {
        if case .error(let error) = session.state {
            switch error {
            case .microphoneDenied:
                return "Allow microphone access in Settings to use voice input."
            case .speechRecognitionDenied:
                return "Allow speech recognition in Settings to turn speech into text."
            default: break
            }
        }
        return "Allow the required permissions in Settings."
    }

    private func openSettings() {
        #if os(iOS)
        guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
        UIApplication.shared.open(url)
        #endif
    }
}
#endif
