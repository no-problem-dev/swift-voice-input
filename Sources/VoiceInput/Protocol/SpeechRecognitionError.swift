import Foundation

/// 音声認識で発生しうるエラー
public enum SpeechRecognitionError: Error, Sendable, Equatable, LocalizedError {
    /// マイク権限が拒否されている
    case microphoneDenied
    /// 音声認識権限が拒否されている
    case speechRecognitionDenied
    /// デバイスで音声認識が利用できない
    case unavailable
    /// エンジン内部エラー
    case engineFailure(String)

    public var errorDescription: String? {
        switch self {
        case .microphoneDenied:
            "マイクの使用が許可されていません"
        case .speechRecognitionDenied:
            "音声認識が許可されていません"
        case .unavailable:
            "音声認識がこのデバイスでは利用できません"
        case .engineFailure(let message):
            message
        }
    }
}
