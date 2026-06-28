# Getting Started with VoiceInput

音声入力機能をアプリに組み込む手順を説明します。

## Installation

`Package.swift` の `dependencies` に追加します。

```swift
dependencies: [
    .package(url: "https://github.com/no-problem-dev/swift-voice-input.git", .upToNextMajor(from: "1.0.0")),
]
```

次に、ターゲットの `dependencies` に `VoiceInput` を追加します。

```swift
.target(
    name: "MyApp",
    dependencies: [
        .product(name: "VoiceInput", package: "swift-voice-input"),
    ]
)
```

SwiftUI コンポーネントも使用する場合は `VoiceInputUI` も追加してください。

```swift
.product(name: "VoiceInputUI", package: "swift-voice-input"),
```

## Info.plist の権限設定

音声入力にはマイクと音声認識の権限が必要です。`Info.plist` に以下のキーを追加してください。

- `NSMicrophoneUsageDescription` — マイクを使用する理由の説明文
- `NSSpeechRecognitionUsageDescription` — 音声認識を使用する理由の説明文

## Basic Usage

### 音声入力の開始と停止

``VoiceInputSession`` を `@State` で保持し、`toggle()` で開始・停止を切り替えます。

```swift
import VoiceInput

@Observable
class MyViewModel {
    var session = VoiceInputSession()
    var recognizedText = ""

    func toggleVoiceInput() {
        session.toggle()
    }
}
```

### リアルタイムテキストの取得

`session.partialText` を観察すると、発話中に逐次更新されるテキストを取得できます。確定テキストは `session.transcript` で参照できます。

```swift
// リアルタイムの部分テキスト（発話中に随時更新）
Text(session.partialText)

// 確定済みテキスト
Text(session.transcript)
```

### 認識結果の確定

`confirm()` を呼ぶと現在のテキストを返し、セッションをリセットします。

```swift
let text = session.confirm()
// text には partialText または transcript が返る
// セッションは .idle 状態にリセットされる
```

### 状態の監視

`session.state` で現在の認識状態を把握できます。

```swift
switch session.state {
case .idle:
    // 待機中
case .requesting:
    // 権限リクエスト中
case .listening:
    // 音声認識中
case .processing:
    // 処理中（停止後の短い遷移期間）
case .error(let error):
    // エラー発生
    print(error.localizedDescription)
}
```

### カスタム認識エンジンの差し込み

``SpeechRecognizer`` プロトコルに準拠した Actor を ``VoiceInputSession/init(recognizer:locale:)`` に渡します。

```swift
let session = VoiceInputSession(
    recognizer: WhisperRecognizer(),
    locale: Locale(identifier: "en-US")
)
```
