import Foundation
import UIKit
import Vision

class ImageAnalyzer {

    func recognizeText(in image: UIImage) async -> [RecognizedTextBlock] {
        guard let cgImage = image.cgImage else { return [] }

        return await withCheckedContinuation { continuation in
            let request = VNRecognizeTextRequest { request, error in
                guard error == nil,
                      let observations = request.results as? [VNRecognizedTextObservation] else {
                    continuation.resume(returning: [])
                    return
                }

                let blocks = observations.compactMap { observation -> RecognizedTextBlock? in
                    guard let candidate = observation.topCandidates(1).first else { return nil }
                    return RecognizedTextBlock(
                        text: candidate.string,
                        confidence: candidate.confidence,
                        boundingBox: observation.boundingBox
                    )
                }

                continuation.resume(returning: blocks)
            }

            request.recognitionLevel = .accurate
            request.usesLanguageCorrection = true

            let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])

            do {
                try handler.perform([request])
            } catch {
                print("Text recognition error: \(error)")
                continuation.resume(returning: [])
            }
        }
    }

    func detectRectangles(in image: UIImage) async -> [CGRect] {
        guard let cgImage = image.cgImage else { return [] }

        return await withCheckedContinuation { continuation in
            let request = VNDetectRectanglesRequest { request, error in
                guard error == nil,
                      let observations = request.results as? [VNRectangleObservation] else {
                    continuation.resume(returning: [])
                    return
                }

                let rects = observations.map { observation in
                    CGRect(
                        x: observation.boundingBox.origin.x,
                        y: observation.boundingBox.origin.y,
                        width: observation.boundingBox.width,
                        height: observation.boundingBox.height
                    )
                }

                continuation.resume(returning: rects)
            }

            request.minimumAspectRatio = 0.3
            request.maximumAspectRatio = 3.0
            request.minimumSize = 0.1
            request.minimumConfidence = 0.5

            let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])

            do {
                try handler.perform([request])
            } catch {
                print("Rectangle detection error: \(error)")
                continuation.resume(returning: [])
            }
        }
    }

    func detectContours(in image: UIImage) async -> [VNContour] {
        guard let cgImage = image.cgImage else { return [] }

        return await withCheckedContinuation { continuation in
            let request = VNDetectContoursRequest { request, error in
                guard error == nil,
                      let results = request.results as? [VNContoursObservation],
                      let observation = results.first else {
                    continuation.resume(returning: [])
                    return
                }

                let contours = (0..<observation.topLevelContourCount).compactMap { index -> VNContour? in
                    try? observation.topLevelContours[index]
                }

                continuation.resume(returning: contours)
            }

            request.contrastAdjustment = 1.5
            request.detectsDarkOnLight = true

            let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])

            do {
                try handler.perform([request])
            } catch {
                print("Contour detection error: \(error)")
                continuation.resume(returning: [])
            }
        }
    }
}

struct RecognizedTextBlock {
    let text: String
    let confidence: Float
    let boundingBox: CGRect

    var isNumber: Bool {
        Double(text.replacingOccurrences(of: ",", with: "")) != nil
    }

    var numericValue: Double? {
        Double(text.replacingOccurrences(of: ",", with: ""))
    }
}

enum AnalysisError: Error, LocalizedError {
    case preprocessingFailed
    case noGraphDetected
    case analysisTimeout
    case lowConfidence
    case unsupportedGraphType
    case invalidResponse

    var errorDescription: String? {
        switch self {
        case .preprocessingFailed: return "Could not optimize image for AI analysis."
        case .noGraphDetected: return "No graph or chart detected in the image."
        case .analysisTimeout: return "Analysis took too long."
        case .lowConfidence: return "Could not reliably interpret the graph."
        case .unsupportedGraphType: return "This type of graph is not yet supported."
        case .invalidResponse: return "The AI returned an unreadable response."
        }
    }
}

