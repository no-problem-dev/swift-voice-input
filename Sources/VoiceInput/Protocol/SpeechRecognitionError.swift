import Foundation

/// Why voice input could not start, or could not continue.
///
/// The distinction that matters to a caller is retryability. The two denials are
/// dead ends in-app — only the user can undo them, in Settings — while
/// ``unavailable`` may clear on its own and ``engineFailure(_:)`` is usually
/// worth one more attempt.
///
/// ```swift
/// switch error {
/// case .microphoneDenied, .speechRecognitionDenied:
///     openSettings()        // retrying in-app cannot help
/// case .unavailable:
///     offerKeyboardInput()  // may succeed later, or in another locale
/// case .engineFailure(let message):
///     log(message)
/// }
/// ```
public enum SpeechRecognitionError: Error, Sendable, Equatable, LocalizedError {
    /// The user refused microphone access, so no audio can be captured at all.
    case microphoneDenied

    /// The user refused speech recognition, so audio is captured but cannot be transcribed.
    ///
    /// Worth separating from ``microphoneDenied`` because the two live under
    /// different rows in Settings, and telling the user the wrong one wastes the trip.
    case speechRecognitionDenied

    /// Recognition is not available on this device for the locale that was asked for.
    ///
    /// Not necessarily permanent: it also covers a server-backed recogniser that
    /// is offline and a language whose assets have not finished downloading.
    case unavailable

    /// The recognition engine failed for a reason outside the cases above.
    ///
    /// The payload is the underlying engine's own message, which
    /// ``errorDescription`` passes through unchanged.
    case engineFailure(String)

    /// The message shown to the user when this error is presented.
    public var errorDescription: String? {
        switch self {
        case .microphoneDenied:
            "Microphone access is turned off."
        case .speechRecognitionDenied:
            "Speech recognition is turned off."
        case .unavailable:
            "Speech recognition isn't available on this device."
        case .engineFailure(let message):
            message
        }
    }
}
