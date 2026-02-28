# 変更履歴

このプロジェクトの全ての重要な変更はこのファイルに記録されます。

フォーマットは [Keep a Changelog](https://keepachangelog.com/ja/1.0.0/) に基づいており、
このプロジェクトは [セマンティックバージョニング](https://semver.org/lang/ja/) に準拠しています。

## [未リリース]

なし

## [1.0.0] - 2026-03-01

### 追加

- **SpeechRecognizer プロトコル** — Actor ベースの音声認識エンジン抽象化
  - `start(locale:)` で `AsyncStream<SpeechRecognitionResult>` を返却
  - `.partial` / `.final` のストリーミング結果型
  - 権限リクエスト、可用性チェックを含む完全なライフサイクル管理
- **AppleSpeechRecognizer** — Apple SFSpeechRecognizer のデフォルト実装
  - リアルタイム部分結果対応
  - 2秒間の無音タイムアウトで自動停止
  - マイク・音声認識の段階的権限リクエスト
- **VoiceInputSession** — `@Observable` `@MainActor` の状態管理
  - `partialText` でリアルタイムテキスト公開
  - `toggle()`, `confirm()`, `reset()` の簡潔な API
- **VoiceInputButton** — DesignSystem 準拠のマイクトグルボタン
  - リスニング中のパルスアニメーション
  - 権限拒否時の設定画面誘導アラート
- **FloatingTranscriptOverlay** — Aqua Voice 風フローティングプレビュー
  - 入力フィールド上部にリアルタイム認識テキスト表示
  - 確認・キャンセルボタン付き
- **`.voiceInputOverlay()` modifier** — 任意の SwiftUI View にプレビューを付与

[未リリース]: https://github.com/no-problem-dev/swift-voice-input/compare/v1.0.0...HEAD
[1.0.0]: https://github.com/no-problem-dev/swift-voice-input/releases/tag/v1.0.0
