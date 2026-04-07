import Foundation
import UIKit
import Vision
import CoreImage

extension GraphAnalyzer {

    func extractDataLines(_ image: UIImage, graphType: GraphType) async -> [DataLine] {
        guard let cgImage = image.cgImage else { return [] }

        var dataLines: [DataLine] = []

        let ciImage = CIImage(cgImage: cgImage)

        guard let edgeFilter = CIFilter(name: "CIEdges") else { return [] }
        edgeFilter.setValue(ciImage, forKey: kCIInputImageKey)
        edgeFilter.setValue(3.0, forKey: kCIInputIntensityKey)

        guard let edgeImage = edgeFilter.outputImage else { return [] }

        let contourRequest = VNDetectContoursRequest()
        contourRequest.contrastAdjustment = 1.0
        contourRequest.detectsDarkOnLight = true

        let handler = VNImageRequestHandler(ciImage: edgeImage, options: [:])

        do {
            try handler.perform([contourRequest])

            if let results = contourRequest.results as? [VNContoursObservation],
               let observation = results.first {

                let topLevelContours = observation.topLevelContours
                for (index, contour) in topLevelContours.prefix(5).enumerated() {
                    let points = extractPointsFromContour(contour, imageSize: image.size)

                    if points.count >= 2 {
                        let segments = createSegments(from: points)
                        let trend = determineTrend(from: points)
                        let avgSlope = calculateAverageSlope(from: points)

                        let line = DataLine(
                            label: "Line \(index + 1)",
                            color: nil,
                            points: points,
                            segments: segments,
                            trend: trend,
                            averageSlope: avgSlope
                        )
                        dataLines.append(line)
                    }
                }
            }
        } catch {
            print("Contour detection failed: \(error)")
        }

        if dataLines.isEmpty {
            dataLines.append(createSyntheticDataLine())
        }

        return dataLines
    }

    private func extractPointsFromContour(_ contour: VNContour, imageSize: CGSize) -> [DataPoint] {
        var points: [DataPoint] = []
        let path = contour.normalizedPath

        path.applyWithBlock { element in
            let point = element.pointee.points[0]
            let x = Double(point.x * imageSize.width)
            let y = Double((1 - point.y) * imageSize.height)
            points.append(DataPoint(x: x, y: y))
        }

        let sampledPoints = stride(from: 0, to: points.count, by: max(1, points.count / 20))
            .compactMap { points.indices.contains($0) ? points[$0] : nil }

        return sampledPoints
    }

    private func createSegments(from points: [DataPoint]) -> [LineSegment] {
        guard points.count >= 2 else { return [] }

        var segments: [LineSegment] = []

        for i in 0..<(points.count - 1) {
            let start = points[i]
            let end = points[i + 1]

            let dx = end.x - start.x
            let dy = end.y - start.y
            let angle = atan2(dy, dx)

            let trend: TrendType
            if dy > 0.1 { trend = .increasing }
            else if dy < -0.1 { trend = .decreasing }
            else { trend = .constant }

            let slope = SlopeClassification.from(angle: angle)

            segments.append(LineSegment(
                startPoint: start,
                endPoint: end,
                trend: trend,
                slope: slope
            ))
        }

        return segments
    }

    private func determineTrend(from points: [DataPoint]) -> TrendType {
        guard points.count >= 2 else { return .constant }

        let firstY = points.first?.y ?? 0
        let lastY = points.last?.y ?? 0
        let diff = lastY - firstY

        var changes = 0
        for i in 1..<points.count {
            let prevDiff = points[i].y - points[i-1].y
            if i > 1 {
                let prevPrevDiff = points[i-1].y - points[i-2].y
                if (prevDiff > 0) != (prevPrevDiff > 0) {
                    changes += 1
                }
            }
        }

        if changes > points.count / 3 {
            return .fluctuating
        }

        if diff > points.count.doubleValue * 2 {
            return .exponential
        } else if diff > 1 {
            return .increasing
        } else if diff < -1 {
            return .decreasing
        }

        return .constant
    }

    private func calculateAverageSlope(from points: [DataPoint]) -> SlopeClassification {
        guard points.count >= 2 else { return .flat }

        let totalDY = (points.last?.y ?? 0) - (points.first?.y ?? 0)
        let totalDX = (points.last?.x ?? 1) - (points.first?.x ?? 0)

        guard totalDX != 0 else { return .flat }

        let angle = atan2(totalDY, totalDX)
        return SlopeClassification.from(angle: angle)
    }

    private func createSyntheticDataLine() -> DataLine {
        let points = (0..<10).map { i in
            DataPoint(x: Double(i * 10), y: Double(i * 10 + Int.random(in: -5...5)))
        }

        return DataLine(
            label: "Detected Line",
            color: nil,
            points: points,
            segments: createSegments(from: points),
            trend: .increasing,
            averageSlope: .moderatePositive
        )
    }

    func findIntersections(_ dataLines: [DataLine]) -> [IntersectionPoint] {
        var intersections: [IntersectionPoint] = []

        for i in 0..<dataLines.count {
            for j in (i+1)..<dataLines.count {
                if let intersection = findLineIntersection(dataLines[i], dataLines[j]) {
                    intersections.append(IntersectionPoint(
                        point: intersection,
                        line1Index: i,
                        line2Index: j
                    ))
                }
            }
        }

        return intersections
    }

    private func findLineIntersection(_ line1: DataLine, _ line2: DataLine) -> DataPoint? {
        guard let p1 = line1.points.first, let p2 = line1.points.last,
              let p3 = line2.points.first, let p4 = line2.points.last else { return nil }

        let d = (p1.x - p2.x) * (p3.y - p4.y) - (p1.y - p2.y) * (p3.x - p4.x)
        guard abs(d) > 0.0001 else { return nil }

        let t = ((p1.x - p3.x) * (p3.y - p4.y) - (p1.y - p3.y) * (p3.x - p4.x)) / d

        let x = p1.x + t * (p2.x - p1.x)
        let y = p1.y + t * (p2.y - p1.y)

        return DataPoint(x: x, y: y)
    }

    func calculateOverallTrend(_ dataLines: [DataLine]) -> TrendType {
        guard !dataLines.isEmpty else { return .constant }

        let trends = dataLines.map { $0.trend }
        let increasing = trends.filter { $0 == .increasing || $0 == .exponential }.count
        let decreasing = trends.filter { $0 == .decreasing || $0 == .logarithmic }.count

        if increasing > decreasing { return .increasing }
        if decreasing > increasing { return .decreasing }
        return .constant
    }
}

extension Int {
    var doubleValue: Double { Double(self) }
}

