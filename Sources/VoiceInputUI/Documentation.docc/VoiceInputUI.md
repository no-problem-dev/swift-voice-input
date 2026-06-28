# ``VoiceInputUI``

`VoiceInputSession` に接続してすぐ使える SwiftUI コンポーネントと View modifier を提供する UI ライブラリ。

## Overview

`VoiceInputUI` は `VoiceInput` モジュールの `VoiceInputSession` をフロントエンドで扱うための SwiftUI コンポーネント集。マイクトグルボタン・インラインテキストプレビュー・フローティングオーバーレイの 3 つのプリミティブで構成されており、既存のフォームや入力欄に最小限の変更で音声入力機能を追加できる。

`VoiceInputButton` はマイクアイコンのトグルボタン。タップするたびに `VoiceInputSession.toggle()` を呼び出し、リスニング中はパルスアニメーションと赤色アイコンに変化する。権限拒否時は自動的に設定アプリへ誘導するアラートを表示するため、権限エラー処理を自前で実装する必要がない。

`InlineTranscriptView` はレイアウトフロー内に直接配置するプレビュー。`session.isActive` の間だけ表示され、リアルタイムの部分テキストをストリーミング表示する。`ScrollView` 内やシート内のように親ビューの bounds を超えられない場所の利用に適しており、確認・キャンセルボタンでテキストを反映または破棄できる。

`.voiceInputOverlay(session:onTranscript:)` は任意の View に適用できる modifier。セッションがアクティブな間だけ対象 View の上部にフローティングプレビューをスプリングアニメーションで表示する。既存の UI 構造を変えずに音声入力を追加する最もシンプルな方法。

### ボタンとインラインプレビューの組み合わせ

```swift
import VoiceInput
import VoiceInputUI

struct VoiceTextField: View {
    @State private var session = VoiceInputSession()
    @State private var text = ""

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                TextField("音声またはキーボードで入力", text: $text)
                VoiceInputButton(session: session)
            }
            InlineTranscriptView(session: session) { transcript in
                text = transcript
            }
        }
    }
}
```

### フローティングオーバーレイ

```swift
import VoiceInput
import VoiceInputUI

struct MessageView: View {
    @State private var session = VoiceInputSession()
    @State private var message = ""

    var body: some View {
        HStack {
            TextField("メッセージ", text: $message)
            VoiceInputButton(session: session)
        }
        .voiceInputOverlay(session: session) { transcript in
            message = transcript
        }
    }
}
```

## Topics

### ボタン

- ``VoiceInputButton``

### テキストプレビュー

- ``InlineTranscriptView``

### オーバーレイ Modifier

- ``SwiftUICore/View/voiceInputOverlay(session:onTranscript:)``
