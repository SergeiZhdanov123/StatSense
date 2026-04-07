import SwiftUI

struct OnboardingView: View {
    @EnvironmentObject var accessibilityManager: AccessibilityManager
    @Binding var isPresented: Bool
    @State private var currentPage = 0

    private let pages: [OnboardingPage] = [
        OnboardingPage(
            icon: "chart.line.uptrend.xyaxis.circle.fill",
            title: "Welcome to StatSense",
            description: "Making graphs and charts accessible for everyone through audio, visual, and haptic feedback.",
            color: AccessibleColors.primary
        ),
        OnboardingPage(
            icon: "camera.fill",
            title: "Point & Capture",
            description: "Simply point your camera at any graph, chart, or diagram. StatSense will analyze it automatically.",
            color: AccessibleColors.secondary
        ),
        OnboardingPage(
            icon: "speaker.wave.3.fill",
            title: "Audio Mode",
            description: "Hear detailed explanations of graphs with adjustable speech rate. Perfect for blind users.",
            color: AccessibleColors.primary
        ),
        OnboardingPage(
            icon: "eye.fill",
            title: "Visual Mode",
            description: "Large, high-contrast text with trend icons. Designed for deaf users who need visual information.",
            color: AccessibleColors.tertiary
        ),
        OnboardingPage(
            icon: "hand.tap.fill",
            title: "Haptic Mode",
            description: "Feel the trends through vibration patterns. Works even with screen off or in your pocket.",
            color: AccessibleColors.quaternary
        )
    ]

    var body: some View {
        VStack(spacing: 0) {

            TabView(selection: $currentPage) {
                ForEach(pages.indices, id: \.self) { index in
                    OnboardingPageView(page: pages[index])
                        .tag(index)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))

            HStack(spacing: 8) {
                ForEach(pages.indices, id: \.self) { index in
                    Circle()
                        .fill(index == currentPage ? AccessibleColors.primary : Color.gray.opacity(0.3))
                        .frame(width: 10, height: 10)
                        .scaleEffect(index == currentPage ? 1.2 : 1.0)
                        .animation(.spring, value: currentPage)
                }
            }
            .padding(.vertical, 20)

            HStack(spacing: 20) {
                if currentPage > 0 {
                    Button("Previous") {
                        withAnimation {
                            currentPage -= 1
                        }
                    }
                    .buttonStyle(.bordered)
                }

                Spacer()

                if currentPage < pages.count - 1 {
                    Button("Next") {
                        withAnimation {
                            currentPage += 1
                        }
                    }
                    .buttonStyle(.borderedProminent)
                } else {
                    Button("Get Started") {
                        accessibilityManager.preferences.showOnboarding = false
                        isPresented = false
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(AccessibleColors.success)
                }
            }
            .padding(.horizontal, 30)
            .padding(.bottom, 40)
        }
        .background(Color(.systemBackground))
        .onAppear {
            if accessibilityManager.preferences.speechSettings.autoPlay {
                accessibilityManager.speak(pages[0].title + ". " + pages[0].description)
            }
        }
        .onChange(of: currentPage) { _, newPage in
            if accessibilityManager.preferences.speechSettings.autoPlay {
                accessibilityManager.speak(pages[newPage].title + ". " + pages[newPage].description, priority: true)
            }
        }
    }
}

struct OnboardingPage {
    let icon: String
    let title: String
    let description: String
    let color: Color
}

struct OnboardingPageView: View {
    let page: OnboardingPage

    var body: some View {
        VStack(spacing: 30) {
            Spacer()

            Image(systemName: page.icon)
                .font(.system(size: 100))
                .foregroundStyle(
                    LinearGradient(
                        colors: [page.color, page.color.opacity(0.6)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .accessibilityHidden(true)

            Text(page.title)
                .font(.title)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)

            Text(page.description)
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)

            Spacer()
            Spacer()
        }
        .padding()
    }
}

#Preview {
    OnboardingView(isPresented: .constant(true))
        .environmentObject(AccessibilityManager())
}

