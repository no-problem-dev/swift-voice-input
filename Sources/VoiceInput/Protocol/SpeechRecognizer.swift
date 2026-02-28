import Foundation

/// 音声認識エンジンの抽象化プロトコル
///
/// Apple Speech、Whisper、ローカル LLM など異なるバックエンドを
/// 同一インターフェースで差し込み可能にする。
///
/// Actor 準拠により、オーディオエンジンの内部状態へのアクセスが
/// スレッドセーフに保たれる。
///
/// ```swift
/// let recognizer = AppleSpeechRecognizer()
/// let stream = try await recognizer.start(locale: Locale(identifier: "ja-JP"))
/// for await result in stream {
///     switch result {
///     case .partial(let text): print("途中: \(text)")
///     case .final(let text): print("確定: \(text)")
///     }
/// }
/// ```
public protocol SpeechRecognizer: Actor {
    /// 表示用の名前（例: "Apple Speech", "Whisper"）
    var displayName: String { get }

    /// このデバイスで利用可能かどうか
    var isAvailable: Bool { get }

    /// 必要な権限をリクエストする
    func requestPermissions() async -> Result<Void, SpeechRecognitionError>

    /// 音声認識を開始し、結果のストリームを返す
    ///
    /// `.partial` が発話中にリアルタイムで生成され、セグメント確定時に `.final` が生成される。
    /// `stop()` 呼び出しまたは無音タイムアウトでストリームが終了する。
    func start(locale: Locale) throws -> AsyncStream<SpeechRecognitionResult>

    /// 音声認識を停止する
    func stop()
}
