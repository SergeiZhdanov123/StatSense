import Foundation
import SwiftData

@Model
final class SavedGraph {
    var id: UUID
    var timestamp: Date
    @Attribute(.externalStorage) var imageData: Data
    var interpretationJSON: Data

    init(id: UUID = UUID(), timestamp: Date = Date(), imageData: Data, interpretationResult: InterpretationResult) throws {
        self.id = id
        self.timestamp = timestamp
        self.imageData = imageData

        let encoder = JSONEncoder()
        self.interpretationJSON = try encoder.encode(interpretationResult)
    }

    var interpretationResult: InterpretationResult? {
        let decoder = JSONDecoder()
        return try? decoder.decode(InterpretationResult.self, from: interpretationJSON)
    }
}
