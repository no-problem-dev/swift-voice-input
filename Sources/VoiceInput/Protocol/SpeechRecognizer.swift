import Foundation

/// A swappable speech recognition backend behind one streaming interface.
///
/// The requirement is deliberately `Actor`: a backend owns the microphone and
/// mutable engine state, and actor isolation is what stops a double-tapped
/// button from leaving two capture sessions running at once.
///
/// Drive it in order — permissions, start, consume the stream, stop. Conformers
/// are not obliged to re-check permissions inside ``start(locale:)``, so skipping
/// the request tends to surface as a stream that finishes having produced nothing
/// rather than as an error.
///
/// ```swift
/// let recognizer = AppleSpeechRecognizer()
/// guard case .success = await recognizer.requestPermissions() else { return }
///
/// for await result in try await recognizer.start(locale: Locale(identifier: "en-US")) {
///     print(result.isFinal ? "settled: \(result.text)" : "so far: \(result.text)")
/// }
/// ```
public protocol SpeechRecognizer: Actor {
    /// A name for this backend fit to show a user choosing between engines.
    var displayName: String { get }

    /// Whether this backend can recognise speech on this device right now.
    ///
    /// The answer changes at runtime — a server-backed engine loses the network,
    /// a language pack finishes downloading — so read it just before starting
    /// rather than caching it at launch.
    var isAvailable: Bool { get }

    /// Asks the user for every permission this backend needs, prompting only the first time.
    ///
    /// A denial is final as far as the app is concerned: the system will not ask
    /// again, and only the user can reverse it in Settings. Treat a failure as a
    /// reason to send them there, not as something to retry.
    ///
    /// - Returns: `.success` only when every required permission is granted;
    ///   otherwise the specific denial, so the caller can name the right setting.
    func requestPermissions() async -> Result<Void, SpeechRecognitionError>

    /// Begins recognising and hands back the stream of transcriptions it produces.
    ///
    /// See ``SpeechRecognitionResult`` for how partial and final updates differ.
    /// The stream finishes on ``stop()``, on a final result, or when the backend
    /// gives up — silence, an interrupted audio session, an engine failure. A
    /// finished stream is therefore not by itself evidence that anything was heard.
    ///
    /// - Parameter locale: The language to recognise. A backend that cannot serve
    ///   it throws rather than quietly recognising in some other language.
    /// - Throws: ``SpeechRecognitionError/unavailable`` when this device or this
    ///   locale cannot be served.
    func start(locale: Locale) throws -> AsyncStream<SpeechRecognitionResult>

    /// Ends recognition and releases the microphone.
    ///
    /// Safe to call when nothing is running. Any stream handed out by
    /// ``start(locale:)`` finishes as a result, so a `for await` loop over it
    /// ends rather than hanging.
    func stop()
}
