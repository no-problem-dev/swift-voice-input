[English](./README.md) | 日本語

# swift-voice-input

iOS / macOS 向けの音声入力。認識エンジンをプロトコルの裏に置き、差し替え可能にする。

[![Swift 6.2](https://img.shields.io/badge/Swift-6.2-orange.svg)](https://swift.org)
[![Platforms](https://img.shields.io/badge/Platforms-iOS%2017%20|%20macOS%2014-blue.svg)](https://developer.apple.com)

## 概要

- **エンジンは継ぎ目であって前提ではない** — Apple の認識器は既定であって設計ではない。`SpeechRecognizer` に準拠すれば差し込める。マイク無しで状態機械をテストできるのも同じ継ぎ目のおかげ
- **話した先からテキストが出る** — 部分結果が逐次流れ、ただの observable な文字列として公開される。View はストリームではなくプロパティに束ねればよい
- **権限拒否を取りこぼさない** — 音声機能が最も間違えやすい経路。拒否はアプリ内で再試行できない。付属のボタンはそれを伝え、設定アプリへ誘導する
- **UI は任意** — `VoiceInput` が認識器とセッション、`VoiceInputUI` が SwiftUI コンポーネント。前者だけに依存すれば SwiftUI はビルドに入らない

## 使い方

アプリ側の `Info.plist` に 2 つの用途説明が必須。

- `NSMicrophoneUsageDescription` — 音声を録音する理由
- `NSSpeechRecognitionUsageDescription` — その音声を文字起こしする理由

どちらかが欠けていると、その権限を要求した瞬間に OS がアプリを終了させる。
症状は「権限が拒否された」ではなく「最初のタップで落ちる」になる。

```swift
import VoiceInput
import VoiceInputUI

struct DictationField: View {
    @State private var session = VoiceInputSession()
    @State private var text = ""

    var body: some View {
        HStack {
            TextField("Type here…", text: $text)
            VoiceInputButton(session: session)
        }
        .voiceInputOverlay(session: session) { transcript in
            text = transcript
        }
    }
}
```

## ドキュメント

[**API リファレンスとガイド**](https://no-problem-dev.github.io/swift-voice-input/documentation/voiceinput/) —
[Getting Started](https://no-problem-dev.github.io/swift-voice-input/documentation/voiceinput/gettingstarted/)、
認識エンジンの差し替え、部分結果と確定結果の違いを含む。

## 要件

| iOS | macOS | Swift |
|-----|-------|-------|
| 17.0+ | 14.0+ | 6.2+ |

## インストール

```swift
dependencies: [
    .package(url: "https://github.com/no-problem-dev/swift-voice-input.git", .upToNextMajor(from: "2.0.0")),
]
```

必要な product を取る。`VoiceInput` はセッションと認識器、`VoiceInputUI` は
SwiftUI コンポーネント。

```swift
.product(name: "VoiceInput", package: "swift-voice-input"),
.product(name: "VoiceInputUI", package: "swift-voice-input"),
```

## コントリビュート

[CONTRIBUTING.md](CONTRIBUTING.md) を参照。

## ライセンス

MIT — [LICENSE](LICENSE) を参照。
