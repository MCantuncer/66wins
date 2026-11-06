import SwiftUI

/// Temporary screen used only to verify the render pipeline. Remove once real screens exist.
struct PipelineCheckScreen: View {
    var body: some View {
        VStack(spacing: 12) {
            Text("66wins")
                .font(.system(.largeTitle, design: .default, weight: .bold))
            Text("Render pipeline check")
                .font(.body)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemBackground))
    }
}

#Preview { PipelineCheckScreen() }
