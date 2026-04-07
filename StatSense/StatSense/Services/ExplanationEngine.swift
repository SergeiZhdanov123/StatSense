import Foundation
import CoreGraphics

class ExplanationEngine {

    func generateExplanations(
        graphType: GraphType,
        xAxis: AxisInfo?,
        yAxis: AxisInfo?,
        dataLines: [DataLine],
        intersections: [IntersectionPoint],
        trend: TrendType
    ) -> ([ExplanationStep], Double, [String]) {

        var steps: [ExplanationStep] = []
        var warnings: [String] = []
        var confidenceFactors: [Double] = []

        steps.append(ExplanationStep(
            order: 1,
            title: "Graph Type",
            description: "This is a \(graphType.rawValue).",
            region: nil,
            trend: nil,
            hapticPattern: .steady
        ))
        confidenceFactors.append(graphType != .unknown ? 0.9 : 0.4)

        if let xAxis = xAxis {
            steps.append(ExplanationStep(
                order: 2,
                title: "Horizontal Axis",
                description: xAxis.description,
                region: nil,
                trend: nil,
                hapticPattern: .steady
            ))
            confidenceFactors.append(0.8)
        } else {
            warnings.append("Could not detect X-axis labels")
            confidenceFactors.append(0.3)
        }

        if let yAxis = yAxis {
            steps.append(ExplanationStep(
                order: 3,
                title: "Vertical Axis",
                description: yAxis.description,
                region: nil,
                trend: nil,
                hapticPattern: .steady
            ))
            confidenceFactors.append(0.8)
        } else {
            warnings.append("Could not detect Y-axis labels")
            confidenceFactors.append(0.3)
        }

        for (index, line) in dataLines.enumerated() {
            let haptic: ExplanationStep.HapticPattern = {
                switch line.trend {
                case .increasing, .exponential: return .rising
                case .decreasing, .logarithmic: return .falling
                default: return .steady
                }
            }()

            steps.append(ExplanationStep(
                order: 4 + index,
                title: line.label ?? "Data Line \(index + 1)",
                description: line.description,
                region: nil,
                trend: line.trend,
                hapticPattern: haptic
            ))
            confidenceFactors.append(line.points.count >= 3 ? 0.85 : 0.5)
        }

        for (index, intersection) in intersections.enumerated() {
            steps.append(ExplanationStep(
                order: 100 + index,
                title: "Intersection \(index + 1)",
                description: intersection.description,
                region: nil,
                trend: nil,
                hapticPattern: .intersection
            ))
            confidenceFactors.append(0.75)
        }

        let trendDescription = generateTrendDescription(trend, dataLines: dataLines)
        let trendHaptic: ExplanationStep.HapticPattern = {
            switch trend {
            case .increasing: return .rising
            case .decreasing: return .falling
            default: return .steady
            }
        }()

        steps.append(ExplanationStep(
            order: 200,
            title: "Overall Pattern",
            description: trendDescription,
            region: nil,
            trend: trend,
            hapticPattern: trendHaptic
        ))

        let insights = generateInsights(graphType: graphType, dataLines: dataLines, intersections: intersections)
        if !insights.isEmpty {
            steps.append(ExplanationStep(
                order: 300,
                title: "Key Insights",
                description: insights,
                region: nil,
                trend: nil,
                hapticPattern: .success
            ))
        }

        if dataLines.count > 5 || intersections.count > 3 {
            warnings.append("This graph is complex. Some details may not be fully captured.")
        }

        let confidence = confidenceFactors.isEmpty ? 0.5 : confidenceFactors.reduce(0, +) / Double(confidenceFactors.count)

        if confidence < 0.5 {
            warnings.append("Interpretation confidence is low. Please verify results.")
        }

        return (steps.sorted { $0.order < $1.order }, confidence, warnings)
    }

    private func generateTrendDescription(_ trend: TrendType, dataLines: [DataLine]) -> String {
        var description = "The overall trend is \(trend.description.lowercased()). "

        switch trend {
        case .increasing:
            description += "As you move from left to right, values generally increase."
        case .decreasing:
            description += "As you move from left to right, values generally decrease."
        case .constant:
            description += "Values remain relatively stable across the graph."
        case .fluctuating:
            description += "Values vary significantly, moving both up and down."
        case .exponential:
            description += "Values grow at an accelerating rate."
        case .logarithmic:
            description += "The rate of change slows down over time."
        }

        return description
    }

    private func generateInsights(graphType: GraphType, dataLines: [DataLine], intersections: [IntersectionPoint]) -> String {
        var insights: [String] = []

        if dataLines.count == 1 {
            insights.append("The graph shows a single data series.")
        } else if dataLines.count > 1 {
            insights.append("The graph compares \(dataLines.count) different data series.")
        }

        if !intersections.isEmpty {
            insights.append("There are \(intersections.count) point(s) where lines cross, indicating equal values.")
        }

        let steepChanges = dataLines.flatMap { $0.segments }.filter {
            $0.slope == .steepPositive || $0.slope == .steepNegative
        }
        if !steepChanges.isEmpty {
            insights.append("There are \(steepChanges.count) segment(s) with rapid change.")
        }

        return insights.joined(separator: " ")
    }
}

