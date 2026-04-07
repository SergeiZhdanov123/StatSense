import Foundation
import CoreGraphics

enum GraphType: String, CaseIterable, Identifiable, Codable {
    case lineGraph = "Line Graph"
    case barChart = "Bar Chart"
    case scatterPlot = "Scatter Plot"
    case pieChart = "Pie Chart"
    case diagram = "Diagram"
    case whiteboard = "Whiteboard"
    case unknown = "Unknown"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .lineGraph: return "chart.line.uptrend.xyaxis"
        case .barChart: return "chart.bar.fill"
        case .scatterPlot: return "chart.dots.scatter"
        case .pieChart: return "chart.pie.fill"
        case .diagram: return "rectangle.3.group"
        case .whiteboard: return "rectangle.on.rectangle"
        case .unknown: return "questionmark.circle"
        }
    }
}

enum TrendType: String, CaseIterable, Codable {
    case increasing = "Increasing"
    case decreasing = "Decreasing"
    case constant = "Constant"
    case fluctuating = "Fluctuating"
    case exponential = "Exponential"
    case logarithmic = "Logarithmic"

    var icon: String {
        switch self {
        case .increasing: return "↑"
        case .decreasing: return "↓"
        case .constant: return "↔"
        case .fluctuating: return "↕"
        case .exponential: return "⤴"
        case .logarithmic: return "⤵"
        }
    }

    var description: String {
        switch self {
        case .increasing: return "Values are rising"
        case .decreasing: return "Values are falling"
        case .constant: return "Values remain stable"
        case .fluctuating: return "Values vary up and down"
        case .exponential: return "Values grow rapidly"
        case .logarithmic: return "Growth rate is slowing"
        }
    }
}

enum SlopeClassification: String, Codable {
    case steepPositive = "Steep Positive"
    case moderatePositive = "Moderate Positive"
    case gentlePositive = "Gentle Positive"
    case flat = "Flat"
    case gentleNegative = "Gentle Negative"
    case moderateNegative = "Moderate Negative"
    case steepNegative = "Steep Negative"

    var description: String {
        switch self {
        case .steepPositive: return "The slope is positive and steep"
        case .moderatePositive: return "The slope is positive with moderate incline"
        case .gentlePositive: return "The slope is positive but gentle"
        case .flat: return "The line is approximately horizontal"
        case .gentleNegative: return "The slope is negative but gentle"
        case .moderateNegative: return "The slope is negative with moderate decline"
        case .steepNegative: return "The slope is negative and steep"
        }
    }

    static func from(angle: Double) -> SlopeClassification {
        let degrees = angle * 180 / .pi
        switch degrees {
        case 60...: return .steepPositive
        case 30..<60: return .moderatePositive
        case 5..<30: return .gentlePositive
        case -5..<5: return .flat
        case -30..<(-5): return .gentleNegative
        case -60..<(-30): return .moderateNegative
        default: return .steepNegative
        }
    }
}

struct DataPoint: Identifiable, Equatable, Codable {
    var id: UUID
    var x: Double
    var y: Double
    var label: String?

    enum CodingKeys: String, CodingKey {
        case id, x, y, label
    }

    init(id: UUID = UUID(), x: Double, y: Double, label: String? = nil) {
        self.id = id
        self.x = x
        self.y = y
        self.label = label
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decodeIfPresent(UUID.self, forKey: .id) ?? UUID()
        x = try container.decode(Double.self, forKey: .x)
        y = try container.decode(Double.self, forKey: .y)
        label = try container.decodeIfPresent(String.self, forKey: .label)
    }

    var cgPoint: CGPoint {
        CGPoint(x: x, y: y)
    }
}

struct AxisInfo: Equatable, Codable {
    var label: String
    var minValue: Double
    var maxValue: Double
    var scale: String
    var unit: String?

    var range: Double { maxValue - minValue }

    var description: String {
        var desc = "\(label) axis ranges from \(formatValue(minValue)) to \(formatValue(maxValue))"
        if let unit = unit {
            desc += " \(unit)"
        }
        return desc
    }

    private func formatValue(_ value: Double) -> String {
        if value == floor(value) {
            return String(format: "%.0f", value)
        }
        return String(format: "%.2f", value)
    }
}

struct LineSegment: Identifiable, Equatable, Codable {
    var id: UUID
    var startPoint: DataPoint
    var endPoint: DataPoint
    var trend: TrendType
    var slope: SlopeClassification

    enum CodingKeys: String, CodingKey {
        case id, startPoint, endPoint, trend, slope
    }

    init(id: UUID = UUID(), startPoint: DataPoint, endPoint: DataPoint, trend: TrendType, slope: SlopeClassification) {
        self.id = id
        self.startPoint = startPoint
        self.endPoint = endPoint
        self.trend = trend
        self.slope = slope
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decodeIfPresent(UUID.self, forKey: .id) ?? UUID()
        startPoint = try container.decode(DataPoint.self, forKey: .startPoint)
        endPoint = try container.decode(DataPoint.self, forKey: .endPoint)
        trend = try container.decode(TrendType.self, forKey: .trend)
        slope = try container.decode(SlopeClassification.self, forKey: .slope)
    }

    var description: String {
        "From (\(startPoint.x), \(startPoint.y)) to (\(endPoint.x), \(endPoint.y)): \(slope.description)"
    }
}

struct IntersectionPoint: Identifiable, Equatable, Codable {
    var id: UUID
    var point: DataPoint
    var line1Index: Int
    var line2Index: Int

    enum CodingKeys: String, CodingKey {
        case id, point, line1Index, line2Index
    }

    init(id: UUID = UUID(), point: DataPoint, line1Index: Int, line2Index: Int) {
        self.id = id
        self.point = point
        self.line1Index = line1Index
        self.line2Index = line2Index
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decodeIfPresent(UUID.self, forKey: .id) ?? UUID()
        point = try container.decode(DataPoint.self, forKey: .point)
        line1Index = try container.decode(Int.self, forKey: .line1Index)
        line2Index = try container.decode(Int.self, forKey: .line2Index)
    }

    var description: String {
        "Lines intersect at approximately x = \(String(format: "%.1f", point.x)), y = \(String(format: "%.1f", point.y))"
    }
}

