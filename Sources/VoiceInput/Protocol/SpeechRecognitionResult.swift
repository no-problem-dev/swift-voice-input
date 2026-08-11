/// One update from a recognition stream, either still being revised or settled.
///
/// Every value carries the whole utterance recognised so far, not the delta since
/// the last one, so render it by replacing the previous text rather than appending.
///
/// A stream emits many ``partial(_:)`` values and at most one ``final(_:)``. It can
/// end without ever producing a final — a silence timeout or an explicit stop just
/// finishes the stream — so take the newest partial as the answer instead of waiting
/// for a final that may never arrive.
public enum SpeechRecognitionResult: Sendable, Equatable {
    /// Text the recogniser is still revising.
    ///
    /// Later values may rewrite any part of it, not just extend it: the recogniser
    /// reinterprets earlier words as more of the utterance arrives. Safe to display,
    /// not safe to act on.
    case partial(String)

    /// Text the recogniser has settled on and will not revise.
    ///
    /// The stream finishes immediately after this value.
    case final(String)

    /// The text of this update, whether or not the recogniser has settled on it.
    ///
    /// Use it to display; use ``isFinal`` to decide whether to commit.
    public var text: String {
        switch self {
        case .partial(let t), .final(let t): t
        }
    }

    /// Whether this text is settled and the stream is about to finish.
    public var isFinal: Bool {
        if case .final = self { return true }
        return false
    }
}
