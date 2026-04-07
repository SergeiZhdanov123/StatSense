import SwiftUI
import SwiftData

struct HistoryView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \SavedGraph.timestamp, order: .reverse) private var savedGraphs: [SavedGraph]

    @State private var selectedResult: InterpretationResult?

    var body: some View {
        NavigationStack {
            Group {
                if savedGraphs.isEmpty {
                    VStack(spacing: 20) {
                        Image(systemName: "photo.on.rectangle.angled")
                            .font(.system(size: 60))
                            .foregroundColor(.secondary)
                        Text("No Past Analysis Yet")
                            .font(.title2)
                        Text("Graphs you analyze in the Capture tab will appear here.")
                            .multilineTextAlignment(.center)
                            .foregroundColor(.secondary)
                            .padding(.horizontal)
                    }
                } else {
                    List {
                        ForEach(savedGraphs) { graph in
                            Button(action: {
                                if let result = graph.interpretationResult {

                                    var resultWithImage = result
                                    if let uiImage = UIImage(data: graph.imageData) {
                                        resultWithImage.capturedImage = uiImage
                                    }
                                    selectedResult = resultWithImage
                                }
                            }) {
                                HStack(spacing: 15) {
                                    if let uiImage = UIImage(data: graph.imageData) {
                                        Image(uiImage: uiImage)
                                            .resizable()
                                            .aspectRatio(contentMode: .fill)
                                            .frame(width: 80, height: 80)
                                            .clipShape(RoundedRectangle(cornerRadius: 8))
                                    } else {
                                        RoundedRectangle(cornerRadius: 8)
                                            .fill(Color.gray.opacity(0.3))
                                            .frame(width: 80, height: 80)
                                    }

                                    VStack(alignment: .leading, spacing: 5) {
                                        if let result = graph.interpretationResult {
                                            Text(result.graphType.rawValue)
                                                .font(.headline)
                                                .foregroundColor(.primary)
                                            Text(result.overallTrend.description)
                                                .font(.subheadline)
                                                .foregroundColor(.secondary)
                                        } else {
                                            Text("Unknown Graph")
                                                .font(.headline)
                                                .foregroundColor(.primary)
                                        }

                                        Text(graph.timestamp, style: .date)
                                            .font(.caption)
                                            .foregroundColor(.gray)
                                    }
                                }
                                .padding(.vertical, 4)
                            }
                        }
                        .onDelete(perform: deleteGraphs)
                    }
                }
            }
            .navigationTitle("History")
            .sheet(item: Binding<InterpretationResult?>(
                get: { selectedResult },
                set: { selectedResult = $0 }
            )) { result in
                ResultsView(result: result)
            }
        }
    }

    private func deleteGraphs(offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                modelContext.delete(savedGraphs[index])
            }
        }
    }
}
