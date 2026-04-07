import SwiftUI

struct AccessibilityModeIndicator: View {
    let mode: AccessibilityMode

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: mode.icon)
                .font(.title3)
            Text(mode.rawValue)
                .font(.subheadline)
                .fontWeight(.medium)
        }
        .foregroundColor(.white)
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(modeColor.opacity(0.8))
        .clipShape(Capsule())
        .accessibilityLabel("Current mode: \(mode.rawValue)")
    }

    private var modeColor: Color {
        switch mode {
        case .audio: return AccessibleColors.primary
        case .visual: return AccessibleColors.secondary
        case .haptic: return AccessibleColors.tertiary
        case .combined: return AccessibleColors.quaternary
        }
    }
}

struct ModeSwitcherButton: View {
    @EnvironmentObject var accessibilityManager: AccessibilityManager
    @State private var showingModeSheet = false

    var body: some View {
        Button(action: { showingModeSheet = true }) {
            Image(systemName: "switch.2")
                .font(.title)
                .foregroundColor(.white)
                .frame(width: 60, height: 60)
                .background(Color.black.opacity(0.5))
                .clipShape(Circle())
        }
        .accessibilityLabel("Switch accessibility mode")
        .sheet(isPresented: $showingModeSheet) {
            ModeSelectorSheet()
        }
    }
}

struct ModeSelectorSheet: View {
    @EnvironmentObject var accessibilityManager: AccessibilityManager
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            List {
                ForEach(AccessibilityMode.allCases) { mode in
                    Button(action: {
                        accessibilityManager.setMode(mode)
                        dismiss()
                    }) {
                        HStack {
                            Image(systemName: mode.icon)
                                .font(.title2)
                                .foregroundColor(AccessibleColors.primary)
                                .frame(width: 40)

                            VStack(alignment: .leading) {
                                Text(mode.rawValue)
                                    .font(.headline)
                                    .foregroundColor(.primary)
                                Text(mode.description)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }

                            Spacer()

                            if accessibilityManager.preferences.primaryMode == mode {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(AccessibleColors.success)
                            }
                        }
                        .padding(.vertical, 8)
                    }
                }
            }
            .navigationTitle("Select Mode")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
        .presentationDetents([.medium])
    }
}

struct TrendIconView: View {
    @EnvironmentObject var accessibilityManager: AccessibilityManager
    let trend: TrendType
    let size: CGFloat

    init(trend: TrendType, size: CGFloat = 24) {
        self.trend = trend
        self.size = size
    }

    var body: some View {
        Text(trend.icon)
            .font(.system(size: size, weight: .bold))
            .foregroundColor(AccessibleColors.trendColor(for: trend, mode: accessibilityManager.preferences.visualSettings.colorBlindMode))
            .accessibilityLabel(trend.description)
    }
}

struct ConfidenceIndicator: View {
    @EnvironmentObject var accessibilityManager: AccessibilityManager
    let confidence: Double

    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: confidenceIcon)
                .foregroundColor(confidenceColor)
            Text("\(Int(confidence * 100))% Confidence")
                .font(.caption)
                .foregroundColor(confidenceColor)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(confidenceColor.opacity(0.2))
        .clipShape(Capsule())
    }

    private var confidenceIcon: String {
        switch confidence {
        case 0.8...: return "checkmark.shield.fill"
        case 0.5..<0.8: return "exclamationmark.shield.fill"
        default: return "xmark.shield.fill"
        }
    }

    private var confidenceColor: Color {
        let mode = accessibilityManager.preferences.visualSettings.colorBlindMode
        switch confidence {
        case 0.8...: return AccessibleColors.trendColor(for: .increasing, mode: mode)
        case 0.5..<0.8: return AccessibleColors.trendColor(for: .fluctuating, mode: mode)
        default: return AccessibleColors.trendColor(for: .decreasing, mode: mode)
        }
    }
}

#Preview {
    VStack(spacing: 20) {
        AccessibilityModeIndicator(mode: .audio)
        AccessibilityModeIndicator(mode: .visual)
        AccessibilityModeIndicator(mode: .haptic)

        HStack {
            TrendIconView(trend: .increasing)
            TrendIconView(trend: .decreasing)
            TrendIconView(trend: .constant)
        }

        ConfidenceIndicator(confidence: 0.85)
        ConfidenceIndicator(confidence: 0.6)
        ConfidenceIndicator(confidence: 0.3)
    }
    .environmentObject(AccessibilityManager())
}

