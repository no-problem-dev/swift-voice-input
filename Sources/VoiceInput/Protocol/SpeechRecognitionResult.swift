/// 音声認識のストリーミング結果
///
/// 認識中は `.partial` が逐次的に生成され、セグメント確定時に `.final` が生成される。
public enum SpeechRecognitionResult: Sendable, Equatable {
    /// 認識途中のテキスト（発話中に随時更新される）
    case partial(String)
    /// 確定済みのテキスト
    case final(String)

    /// partial/final を問わずテキストを取得
    public var text: String {
        switch self {
        case .partial(let t), .final(let t): t
        }
    }

    /// 確定済みかどうか
    public var isFinal: Bool {
        if case .final = self { return true }
        return false
    }
}
