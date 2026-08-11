#if canImport(Speech)
import Speech
import AVFoundation

/// Apple's built-in recogniser, transcribing a live microphone tap with `SFSpeechRecognizer`.
///
/// ## Before the first line of code works
///
/// The host app must declare both `NSMicrophoneUsageDescription` and
/// `NSSpeechRecognitionUsageDescription` in its `Info.plist`. A missing key is
/// not a soft failure: the system terminates the app at the moment that
/// permission is requested, so the symptom is a crash on first tap rather than
/// a denied permission.
///
/// ``requestPermissions()`` must succeed before ``start(locale:)``. Nothing here
/// re-checks, so starting without permission yields a stream that finishes
/// having produced nothing rather than one that reports an error.
///
/// ## On-device or sent to Apple
///
/// Recognition follows the system default, which for most locales means the
/// audio leaves the device. Apple also caps how many recognitions a device may
/// perform per day and how long one utterance may be (roughly a minute). Both
/// make this a short-utterance input method rather than a transcription engine —
/// mention the network hop in a privacy policy if the app handles anything
/// sensitive.
///
/// ## How a session ends
///
/// The stream finishes on ``stop()``, on a final result from the recogniser, or
/// after `silenceTimeout` elapses with no new partial result. Interruptions are
/// not observed separately: when a call arrives, or Siri takes over, or another
/// app claims the audio session, audio simply stops arriving — indistinguishable
/// from the user falling silent, and ended the same way, keeping whatever text
/// had been recognised up to that point.
public actor AppleSpeechRecognizer: SpeechRecognizer {

    public let displayName = "Apple Speech"

    private let silenceTimeout: TimeInterval

    private var recognizer: SFSpeechRecognizer?
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private var audioEngine: AVAudioEngine?
    private var silenceTimer: Timer?
    private var continuation: AsyncStream<SpeechRecognitionResult>.Continuation?

    /// Creates a recogniser that gives up after a chosen stretch of silence.
    ///
    /// - Parameter silenceTimeout: How long to wait for a new partial result
    ///   before ending the stream. Shorter feels responsive for single phrases;
    ///   longer tolerates the pauses in a dictated sentence.
    public init(silenceTimeout: TimeInterval = 2.0) {
        self.silenceTimeout = silenceTimeout
    }

    /// Whether recognition is available for the device's *current* locale.
    ///
    /// It says nothing about the locale you intend to pass to ``start(locale:)``,
    /// which is checked separately and throws if unsupported.
    public var isAvailable: Bool {
        SFSpeechRecognizer()?.isAvailable ?? false
    }

    /// Asks for microphone access first, then speech recognition — two prompts, in that order.
    ///
    /// Stops at the first refusal, so the returned failure names the setting the
    /// user actually has to change.
    public func requestPermissions() async -> Result<Void, SpeechRecognitionError> {
        let micGranted = await PermissionRequester.requestMicrophone()
        guard micGranted else { return .failure(.microphoneDenied) }

        let speechGranted = await PermissionRequester.requestSpeechRecognition()
        guard speechGranted else { return .failure(.speechRecognitionDenied) }

        return .success(())
    }

    /// Starts a fresh session, discarding any session still running.
    ///
    /// On iOS this claims the shared audio session for recording and ducks other
    /// apps' audio, which stays ducked for as long as the session is held.
    ///
    /// - Parameter locale: The language to recognise. Unsupported locales throw
    ///   rather than falling back to the device language.
    /// - Throws: ``SpeechRecognitionError/unavailable`` if no recogniser exists
    ///   for this locale; the underlying `AVFoundation` error if the audio
    ///   session or engine refuses to start.
    public func start(locale: Locale) throws -> AsyncStream<SpeechRecognitionResult> {
        // Two taps in quick succession must not leave two engines on the microphone.
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
                    // A partial result is the only proof that speech is still
                    // arriving, so it is what restarts the silence countdown.
                    let captured = self
                    Task { await captured?.resetSilenceTimer(timeout: timeout) }
                }
            }
            if let error {
                let nsError = error as NSError
                // Code 216 in this domain is the recogniser acknowledging the
                // cancel() that stop() just issued. Surfacing it would turn every
                // ordinary stop into an error.
                if nsError.domain == "kAFAssistantErrorDomain" && nsError.code == 216 {
                    return
                }
                cont.yield(.final(""))
                cont.finish()
            }
        }

        let engine = AVAudioEngine()
        self.audioEngine = engine

        let inputNode = engine.inputNode
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { buffer, _ in
            request.append(buffer)
        }

        engine.prepare()
        try engine.start()

        // Armed before any speech arrives, so a user who never speaks still ends the stream.
        scheduleSilenceTimer(timeout: timeout)

        return stream
    }

    /// Ends the session, releases the microphone, and finishes the stream.
    ///
    /// Safe to call when nothing is running.
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
