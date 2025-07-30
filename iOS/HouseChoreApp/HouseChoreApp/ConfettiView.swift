import SwiftUI

struct ConfettiView: View {
    @Binding var isVisible: Bool
    let colors: [Color] = [.red, .blue, .green, .yellow, .orange, .purple, .pink, .cyan, .mint, .indigo]
    
    var body: some View {
        ZStack {
            // Animated confetti pieces
            if isVisible {
                ForEach(0..<50, id: \.self) { index in
                    ConfettiPiece(
                        color: colors[index % colors.count],
                        delay: Double(index) * 0.05,
                        index: index
                    )
                }
            }
        }
        .onChange(of: isVisible) { newValue in
            if newValue {
                print("🎊 ConfettiView isVisible changed to true!")
                
                // Auto-reset after animation completes (3 seconds total)
                DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                    isVisible = false
                    print("🎊 ConfettiView auto-reset to false")
                }
            }
        }
    }
}

struct ConfettiPiece: View {
    let color: Color
    let delay: Double
    let index: Int
    
    @State private var isAnimating = false
    @State private var opacity: Double = 0
    
    var body: some View {
        Rectangle()
            .fill(color)
            .frame(width: 12, height: 18)
            .opacity(opacity)
            .offset(y: isAnimating ? UIScreen.main.bounds.height + 100 : -300)
            .offset(x: CGFloat.random(in: -UIScreen.main.bounds.width/2...UIScreen.main.bounds.width/2))
            .onAppear {
                print("🎊 ConfettiPiece \(color) appeared with index \(index)")
                
                DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                    print("🎊 Starting confetti animation for \(color)")
                    withAnimation(.easeIn(duration: 2.5)) {
                        isAnimating = true
                        opacity = 1.0
                    }
                    
                    // Fade out after animation
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                        withAnimation(.easeOut(duration: 0.5)) {
                            opacity = 0
                        }
                    }
                }
            }
    }
} 