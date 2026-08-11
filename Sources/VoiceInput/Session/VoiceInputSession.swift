#if canImport(Speech)
import Foundation

/// Observable state for one voice input field: what has been heard, and what the mic is doing.
///
/// Wraps any ``SpeechRecognizer`` so a view can bind to plain properties instead
/// of managing an async stream. Hold one per input field — two fields sharing a
/// session will fight over the same text.
///
/// Nothing tears the session down on its own. A session left in ``State/listening``
/// holds the microphone until something calls ``reset()``, so a view that can
/// disappear mid-utterance should do that as it goes.
///
/// ```swift
/// @State private var session = VoiceInputSession()
///
/// session.toggle()          // start, or stop if already listening
/// Text(session.partialText) // updates as the user speaks
/// let text = session.confirm()
/// ```
@Observable
@MainActor
public final class VoiceInputSession {

    // MARK: - State

    /// Where the session is in the start / listen / stop cycle.
    public enum State: Equatable, Sendable {
        /// Nothing is running and the microphone is free.
        case idle
        /// Waiting on the user to answer a permission prompt — may last indefinitely.
        case requesting
        /// The microphone is live and text is arriving.
        case listening
        /// Stopping: the engine has been told to stop but the last words may still land.
        case processing
        /// The attempt failed. Starting again from here is allowed and is how a retry happens.
        case error(SpeechRecognitionError)
    }

    /// Where the session is now; drive the microphone button's appearance from this.
    public private(set) var state: State = .idle

    /// Text the recogniser has settled on, set once per session when a final result arrives.
    ///
    /// Stays empty when a session ends by silence or by ``stopListening()`` before
    /// the recogniser settles, which is the common case — read ``partialText``
    /// too, or use ``confirm()``, which already prefers whichever is populated.
    public private(set) var transcript: String = ""

    /// Text as it is being recognised, replaced wholesale on every update.
    ///
    /// Words already shown can change as the recogniser reinterprets the
    /// utterance, so display it rather than treating it as committed input.
    public private(set) var partialText: String = ""

    /// Whether the session is doing anything the user should see — a good condition for showing a preview.
    ///
    /// Covers waiting on permission and stopping as well as listening, so the
    /// preview does not flicker out between those steps.
    public var isActive: Bool {
        state == .listening || state == .processing || state == .requesting
    }

    /// Whether the failure was a refused permission, which no in-app retry can fix.
    ///
    /// The only useful response is to send the user to Settings.
    public var isPermissionDenied: Bool {
        if case .error(let err) = state {
            return err == .microphoneDenied || err == .speechRecognitionDenied
        }
        return false
    }

    // MARK: - Configuration

    private let recognizer: any SpeechRecognizer
    private let locale: Locale
    private var recognitionTask: Task<Void, Never>?

    // MARK: - Init

    /// Creates a session bound to one backend and one language.
    ///
    /// Both are fixed for the session's lifetime; to recognise a different
    /// language, make another session.
    ///
    /// - Parameters:
    ///   - recognizer: The backend to drive. Substitute one in tests to exercise
    ///     the state machine without a microphone.
    ///   - locale: The language to recognise, independent of the device language.
    public init(
        recognizer: any SpeechRecognizer = AppleSpeechRecognizer(),
        locale: Locale = Locale(identifier: "ja-JP")
    ) {
        self.recognizer = recognizer
        self.locale = locale
    }

    // MARK: - Public API

    /// Starts listening, or stops if already listening — the whole behaviour of a mic button.
    ///
    /// Does nothing while a permission prompt is up, so a second tap cannot
    /// cancel a request the user has not answered yet.
    public func toggle() {
        if state == .listening {
            stopListening()
        } else if state == .idle || isRetryableState {
            startListening()
        }
    }

    /// Requests permission if needed, then starts listening; clears any previous text first.
    ///
    /// Ignored unless the session is idle or has failed, so calling it twice
    /// cannot open a second microphone session. Failures land in ``state`` rather
    /// than being thrown — this returns before the recogniser has even been asked.
    public func startListening() {
        guard state == .idle || isRetryableState else { return }

        transcript = ""
        partialText = ""
        state = .requesting

        recognitionTask = Task {
            let permissionResult = await recognizer.requestPermissions()
            switch permissionResult {
            case .failure(let error):
                state = .error(error)
                return
            case .success:
                break
            }

            do {
                let stream = try await recognizer.start(locale: locale)
                state = .listening

                for await result in stream {
                    switch result {
                    case .partial(let text):
                        partialText = text
                    case .final(let text):
                        transcript = text
                        partialText = text
                    }
                }

                if state == .listening || state == .processing {
                    state = .idle
                }
            } catch let error as SpeechRecognitionError {
                state = .error(error)
            } catch {
                state = .error(.engineFailure(error.localizedDescription))
            }
        }
    }

    /// Stops listening, keeping the text recognised so far.
    ///
    /// Only acts while listening; a stop during the permission prompt is ignored.
    /// The session passes through ``State/processing`` for a moment so the last
    /// words in flight can still land before it settles at ``State/idle``.
    public func stopListening() {
        guard state == .listening else { return }
        state = .processing

        Task {
            await recognizer.stop()
            // Long enough for a result already in flight to arrive, short enough
            // that the button does not feel stuck.
            try? await Task.sleep(for: .milliseconds(300))
            if state == .processing {
                state = .idle
            }
        }
    }

    /// Abandons the session and discards the text, releasing the microphone.
    ///
    /// The counterpart to ``confirm()`` for the cancel path, and what to call
    /// when a view holding the session goes away mid-utterance.
    public func reset() {
        recognitionTask?.cancel()
        recognitionTask = nil
        Task { await recognizer.stop() }
        transcript = ""
        partialText = ""
        state = .idle
    }

    /// Takes the recognised text and clears the session, ready for the next utterance.
    ///
    /// Prefers ``partialText`` over ``transcript``, because a session usually ends
    /// before the recogniser settles and the partial is then the more complete of
    /// the two. Returns an empty string when nothing was heard.
    @discardableResult
    public func confirm() -> String {
        let result = partialText.isEmpty ? transcript : partialText
        reset()
        return result
    }

    // MARK: - Private

    private var isRetryableState: Bool {
        if case .error = state { return true }
        return false
    }
}
#endif
