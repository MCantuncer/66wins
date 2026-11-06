import SwiftUI
import UIKit

// MARK: - Medallion stage
//
// Light as the material: a soft pool of light behind a medallion when it is
// presented on its own (the earn moment). In dark it is a faint white bloom on
// near-black; in light it is a paper-white lift. Decorative, hidden from VoiceOver.
// Added by designer-2 (round 4). Uses only Theme's dynamic Color initializer.

enum StageLight {
    /// Center of the light pool behind a presented medallion.
    static let glow = Color(
        light: UIColor(white: 1, alpha: 0.90),
        dark: UIColor(white: 1, alpha: 0.10),
        lightHighContrast: UIColor(white: 1, alpha: 0.0),
        darkHighContrast: UIColor(white: 1, alpha: 0.0)
    )
}

struct MedallionStage<Content: View>: View {
    /// Diameter of the medallion being staged.
    let diameter: CGFloat
    let content: Content

    init(diameter: CGFloat, @ViewBuilder content: () -> Content) {
        self.diameter = diameter
        self.content = content()
    }

    var body: some View {
        content
            .background {
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [StageLight.glow, StageLight.glow.opacity(0)],
                            center: .center,
                            startRadius: diameter * 0.25,
                            endRadius: diameter * 0.95
                        )
                    )
                    .frame(width: diameter * 1.9, height: diameter * 1.9)
                    .allowsHitTesting(false)
                    .accessibilityHidden(true)
            }
    }
}

#Preview("Medallion stage") {
    MedallionStage(diameter: 248) {
        MedallionView(number: 21, material: .pewter, size: 248, litTicks: 21)
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .screenBackground()
    .preferredColorScheme(.dark)
}
