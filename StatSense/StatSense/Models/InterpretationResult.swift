import Foundation
import UIKit

struct InterpretationResult: Identifiable, Equatable, Codable {
    var id = UUID()
    var graphType: GraphType
    var title: String
    var xAxis: AxisInfo?
    var yAxis: AxisInfo?
    var dataLines: [DataLine]
    var intersections: [IntersectionPoint]
    var overallTrend: TrendType
    var confidence: Double
    var warnings: [String]
    var explanations: [ExplanationStep]
    var capturedImage: UIImage?
    var timestamp: Date

    enum CodingKeys: String, CodingKey {
        case id, graphType, title, xAxis, yAxis, dataLines, intersections, overallTrend, confidence, warnings, explanations, timestamp
    }

    init(id: UUID = UUID(), graphType: GraphType, title: String, xAxis: AxisInfo? = nil, yAxis: AxisInfo? = nil, dataLines: [DataLine], intersections: [IntersectionPoint], overallTrend: TrendType, confidence: Double, warnings: [String], explanations: [ExplanationStep], capturedImage: UIImage? = nil, timestamp: Date) {
        self.id = id
        self.graphType = graphType
        self.title = title
        self.xAxis = xAxis
        self.yAxis = yAxis
        self.dataLines = dataLines
        self.intersections = intersections
        self.overallTrend = overallTrend
        self.confidence = confidence
        self.warnings = warnings
        self.explanations = explanations
        self.capturedImage = capturedImage
        self.timestamp = timestamp
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decodeIfPresent(UUID.self, forKey: .id) ?? UUID()
        graphType = try container.decode(GraphType.self, forKey: .graphType)
        title = try container.decode(String.self, forKey: .title)
        xAxis = try container.decodeIfPresent(AxisInfo.self, forKey: .xAxis)
        yAxis = try container.decodeIfPresent(AxisInfo.self, forKey: .yAxis)
        dataLines = try container.decode([DataLine].self, forKey: .dataLines)
        intersections = try container.decode([IntersectionPoint].self, forKey: .intersections)
        overallTrend = try container.decode(TrendType.self, forKey: .overallTrend)
        confidence = try container.decode(Double.self, forKey: .confidence)
        warnings = try container.decode([String].self, forKey: .warnings)
        explanations = try container.decode([ExplanationStep].self, forKey: .explanations)
        timestamp = try container.decodeIfPresent(Date.self, forKey: .timestamp) ?? Date()
        capturedImage = nil
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(graphType, forKey: .graphType)
        try container.encode(title, forKey: .title)
        try container.encodeIfPresent(xAxis, forKey: .xAxis)
        try container.encodeIfPresent(yAxis, forKey: .yAxis)
        try container.encode(dataLines, forKey: .dataLines)
        try container.encode(intersections, forKey: .intersections)
        try container.encode(overallTrend, forKey: .overallTrend)
        try container.encode(confidence, forKey: .confidence)
        try container.encode(warnings, forKey: .warnings)
        try container.encode(explanations, forKey: .explanations)
        try container.encode(timestamp, forKey: .timestamp)
    }

    static func == (lhs: InterpretationResult, rhs: InterpretationResult) -> Bool {
        lhs.id == rhs.id
    }

    var isReliable: Bool { confidence >= 0.7 }
    var isLowConfidence: Bool { confidence < 0.5 }

    var confidenceDescription: String {
        switch confidence {
        case 0.9...: return "Very High Confidence"
        case 0.7..<0.9: return "High Confidence"
        case 0.5..<0.7: return "Moderate Confidence"
        case 0.3..<0.5: return "Low Confidence"
        default: return "Very Low Confidence"
        }
    }

    var summary: String {
        var parts: [String] = []
        parts.append("This is a \(graphType.rawValue).")

        if let xAxis = xAxis {
            parts.append(xAxis.description + ".")
        }
        if let yAxis = yAxis {
            parts.append(yAxis.description + ".")
        }

        parts.append("The overall trend is \(overallTrend.description.lowercased()).")

        if !intersections.isEmpty {
            parts.append("There are \(intersections.count) intersection point(s).")
        }

        return parts.joined(separator: " ")
    }
}

struct DataLine: Identifiable, Equatable, Codable {
    var id: UUID
    var label: String?
    var color: String?
    var points: [DataPoint]
    var segments: [LineSegment]
    var trend: TrendType
    var averageSlope: SlopeClassification

    enum CodingKeys: String, CodingKey {
        case id, label, color, points, segments, trend, averageSlope
    }

    init(id: UUID = UUID(), label: String? = nil, color: String? = nil, points: [DataPoint] = [], segments: [LineSegment] = [], trend: TrendType = .constant, averageSlope: SlopeClassification = .flat) {
        self.id = id
        self.label = label
        self.color = color
        self.points = points
        self.segments = segments
        self.trend = trend
        self.averageSlope = averageSlope
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decodeIfPresent(UUID.self, forKey: .id) ?? UUID()
        label = try container.decodeIfPresent(String.self, forKey: .label)
        color = try container.decodeIfPresent(String.self, forKey: .color)
        points = try container.decode([DataPoint].self, forKey: .points)
        segments = try container.decode([LineSegment].self, forKey: .segments)
        trend = try container.decode(TrendType.self, forKey: .trend)
        averageSlope = try container.decode(SlopeClassification.self, forKey: .averageSlope)
    }

    var description: String {
        var desc = label ?? "A line"
        desc += " shows \(trend.description.lowercased())"
        desc += " with \(averageSlope.description.lowercased())"
        return desc
    }
}

struct ExplanationStep: Identifiable, Equatable, Codable {
    var id: UUID
    var order: Int
    var title: String
    var description: String
    var region: CGRect?
    var trend: TrendType?
    var hapticPattern: HapticPattern

    enum CodingKeys: String, CodingKey {
        case id, order, title, description, region, trend, hapticPattern
    }

    init(id: UUID = UUID(), order: Int, title: String, description: String, region: CGRect? = nil, trend: TrendType? = nil, hapticPattern: HapticPattern = .none) {
        self.id = id
        self.order = order
        self.title = title
        self.description = description
        self.region = region
        self.trend = trend
        self.hapticPattern = hapticPattern
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decodeIfPresent(UUID.self, forKey: .id) ?? UUID()
        order = try container.decode(Int.self, forKey: .order)
        title = try container.decode(String.self, forKey: .title)
        description = try container.decode(String.self, forKey: .description)
        region = try container.decodeIfPresent(CGRect.self, forKey: .region)
        trend = try container.decodeIfPresent(TrendType.self, forKey: .trend)
        hapticPattern = try container.decode(HapticPattern.self, forKey: .hapticPattern)
    }

    enum HapticPattern: String, Equatable, Codable {
        case none
        case rising
        case falling
        case steady
        case intersection
        case attention
        case success
    }
}

struct GraphRegion: Identifiable {
    let id = UUID()
    var name: String
    var bounds: CGRect
    var type: RegionType
    var explanation: String
    var hapticPattern: ExplanationStep.HapticPattern

    enum RegionType {
        case xAxis
        case yAxis
        case title
        case legend
        case dataLine
        case dataPoint
        case intersection
        case gridArea
    }
}

struct DemoGraph: Identifiable {
    let id = UUID()
    var name: String
    var description: String
    var image: String
    var precomputedResult: InterpretationResult
    var difficulty: Difficulty

    enum Difficulty: String, CaseIterable {
        case beginner = "Beginner"
        case intermediate = "Intermediate"
        case advanced = "Advanced"
    }
}

