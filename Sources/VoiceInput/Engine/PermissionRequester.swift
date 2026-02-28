#if canImport(Speech)
import Speech
import AVFoundation

/// マイク・音声認識の権限リクエストヘルパー
enum PermissionRequester {

    static func requestMicrophone() async -> Bool {
        let status = AVAudioApplication.shared.recordPermission
        switch status {
        case .granted: return true
        case .denied: return false
        case .undetermined: return await AVAudioApplication.requestRecordPermission()
        @unknown default: return false
        }
    }

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
