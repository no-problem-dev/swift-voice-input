#if canImport(Speech)
import Foundation

/// 音声入力セッションの状態管理
///
/// `SpeechRecognizer` プロトコルを介して任意の音声認識バックエンドを使用し、
/// リアルタイムのストリーミング結果を `partialText` で公開する。
///
/// ```swift
/// @State private var session = VoiceInputSession()
///
/// // トグルで開始/停止
/// session.toggle()
///
/// // リアルタイムテキスト
/// Text(session.partialText)
///
/// // 確定して取得
/// let text = session.confirm()
/// ```
@Observable
@MainActor
public final class VoiceInputSession {

    // MARK: - State

    public enum State: Equatable, Sendable {
        case idle
        case requesting
        case listening
        case processing
        case error(SpeechRecognitionError)
    }

    /// 現在の状態
    public private(set) var state: State = .idle

    /// 確定済みテキスト（`.final` 結果で更新）
    public private(set) var transcript: String = ""

    /// リアルタイムの部分テキスト（`.partial` 結果で逐次更新）
    public private(set) var partialText: String = ""

    /// 認識がアクティブかどうか
    public var isActive: Bool {
        state == .listening || state == .processing || state == .requesting
    }

    /// 権限が拒否されているかどうか
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

    /// 音声入力セッションを作成
    ///
    /// - Parameters:
    ///   - recognizer: 音声認識バックエンド（デフォルト: `AppleSpeechRecognizer`）
    ///   - locale: 認識言語（デフォルト: ja-JP）
    public init(
        recognizer: any SpeechRecognizer = AppleSpeechRecognizer(),
        locale: Locale = Locale(identifier: "ja-JP")
    ) {
        self.recognizer = recognizer
        self.locale = locale
    }

    // MARK: - Public API

    /// 認識の開始/停止をトグル
    public func toggle() {
        if state == .listening {
            stopListening()
        } else if state == .idle || isRetryableState {
            startListening()
        }
    }

    /// 音声認識を開始
    public func startListening() {
        guard state == .idle || isRetryableState else { return }

        transcript = ""
        partialText = ""
        state = .requesting

        recognitionTask = Task {
            // 権限チェック
            let permissionResult = await recognizer.requestPermissions()
            switch permissionResult {
            case .failure(let error):
                state = .error(error)
                return
            case .success:
                break
            }

            // 認識開始
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

                // ストリーム終了後
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

    /// 音声認識を停止
    public func stopListening() {
        guard state == .listening else { return }
        state = .processing

        Task {
            await recognizer.stop()
            // 短い遅延で processing → idle 遷移
            try? await Task.sleep(for: .milliseconds(300))
            if state == .processing {
                state = .idle
            }
        }
    }

    /// セッションをリセット（テキストクリア）
    public func reset() {
        recognitionTask?.cancel()
        recognitionTask = nil
        Task { await recognizer.stop() }
        transcript = ""
        partialText = ""
        state = .idle
    }

    /// 現在のテキストを確定して返す
    ///
    /// 確定後にセッションはリセットされる。
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
