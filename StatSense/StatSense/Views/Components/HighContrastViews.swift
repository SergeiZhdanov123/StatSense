import SwiftUI

struct HighContrastResultCard: View {
    @EnvironmentObject var accessibilityManager: AccessibilityManager
    let result: InterpretationResult

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {

            HStack {
                TrendIconView(trend: result.overallTrend, size: 64)

                VStack(alignment: .leading) {
                    Text(result.graphType.rawValue)
                        .font(.title2.bold())
                    Text(result.overallTrend.description)
                        .font(.headline)
                }
            }

            Divider()
                .background(AccessibleColors.highContrastAccent)

            ForEach(result.explanations.prefix(5)) { step in
                HighContrastStepView(step: step)
            }

            ConfidenceBarView(confidence: result.confidence)
        }
        .padding()
        .background(accessibilityManager.preferences.visualSettings.useHighContrast
                    ? AccessibleColors.highContrastBackground
                    : Color(.systemBackground))
        .foregroundColor(accessibilityManager.preferences.visualSettings.useHighContrast
                         ? AccessibleColors.highContrastText
                         : .primary)
        .cornerRadius(16)
    }
}

struct HighContrastStepView: View {
    let step: ExplanationStep

    var body: some View {
        HStack(alignment: .top, spacing: 16) {

            if let trend = step.trend {
                TrendIconView(trend: trend, size: 32)
            } else {
                Image(systemName: "info.circle.fill")
                    .font(.title2)
                    .foregroundColor(AccessibleColors.primary)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(step.title)
                    .font(.headline.weight(.semibold))
                Text(step.description)
                    .font(.body)
                    .opacity(0.9)
            }
        }
        .padding(.vertical, 8)
    }
}

struct ConfidenceBarView: View {
    @EnvironmentObject var accessibilityManager: AccessibilityManager
    let confidence: Double

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Confidence")
                    .font(.headline)
                Spacer()
                Text("\(Int(confidence * 100))%")
                    .font(.headline)
                    .foregroundColor(confidenceColor)
            }

            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Rectangle()
                        .fill(Color.gray.opacity(0.3))
                        .frame(height: 12)
                        .cornerRadius(6)

                    Rectangle()
                        .fill(confidenceColor)
                        .frame(width: geometry.size.width * confidence, height: 12)
                        .cornerRadius(6)
                }
            }
            .frame(height: 12)
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }

    private var mode: VisualSettings.ColorBlindMode {
        accessibilityManager.preferences.visualSettings.colorBlindMode
    }

    private var confidenceColor: Color {
        switch confidence {
        case 0.8...: return AccessibleColors.success(mode: mode)
        case 0.5..<0.8: return AccessibleColors.warning(mode: mode)
        default: return AccessibleColors.error(mode: mode)
        }
    }
}

struct LargeAccessibleButtonStyle: ButtonStyle {
    let backgroundColor: Color
    let foregroundColor: Color

    init(backgroundColor: Color = AccessibleColors.primary, foregroundColor: Color = .white) {
        self.backgroundColor = backgroundColor
        self.foregroundColor = foregroundColor
    }

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.title2.weight(.semibold))
            .foregroundColor(foregroundColor)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 20)
            .background(backgroundColor.opacity(configuration.isPressed ? 0.8 : 1.0))
            .cornerRadius(16)
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

struct AccessibleIconButton: View {
    let icon: String
    let label: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: 32))
                Text(label)
                    .font(.caption)
                    .fontWeight(.medium)
            }
            .frame(width: 80, height: 80)
            .background(AccessibleColors.primary.opacity(0.15))
            .foregroundColor(AccessibleColors.primary)
            .cornerRadius(16)
        }
        .accessibilityLabel(label)
    }
}

#Preview {
    VStack {
        ConfidenceBarView(confidence: 0.85)
        ConfidenceBarView(confidence: 0.6)
        ConfidenceBarView(confidence: 0.3)
    }
    .padding()
    .environmentObject(AccessibilityManager())
}

