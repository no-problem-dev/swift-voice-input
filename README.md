# swift-voice-input

iOS / macOS 向けの音声入力 Swift パッケージ。プロトコル指向の設計により、Apple Speech をはじめとする複数の音声認識バックエンドを差し込み可能にする。

[![Swift 6.2](https://img.shields.io/badge/Swift-6.2-orange.svg)](https://swift.org)
[![Platforms](https://img.shields.io/badge/Platforms-iOS%2017%20|%20macOS%2014-blue.svg)](https://developer.apple.com)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)

## 特徴

- **プロトコル指向** — `SpeechRecognizer` プロトコルで認識エンジンを抽象化。Apple Speech、Whisper、ローカル LLM 等を差し込み可能
- **リアルタイムストリーミング** — `AsyncStream` で部分結果を逐次配信。`partialText` でリアルタイム表示
- **フローティングプレビュー** — Aqua Voice 風のオーバーレイで、入力フィールド上部に認識テキストをリアルタイム表示
- **DesignSystem 準拠** — [swift-design-system](https://github.com/no-problem-dev/swift-design-system) のトークン体系に完全準拠した UI コンポーネント
- **2ターゲット構成** — `VoiceInput`（Core）と `VoiceInputUI`（SwiftUI）を分離。UI 不要な場合は Core のみ依存可能
- **Swift Concurrency** — Actor ベースの音声エンジン、`@Observable` の状態管理で安全な並行処理

## インストール

`Package.swift` に依存を追加:

```swift
dependencies: [
    .package(url: "https://github.com/no-problem-dev/swift-voice-input.git", .upToNextMajor(from: "1.0.0")),
]
```

ターゲットに追加:

```swift
// Core のみ（UI 不要な場合）
.product(name: "VoiceInput", package: "swift-voice-input"),

// Core + SwiftUI コンポーネント
.product(name: "VoiceInputUI", package: "swift-voice-input"),
```

## クイックスタート

### 基本的な使い方

```swift
import VoiceInput
import VoiceInputUI

struct MyView: View {
    @State private var session = VoiceInputSession()
    @State private var text = ""

    var body: some View {
        VStack {
            TextField("入力...", text: $text)

            VoiceInputButton(session: session)
        }
        .voiceInputOverlay(session: session) { transcript in
            text = transcript
        }
    }
}
```

### カスタム認識エンジンの差し込み

`SpeechRecognizer` プロトコルに準拠した Actor を実装:

```swift
actor WhisperRecognizer: SpeechRecognizer {
    let displayName = "Whisper"
    var isAvailable: Bool { true }

    func requestPermissions() async -> Result<Void, SpeechRecognitionError> {
        // マイク権限のリクエスト
    }

    func start(locale: Locale) throws -> AsyncStream<SpeechRecognitionResult> {
        // Whisper モデルによる認識開始
    }

    func stop() {
        // 認識停止
    }
}

// 使用時に差し込み
@State private var session = VoiceInputSession(
    recognizer: WhisperRecognizer()
)
```

### セッション API

```swift
let session = VoiceInputSession()

session.toggle()           // 開始/停止のトグル
session.startListening()   // 開始
session.stopListening()    // 停止

session.state              // .idle, .listening, .processing, .error
session.partialText        // リアルタイムの部分テキスト
session.transcript         // 確定テキスト

let text = session.confirm() // テキスト確定 + リセット
session.reset()              // リセット
```

## アーキテクチャ

```
VoiceInput (Core)
├── Protocol/
│   ├── SpeechRecognizer         # 認識エンジン抽象化プロトコル (Actor)
│   ├── SpeechRecognitionResult  # .partial / .final 結果型
│   └── SpeechRecognitionError   # エラー型
├── Engine/
│   ├── AppleSpeechRecognizer    # Apple Speech デフォルト実装
│   └── PermissionRequester      # マイク・音声認識権限
└── Session/
    └── VoiceInputSession        # @Observable 状態管理

VoiceInputUI (SwiftUI + DesignSystem)
├── Button/
│   ├── VoiceInputButton         # マイクトグルボタン
│   └── WaveformIndicator        # 波形アニメーション
└── Overlay/
    ├── FloatingTranscriptOverlay # フローティングプレビュー
    └── TranscriptOverlayModifier # .voiceInputOverlay() modifier
```

## 要件

| 要件 | バージョン |
|------|-----------|
| iOS | 17.0+ |
| macOS | 14.0+ |
| Swift | 6.2+ |
| Xcode | 26.0+ |

## ライセンス

MIT License - 詳細は [LICENSE](LICENSE) を参照。

## リンク

- [Issues](https://github.com/no-problem-dev/swift-voice-input/issues)
