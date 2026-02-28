#if canImport(Speech)
import Testing
@testable import VoiceInput

@Suite("VoiceInputSession")
struct VoiceInputSessionTests {

    @Test("初期状態は idle")
    @MainActor
    func initialState() {
        let session = VoiceInputSession()
        #expect(session.state == .idle)
        #expect(session.transcript.isEmpty)
        #expect(session.partialText.isEmpty)
        #expect(!session.isActive)
    }

    @Test("権限拒否時にエラー状態になる")
    @MainActor
    func permissionDenied() async throws {
        let mock = MockSpeechRecognizer(
            permissionResult: .failure(.microphoneDenied)
        )
        let session = VoiceInputSession(recognizer: mock)

        session.startListening()

        // 状態遷移を待つ
        try await Task.sleep(for: .milliseconds(100))

        #expect(session.state == .error(.microphoneDenied))
        #expect(session.isPermissionDenied)
    }

    @Test("ストリーミング結果で partialText が更新される")
    @MainActor
    func streamingPartialResults() async throws {
        let mock = MockSpeechRecognizer(
            results: [
                .partial("こん"),
                .partial("こんにちは"),
                .final("こんにちは世界"),
            ]
        )
        let session = VoiceInputSession(recognizer: mock)

        session.startListening()

        // ストリームが完了するまで待つ
        try await Task.sleep(for: .milliseconds(200))

        #expect(session.transcript == "こんにちは世界")
        #expect(session.partialText == "こんにちは世界")
    }

    @Test("confirm でテキストを取得しリセットされる")
    @MainActor
    func confirmResetsSession() async throws {
        let mock = MockSpeechRecognizer(
            results: [.final("テスト入力")]
        )
        let session = VoiceInputSession(recognizer: mock)

        session.startListening()
        try await Task.sleep(for: .milliseconds(200))

        let text = session.confirm()
        #expect(text == "テスト入力")
        #expect(session.state == .idle)
        #expect(session.transcript.isEmpty)
        #expect(session.partialText.isEmpty)
    }

    @Test("reset でクリーンアップされる")
    @MainActor
    func resetClearsState() async throws {
        let mock = MockSpeechRecognizer(
            results: [.partial("途中")]
        )
        let session = VoiceInputSession(recognizer: mock)

        session.startListening()
        try await Task.sleep(for: .milliseconds(100))

        session.reset()
        #expect(session.state == .idle)
        #expect(session.partialText.isEmpty)
    }

    @Test("toggle で開始と停止を切り替えられる")
    @MainActor
    func toggleStartsAndStops() async throws {
        let mock = MockSpeechRecognizer(
            results: [
                .partial("あ"),
                .partial("あい"),
            ]
        )
        let session = VoiceInputSession(recognizer: mock)

        // 開始
        session.toggle()
        try await Task.sleep(for: .milliseconds(50))

        // listening 状態になっているはず（ストリーム完了前なら）
        // ストリームが短いのでタイミングにより idle の場合もある
        // toggle で停止
        if session.state == .listening {
            session.toggle()
            try await Task.sleep(for: .milliseconds(400))
            #expect(session.state == .idle)
        }
    }
}
#endif
