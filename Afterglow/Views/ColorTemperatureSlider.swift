import SwiftUI

/// A custom slider for adjusting Night Shift color temperature.
/// Displays warm (sun) and cool (moon) icons at the ends.
struct ColorTemperatureSlider: View {
    @Binding var value: Float
    var isEnabled: Bool

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "sun.max.fill")
                .font(.caption)
                .foregroundColor(isEnabled ? .orange : .secondary)

            Slider(
                value: Binding(
                    get: { Double(value) },
                    set: { value = Float($0) }
                ),
                in: 0...1,
                step: 0.01
            )
            .disabled(!isEnabled)

            Image(systemName: "moon.fill")
                .font(.caption)
                .foregroundColor(isEnabled ? .blue : .secondary)
        }
        .opacity(isEnabled ? 1.0 : 0.5)
    }
}
