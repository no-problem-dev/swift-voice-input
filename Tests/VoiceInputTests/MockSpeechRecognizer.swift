#if canImport(Speech)
import Foundation
import VoiceInput

/// テスト用のモック音声認識エンジン
///
/// プロトコル準拠を検証し、`VoiceInputSession` の状態遷移テストに使用する。
/// `results` に設定したイベントを順次ストリーム配信する。
actor MockSpeechRecognizer: SpeechRecognizer {

    let displayName = "Mock"

    var isAvailable: Bool { _isAvailable }

    private var _isAvailable: Bool
    private var permissionResult: Result<Void, SpeechRecognitionError>
    private var results: [SpeechRecognitionResult]
    private var _startCallCount = 0
    private var _stopCallCount = 0
    private var continuation: AsyncStream<SpeechRecognitionResult>.Continuation?

    var startCallCount: Int { _startCallCount }
    var stopCallCount: Int { _stopCallCount }

    init(
        isAvailable: Bool = true,
        permissionResult: Result<Void, SpeechRecognitionError> = .success(()),
        results: [SpeechRecognitionResult] = []
    ) {
        self._isAvailable = isAvailable
        self.permissionResult = permissionResult
        self.results = results
    }

    func requestPermissions() async -> Result<Void, SpeechRecognitionError> {
        permissionResult
    }

    func start(locale: Locale) throws -> AsyncStream<SpeechRecognitionResult> {
        guard _isAvailable else {
            throw SpeechRecognitionError.unavailable
        }

        _startCallCount += 1

        let capturedResults = results
        return AsyncStream { continuation in
            self.continuation = continuation
            Task {
                for result in capturedResults {
                    continuation.yield(result)
                    // 少し間を空ける
                    try? await Task.sleep(for: .milliseconds(10))
                }
                continuation.finish()
            }
        }
    }

    func stop() {
        _stopCallCount += 1
        continuation?.finish()
        continuation = nil
    }
}
#endif
