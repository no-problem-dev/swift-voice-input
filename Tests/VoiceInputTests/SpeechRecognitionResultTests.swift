#if canImport(Speech)
import Testing
@testable import VoiceInput

@Suite("SpeechRecognitionResult")
struct SpeechRecognitionResultTests {

    @Test("partial はテキストを保持し isFinal は false")
    func partialResult() {
        let result = SpeechRecognitionResult.partial("こんにちは")
        #expect(result.text == "こんにちは")
        #expect(!result.isFinal)
    }

    @Test("final はテキストを保持し isFinal は true")
    func finalResult() {
        let result = SpeechRecognitionResult.final("こんにちは世界")
        #expect(result.text == "こんにちは世界")
        #expect(result.isFinal)
    }

    @Test("Equatable 準拠")
    func equatable() {
        #expect(SpeechRecognitionResult.partial("a") == .partial("a"))
        #expect(SpeechRecognitionResult.partial("a") != .partial("b"))
        #expect(SpeechRecognitionResult.partial("a") != .final("a"))
        #expect(SpeechRecognitionResult.final("x") == .final("x"))
    }
}
#endif
