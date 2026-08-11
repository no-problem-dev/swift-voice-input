#if canImport(Speech)
import Speech
import AVFoundation

/// Turns the two permission APIs voice input needs into one shape: `true` means usable now.
///
/// Each call is safe to repeat. The system prompts at most once per permission
/// per install; after that these return the standing answer without any UI, so
/// callers can ask on every session rather than caching the result.
enum PermissionRequester {

    /// Whether the microphone may be used, prompting only if the user has never been asked.
    static func requestMicrophone() async -> Bool {
        let status = AVAudioApplication.shared.recordPermission
        switch status {
        case .granted: return true
        case .denied: return false
        case .undetermined: return await AVAudioApplication.requestRecordPermission()
        @unknown default: return false
        }
    }

    /// Whether captured audio may be transcribed, prompting only if the user has never been asked.
    ///
    /// `restricted` is folded in with `denied`: the app cannot change it either
    /// way, and it is set by device policy rather than by the user.
    static func requestSpeechRecognition() async -> Bool {
        let status = SFSpeechRecognizer.authorizationStatus()
        switch status {
        case .authorized: return true
        case .denied, .restricted: return false
        case .notDetermined:
            return await withCheckedContinuation { continuation in
                SFSpeechRecognizer.requestAuthorization { newStatus in
                    continuation.resume(returning: newStatus == .authorized)
                }
            }
        @unknown default: return false
        }
    }
}
#endif
