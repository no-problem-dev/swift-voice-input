#if canImport(Speech)
import Speech
import AVFoundation

/// Apple 標準の音声認識エンジン（SFSpeechRecognizer）
///
/// `SpeechRecognizer` プロトコルに準拠し、`AVAudioEngine` でマイク入力を取得、
/// `SFSpeechRecognizer` でリアルタイム音声認識を実行する。
///
/// 2秒間の無音を検出すると自動的に認識を停止する。
public actor AppleSpeechRecognizer: SpeechRecognizer {

    public let displayName = "Apple Speech"

    private let silenceTimeout: TimeInterval

    private var recognizer: SFSpeechRecognizer?
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private var audioEngine: AVAudioEngine?
    private var silenceTimer: Timer?
    private var continuation: AsyncStream<SpeechRecognitionResult>.Continuation?

    /// - Parameter silenceTimeout: 無音で自動停止するまでの秒数（デフォルト: 2秒）
    public init(silenceTimeout: TimeInterval = 2.0) {
        self.silenceTimeout = silenceTimeout
    }

    public var isAvailable: Bool {
        SFSpeechRecognizer()?.isAvailable ?? false
    }

    public func requestPermissions() async -> Result<Void, SpeechRecognitionError> {
        let micGranted = await PermissionRequester.requestMicrophone()
        guard micGranted else { return .failure(.microphoneDenied) }

        let speechGranted = await PermissionRequester.requestSpeechRecognition()
        guard speechGranted else { return .failure(.speechRecognitionDenied) }

        return .success(())
    }

    public func start(locale: Locale) throws -> AsyncStream<SpeechRecognitionResult> {
        // 既存のセッションをクリーンアップ
        cleanupInternal()

        let recognizer = SFSpeechRecognizer(locale: locale)
        guard let recognizer, recognizer.isAvailable else {
            throw SpeechRecognitionError.unavailable
        }
        self.recognizer = recognizer

        #if os(iOS)
        let audioSession = AVAudioSession.sharedInstance()
        try audioSession.setCategory(.record, mode: .measurement, options: .duckOthers)
        try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
        #endif

        let request = SFSpeechAudioBufferRecognitionRequest()
        request.shouldReportPartialResults = true
        self.recognitionRequest = request

        let stream = AsyncStream<SpeechRecognitionResult> { continuation in
            self.continuation = continuation
        }

        let cont = self.continuation!
        let timeout = self.silenceTimeout

        recognitionTask = recognizer.recognitionTask(with: request) { [weak self] result, error in
            if let result {
                let text = result.bestTranscription.formattedString
                if result.isFinal {
                    cont.yield(.final(text))
                    cont.finish()
                } else {
                    cont.yield(.partial(text))
                    // 部分結果が来るたびに無音タイマーをリセット
                    let captured = self
                    Task { await captured?.resetSilenceTimer(timeout: timeout) }
                }
            }
            if let error {
                let nsError = error as NSError
                // キャンセルエラーは無視
                if nsError.domain == "kAFAssistantErrorDomain" && nsError.code == 216 {
                    return
                }
                cont.yield(.final(""))
                cont.finish()
            }
        }

        // オーディオエンジンセットアップ
        let engine = AVAudioEngine()
        self.audioEngine = engine

        let inputNode = engine.inputNode
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { buffer, _ in
            request.append(buffer)
        }

        engine.prepare()
        try engine.start()

        // 初回の無音タイマー開始
        scheduleSilenceTimer(timeout: timeout)

        return stream
    }

    public func stop() {
        cleanupInternal()
    }

    // MARK: - Private

    private func cleanupInternal() {
        silenceTimer?.invalidate()
        silenceTimer = nil

        audioEngine?.stop()
        audioEngine?.inputNode.removeTap(onBus: 0)
        audioEngine = nil

        recognitionRequest?.endAudio()
        recognitionRequest = nil

        recognitionTask?.cancel()
        recognitionTask = nil

        continuation?.finish()
        continuation = nil
    }

    private func scheduleSilenceTimer(timeout: TimeInterval) {
        silenceTimer?.invalidate()
        let cont = self.continuation
        silenceTimer = Timer.scheduledTimer(withTimeInterval: timeout, repeats: false) { _ in
            cont?.finish()
        }
    }

    private func resetSilenceTimer(timeout: TimeInterval) {
        scheduleSilenceTimer(timeout: timeout)
    }
}
#endif
