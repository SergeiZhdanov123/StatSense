import SwiftUI

struct GraphInteractionView: View {
    @EnvironmentObject var accessibilityManager: AccessibilityManager
    @Environment(\.dismiss) private var dismiss

    let result: InterpretationResult
    @State private var selectedRegion: GraphRegion?
    @State private var regions: [GraphRegion] = []

    var body: some View {
        NavigationStack {
            GeometryReader { geometry in
                ZStack {

                    if let image = result.capturedImage {
                        Image(uiImage: image)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                    }

                    ForEach(regions) { region in
                        RegionOverlay(
                            region: region,
                            isSelected: selectedRegion?.id == region.id,
                            imageSize: geometry.size
                        )
                        .onTapGesture {
                            selectRegion(region)
                        }
                    }
                }
            }
            .navigationTitle("Explore Graph")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") { dismiss() }
                }
            }
            .safeAreaInset(edge: .bottom) {
                if let region = selectedRegion {
                    RegionInfoPanel(region: region)
                } else {
                    instructionsPanel
                }
            }
            .onAppear {
                generateRegions()
                accessibilityManager.speak("Graph exploration mode. Tap different areas to learn about each part.", priority: true)
            }
        }
    }

    private var instructionsPanel: some View {
        VStack(spacing: 12) {
            Image(systemName: "hand.tap.fill")
                .font(.title)
                .foregroundColor(AccessibleColors.primary)

            Text("Tap any area of the graph to explore")
                .font(.headline)

            Text("Each tap will describe that section with audio and haptic feedback")
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color(.systemBackground))
        .cornerRadius(16, corners: [.topLeft, .topRight])
        .shadow(radius: 10)
    }

    private func generateRegions() {
        var newRegions: [GraphRegion] = []

        if let xAxis = result.xAxis {
            newRegions.append(GraphRegion(
                name: "X-Axis",
                bounds: CGRect(x: 0.1, y: 0.85, width: 0.8, height: 0.15),
                type: .xAxis,
                explanation: xAxis.description,
                hapticPattern: .steady
            ))
        }

        if let yAxis = result.yAxis {
            newRegions.append(GraphRegion(
                name: "Y-Axis",
                bounds: CGRect(x: 0, y: 0.1, width: 0.15, height: 0.75),
                type: .yAxis,
                explanation: yAxis.description,
                hapticPattern: .steady
            ))
        }

        for (index, line) in result.dataLines.enumerated() {
            let yOffset = 0.2 + Double(index) * 0.15
            let haptic: ExplanationStep.HapticPattern = {
                switch line.trend {
                case .increasing: return .rising
                case .decreasing: return .falling
                default: return .steady
                }
            }()

            newRegions.append(GraphRegion(
                name: line.label ?? "Data Line \(index + 1)",
                bounds: CGRect(x: 0.15, y: yOffset, width: 0.7, height: 0.2),
                type: .dataLine,
                explanation: line.description,
                hapticPattern: haptic
            ))
        }

        for (index, intersection) in result.intersections.enumerated() {
            newRegions.append(GraphRegion(
                name: "Intersection \(index + 1)",
                bounds: CGRect(x: 0.4, y: 0.4, width: 0.2, height: 0.2),
                type: .intersection,
                explanation: intersection.description,
                hapticPattern: .intersection
            ))
        }

        regions = newRegions
    }

    private func selectRegion(_ region: GraphRegion) {
        selectedRegion = region
        accessibilityManager.speak(region.explanation, priority: true)
        accessibilityManager.playHaptic(region.hapticPattern)
    }
}

struct RegionOverlay: View {
    let region: GraphRegion
    let isSelected: Bool
    let imageSize: CGSize

    var body: some View {
        Rectangle()
            .fill(isSelected ? AccessibleColors.primary.opacity(0.3) : Color.clear)
            .stroke(isSelected ? AccessibleColors.primary : Color.white.opacity(0.5), lineWidth: isSelected ? 3 : 1)
            .frame(
                width: region.bounds.width * imageSize.width,
                height: region.bounds.height * imageSize.height
            )
            .position(
                x: (region.bounds.minX + region.bounds.width / 2) * imageSize.width,
                y: (region.bounds.minY + region.bounds.height / 2) * imageSize.height
            )
            .accessibilityLabel(region.name)
            .accessibilityHint("Double tap to hear description")
    }
}

struct RegionInfoPanel: View {
    @EnvironmentObject var accessibilityManager: AccessibilityManager
    let region: GraphRegion

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: iconForType(region.type))
                    .font(.title2)
                    .foregroundColor(AccessibleColors.primary)

                Text(region.name)
                    .font(.headline)

                Spacer()

                Button(action: { accessibilityManager.speak(region.explanation, priority: true) }) {
                    Image(systemName: "speaker.wave.2.fill")
                        .foregroundColor(AccessibleColors.primary)
                }
                .accessibilityLabel("Read aloud")
            }

            Text(region.explanation)
                .font(.body)
                .foregroundColor(.secondary)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color(.systemBackground))
        .cornerRadius(16, corners: [.topLeft, .topRight])
        .shadow(radius: 10)
    }

    private func iconForType(_ type: GraphRegion.RegionType) -> String {
        switch type {
        case .xAxis: return "arrow.left.and.right"
        case .yAxis: return "arrow.up.and.down"
        case .title: return "textformat"
        case .legend: return "list.bullet"
        case .dataLine: return "chart.line.uptrend.xyaxis"
        case .dataPoint: return "circle.fill"
        case .intersection: return "point.topleft.down.curvedto.point.filled.bottomright.up"
        case .gridArea: return "grid"
        }
    }
}

extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}

struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}

