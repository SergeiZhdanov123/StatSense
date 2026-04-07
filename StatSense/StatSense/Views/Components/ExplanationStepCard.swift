import SwiftUI

struct ExplanationStepCard: View {
    @EnvironmentObject var accessibilityManager: AccessibilityManager
    let step: ExplanationStep

    var body: some View {
        Button(action: handleTap) {
            HStack(alignment: .top, spacing: 12) {
                Text("\(step.order)")
                    .font(.caption.bold())
                    .foregroundColor(.white)
                    .frame(width: 24, height: 24)
                    .background(AccessibleColors.primary)
                    .clipShape(Circle())

                VStack(alignment: .leading, spacing: 6) {
                    HStack {
                        Text(step.title)
                            .font(.headline.bold())
                            .foregroundColor(.primary)

                        if let trend = step.trend {
                            TrendIconView(trend: trend, size: 24)
                        }
                    }

                    Text(step.description)
                        .font(.body)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.leading)
                }

                Spacer()

                if step.hapticPattern != .none {
                    Image(systemName: "hand.tap.fill")
                        .foregroundColor(AccessibleColors.tertiary)
                        .font(.caption)
                }
            }
            .padding()
            .background(Color(.systemBackground))
            .cornerRadius(12)
            .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
        }
        .buttonStyle(.plain)
        .accessibilityLabel("\(step.title). \(step.description)")
        .accessibilityHint("Double tap to hear and feel this step")
    }

    private func handleTap() {

        accessibilityManager.speak(step.description, priority: true)

        accessibilityManager.playHaptic(step.hapticPattern)
    }
}

struct WarningsCard: View {
    @EnvironmentObject var accessibilityManager: AccessibilityManager
    let warnings: [String]

    private var fontSize: CGFloat {
        accessibilityManager.preferences.visualSettings.fontSize
    }

    private var mode: VisualSettings.ColorBlindMode {
        accessibilityManager.preferences.visualSettings.colorBlindMode
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label("Warnings", systemImage: "exclamationmark.triangle.fill")
                .font(.system(size: fontSize * 0.7, weight: .bold))
                .foregroundColor(AccessibleColors.warning(mode: mode))

            ForEach(warnings, id: \.self) { warning in
                Text("• \(warning)")
                    .font(.system(size: fontSize * 0.6))
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(AccessibleColors.warning(mode: mode).opacity(0.1))
        .cornerRadius(12)
    }
}

struct StepByStepExplorer: View {
    @EnvironmentObject var accessibilityManager: AccessibilityManager
    let steps: [ExplanationStep]
    @Binding var currentIndex: Int

    var currentStep: ExplanationStep? {
        guard steps.indices.contains(currentIndex) else { return nil }
        return steps[currentIndex]
    }

    var body: some View {
        VStack(spacing: 20) {

            HStack {
                ForEach(0..<steps.count, id: \.self) { index in
                    Circle()
                        .fill(index == currentIndex ? AccessibleColors.primary : Color.gray.opacity(0.3))
                        .frame(width: 10, height: 10)
                }
            }

            if let step = currentStep {
                VStack(spacing: 16) {
                    Text(step.title)
                        .font(.title2)
                        .fontWeight(.bold)

                    if let trend = step.trend {
                        TrendIconView(trend: trend, size: 48)
                    }

                    Text(step.description)
                        .font(.title3)
                        .multilineTextAlignment(.center)
                        .foregroundColor(.secondary)
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color(.systemGray6))
                .cornerRadius(16)
            }

            HStack(spacing: 40) {

                Button(action: previousStep) {
                    Image(systemName: "chevron.left.circle.fill")
                        .font(.system(size: 50))
                        .foregroundColor(currentIndex > 0 ? AccessibleColors.primary : .gray)
                }
                .disabled(currentIndex == 0)
                .accessibilityLabel("Previous step")

                Button(action: repeatStep) {
                    Image(systemName: "arrow.counterclockwise.circle.fill")
                        .font(.system(size: 40))
                        .foregroundColor(AccessibleColors.secondary)
                }
                .accessibilityLabel("Repeat current step")

                Button(action: nextStep) {
                    Image(systemName: "chevron.right.circle.fill")
                        .font(.system(size: 50))
                        .foregroundColor(currentIndex < steps.count - 1 ? AccessibleColors.primary : .gray)
                }
                .disabled(currentIndex >= steps.count - 1)
                .accessibilityLabel("Next step")
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(radius: 10)
        .onAppear {
            announceStep()
        }
    }

    private func previousStep() {
        guard currentIndex > 0 else { return }
        currentIndex -= 1
        announceStep()
    }

    private func nextStep() {
        guard currentIndex < steps.count - 1 else { return }
        currentIndex += 1
        announceStep()
    }

    private func repeatStep() {
        announceStep()
    }

    private func announceStep() {
        guard let step = currentStep else { return }
        accessibilityManager.speak("Step \(currentIndex + 1) of \(steps.count). \(step.title). \(step.description)", priority: true)
        accessibilityManager.playHaptic(step.hapticPattern)
    }
}

