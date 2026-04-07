import SwiftUI

struct PrimaryActionButton: View {
    let title: String
    let icon: String
    let action: () -> Void
    var isLoading: Bool = false

    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                if isLoading {
                    ProgressView()
                        .tint(.white)
                } else {
                    Image(systemName: icon)
                        .font(.title2)
                }
                Text(title)
                    .font(.title3.weight(.semibold))
            }
            .frame(maxWidth: .infinity)
            .frame(height: 60)
            .background(AccessibleColors.primary)
            .foregroundColor(.white)
            .cornerRadius(16)
        }
        .disabled(isLoading)
        .accessibilityLabel(title)
    }
}

struct SecondaryActionButton: View {
    let title: String
    let icon: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.title3)
                Text(title)
                    .font(.body.weight(.medium))
            }
            .frame(maxWidth: .infinity)
            .frame(height: 50)
            .background(AccessibleColors.primary.opacity(0.15))
            .foregroundColor(AccessibleColors.primary)
            .cornerRadius(12)
        }
        .accessibilityLabel(title)
    }
}

struct CircularActionButton: View {
    let icon: String
    let size: CGFloat
    let backgroundColor: Color
    let foregroundColor: Color
    let action: () -> Void

    init(
        icon: String,
        size: CGFloat = 60,
        backgroundColor: Color = .black.opacity(0.5),
        foregroundColor: Color = .white,
        action: @escaping () -> Void
    ) {
        self.icon = icon
        self.size = size
        self.backgroundColor = backgroundColor
        self.foregroundColor = foregroundColor
        self.action = action
    }

    var body: some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.system(size: size * 0.4))
                .foregroundColor(foregroundColor)
                .frame(width: size, height: size)
                .background(backgroundColor)
                .clipShape(Circle())
        }
    }
}

struct CaptureButton: View {
    let action: () -> Void
    var isAnalyzing: Bool = false

    var body: some View {
        Button(action: action) {
            ZStack {
                Circle()
                    .strokeBorder(Color.white, lineWidth: 4)
                    .frame(width: 80, height: 80)

                if isAnalyzing {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .scaleEffect(1.5)
                } else {
                    Circle()
                        .fill(AccessibleColors.primary)
                        .frame(width: 65, height: 65)

                    Image(systemName: "camera.fill")
                        .font(.title)
                        .foregroundColor(.white)
                }
            }
        }
        .disabled(isAnalyzing)
        .accessibilityLabel(isAnalyzing ? "Analyzing graph" : "Capture and analyze graph")
    }
}

struct NavigationControlButton: View {
    let direction: Direction
    let isEnabled: Bool
    let action: () -> Void

    enum Direction {
        case previous
        case next

        var icon: String {
            switch self {
            case .previous: return "chevron.left.circle.fill"
            case .next: return "chevron.right.circle.fill"
            }
        }

        var label: String {
            switch self {
            case .previous: return "Previous"
            case .next: return "Next"
            }
        }
    }

    var body: some View {
        Button(action: action) {
            Image(systemName: direction.icon)
                .font(.system(size: 50))
                .foregroundColor(isEnabled ? AccessibleColors.primary : .gray.opacity(0.5))
        }
        .disabled(!isEnabled)
        .accessibilityLabel(direction.label)
        .accessibilityHint(isEnabled ? "Tap to go to \(direction.label.lowercased()) item" : "No \(direction.label.lowercased()) item available")
    }
}

struct AudioControlBar: View {
    @EnvironmentObject var accessibilityManager: AccessibilityManager
    let text: String

    var body: some View {
        HStack(spacing: 20) {

            Button(action: togglePlayback) {
                Image(systemName: accessibilityManager.isSpeaking ? "pause.circle.fill" : "play.circle.fill")
                    .font(.system(size: 44))
                    .foregroundColor(AccessibleColors.primary)
            }
            .accessibilityLabel(accessibilityManager.isSpeaking ? "Pause" : "Play")

            Button(action: { accessibilityManager.speak(text, priority: true) }) {
                Image(systemName: "arrow.counterclockwise.circle.fill")
                    .font(.system(size: 36))
                    .foregroundColor(AccessibleColors.secondary)
            }
            .accessibilityLabel("Repeat")

            Text(accessibilityManager.preferences.speechSettings.rateDescription)
                .font(.caption)
                .foregroundColor(.secondary)
                .frame(width: 60)
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }

    private func togglePlayback() {
        if accessibilityManager.isSpeaking {
            accessibilityManager.pauseSpeaking()
        } else {
            accessibilityManager.speak(text, priority: true)
        }
    }
}

#Preview {
    VStack(spacing: 20) {
        PrimaryActionButton(title: "Analyze Graph", icon: "camera.fill") {}
        SecondaryActionButton(title: "View History", icon: "clock") {}

        HStack(spacing: 40) {
            CircularActionButton(icon: "photo") {}
            CaptureButton {}
            CircularActionButton(icon: "switch.2") {}
        }

        HStack(spacing: 40) {
            NavigationControlButton(direction: .previous, isEnabled: true) {}
            NavigationControlButton(direction: .next, isEnabled: false) {}
        }
    }
    .padding()
}

