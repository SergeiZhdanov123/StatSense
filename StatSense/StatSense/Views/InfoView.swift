import SwiftUI

struct InfoView: View {
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {

                    appHeader

                    problemSection

                    solutionSection

                    featuresSection

                    howItWorksSection

                    technicalSection

                }
                .padding()
            }
            .navigationTitle("About StatSense")
        }
    }

    private var appHeader: some View {
        VStack(spacing: 12) {
            Image(systemName: "chart.line.uptrend.xyaxis.circle.fill")
                .font(.system(size: 80))
                .foregroundStyle(
                    LinearGradient(
                        colors: [AccessibleColors.primary, AccessibleColors.tertiary],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )

            Text("StatSense")
                .font(.largeTitle)
                .fontWeight(.bold)

            Text("Making STEM Accessible for Everyone")
                .font(.headline)
                .foregroundColor(.secondary)
        }
        .padding(.vertical)
    }

    private var problemSection: some View {
        InfoCard(
            title: "The Problem",
            icon: "exclamationmark.triangle.fill",
            iconColor: AccessibleColors.error,
            content: """
            Millions of blind and deaf students are excluded from STEM education because critical \
            information is presented visually through graphs, charts, diagrams, and whiteboard drawings.

            Traditional accessibility tools cannot interpret the meaning of visual data—they can only \
            describe what text is present, leaving students without access to the actual content.
            """
        )
    }

    private var solutionSection: some View {
        InfoCard(
            title: "Our Solution",
            icon: "lightbulb.fill",
            iconColor: AccessibleColors.warning,
            content: """
            StatSense uses on-device AI to interpret visual data and convert it into structured, \
            meaningful explanations. Unlike simple text readers, StatSense understands:

            • What type of graph it's looking at
            • The axes, scales, and labels
            • Data trends and patterns
            • Slopes and their meanings
            • Intersection points and their significance
            """
        )
    }

    private var featuresSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Key Features")
                .font(.title2)
                .fontWeight(.bold)

            FeatureRow(icon: "speaker.wave.3.fill", title: "Audio Mode", description: "Voice descriptions with adjustable speed and controls")
            FeatureRow(icon: "eye.fill", title: "Visual Mode", description: "High-contrast display for deaf users")
            FeatureRow(icon: "hand.tap.fill", title: "Haptic Mode", description: "Vibration patterns for trends—works without screen")
            FeatureRow(icon: "lock.shield.fill", title: "100% Private", description: "All processing on-device, no cloud required")
            FeatureRow(icon: "accessibility", title: "VoiceOver Ready", description: "Full compatibility with iOS accessibility features")
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(16)
    }

    private var howItWorksSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("How It Works")
                .font(.title2)
                .fontWeight(.bold)

            StepItem(number: 1, text: "Point your camera at any graph, chart, or diagram")
            StepItem(number: 2, text: "StatSense analyzes the image using on-device AI")
            StepItem(number: 3, text: "Receive structured explanations through your preferred mode")
            StepItem(number: 4, text: "Explore step-by-step with audio, visuals, and haptics")
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(16)
    }

    private var technicalSection: some View {
        InfoCard(
            title: "Technical Details",
            icon: "cpu.fill",
            iconColor: AccessibleColors.tertiary,
            content: """
            Built with:
            • Swift & SwiftUI for native iOS performance
            • Vision Framework for image analysis
            • Core ML for on-device machine learning
            • Core Haptics for tactile feedback
            • AVSpeechSynthesizer for voice output

            No external hardware, no cloud dependency, no institutional systems required.
            """
        )
    }
}

struct InfoCard: View {
    let title: String
    let icon: String
    let iconColor: Color
    let content: String

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(iconColor)
                    .font(.title2)
                Text(title)
                    .font(.title2)
                    .fontWeight(.bold)
            }

            Text(content)
                .font(.body)
                .foregroundColor(.secondary)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.systemGray6))
        .cornerRadius(16)
    }
}

struct FeatureRow: View {
    let icon: String
    let title: String
    let description: String

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(AccessibleColors.primary)
                .frame(width: 24)

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.headline)
                Text(description)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
    }
}

struct StepItem: View {
    let number: Int
    let text: String

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Text("\(number)")
                .font(.headline)
                .foregroundColor(.white)
                .frame(width: 28, height: 28)
                .background(AccessibleColors.primary)
                .clipShape(Circle())

            Text(text)
                .font(.body)
        }
    }
}

#Preview {
    InfoView()
}

