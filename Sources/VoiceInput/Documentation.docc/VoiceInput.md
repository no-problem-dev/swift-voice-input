# ``VoiceInput``

プロトコル指向の音声入力 Core ライブラリ。Apple Speech をはじめとする複数のバックエンドを同一インターフェースで差し込み可能にする。

## Overview

`VoiceInput` は iOS / macOS 向けの音声入力 Swift パッケージ。`SpeechRecognizer` プロトコルで認識エンジンを抽象化し、`AsyncStream` でリアルタイムの部分テキストをストリーミング配信する。

`VoiceInputSession` は `@Observable` な状態管理クラスで、認識の開始・停止・テキスト確定をシンプルな API で提供する。

```swift
import VoiceInput

@State private var session = VoiceInputSession()

// 開始/停止のトグル
session.toggle()

// リアルタイムの部分テキスト
Text(session.partialText)

// テキストを確定して取得（セッションはリセットされる）
let text = session.confirm()
```

`SpeechRecognizer` プロトコルに準拠した Actor を実装すれば、Whisper やローカル LLM など任意のバックエンドを差し込める。

```swift
actor WhisperRecognizer: SpeechRecognizer {
    let displayName = "Whisper"
    var isAvailable: Bool { true }

    func requestPermissions() async -> Result<Void, SpeechRecognitionError> {
        // マイク権限のリクエスト
        .success(())
    }

    func start(locale: Locale) throws -> AsyncStream<SpeechRecognitionResult> {
        // Whisper モデルによる認識開始
        AsyncStream { _ in }
    }

    func stop() {}
}
```

SwiftUI コンポーネントが必要な場合は `VoiceInputUI` モジュールを追加する。`VoiceInputUI` は `VoiceInputSession` を受け取るマイクトグルボタン（`VoiceInputButton`）、フロー内に配置するインラインプレビュー（`InlineTranscriptView`）、任意の View に後付けできるフローティングオーバーレイ modifier（`.voiceInputOverlay(session:onTranscript:)`）を提供する。`VoiceInput` はバックエンドと状態管理のみを担い、UI の詳細は `VoiceInputUI` に委ねる設計。

## Topics

### はじめに

- <doc:GettingStarted>

### セッション管理

- ``VoiceInputSession``

### 認識プロトコル

- ``SpeechRecognizer``
- ``SpeechRecognitionResult``
- ``SpeechRecognitionError``

### 組み込みエンジン

- ``AppleSpeechRecognizer``
