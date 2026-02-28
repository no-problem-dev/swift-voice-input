#if canImport(Speech)
import SwiftUI
import DesignSystem

/// 録音中のパルスアニメーションインジケーター
///
/// 3本のバーがランダムな高さでアニメーションし、音声入力中であることを視覚的に示す。
struct WaveformIndicator: View {

    let isListening: Bool

    @Environment(\.colorPalette) private var colors

    @State private var animating = false

    var body: some View {
        HStack(spacing: 2) {
            ForEach(0..<3, id: \.self) { index in
                RoundedRectangle(cornerRadius: 1)
                    .fill(colors.error)
                    .frame(width: 3, height: barHeight(for: index))
                    .animation(
                        isListening
                            ? .easeInOut(duration: duration(for: index))
                              .repeatForever(autoreverses: true)
                            : .default,
                        value: animating
                    )
            }
        }
        .frame(width: 16, height: 16)
        .onChange(of: isListening) { _, newValue in
            animating = newValue
        }
        .onAppear {
            if isListening {
                animating = true
            }
        }
    }

    private func barHeight(for index: Int) -> CGFloat {
        if !animating {
            return 4
        }
        switch index {
        case 0: return 12
        case 1: return 16
        case 2: return 8
        default: return 4
        }
    }

    private func duration(for index: Int) -> TimeInterval {
        switch index {
        case 0: 0.4
        case 1: 0.5
        case 2: 0.35
        default: 0.4
        }
    }
}
#endif
