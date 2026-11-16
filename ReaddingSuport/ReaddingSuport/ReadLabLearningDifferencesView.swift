import SwiftUI

/// Step 3 of the ReadLab onboarding. This is a parent-reported preference,
/// not a medical assessment or diagnosis.
struct ReadLabLearningPreferences: Equatable {
    var diagnosis: ReadLabDiagnosis = .noneReported
    var trackReadingProgress = true
}

enum ReadLabDiagnosis: String, CaseIterable, Identifiable {
    case noneReported = "No Diagnosed Learning Difficulty (DSA)"
    case diagnosed = "Has a Diagnosed Learning Difficulty (DSA)"

    var id: String { rawValue }
    var detail: String {
        switch self {
        case .noneReported: "Nothing has been diagnosed. Standard practice is perfect."
        case .diagnosed: "A learning difficulty has been diagnosed by a specialist."
        }
    }
}

struct ReadLabLearningDifferencesView: View {
    @Binding var preferences: ReadLabLearningPreferences
    let onBack: () -> Void
    let onContinue: () -> Void

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var appeared = false

    private let ink = Color(red: 0.14, green: 0.21, blue: 0.25)
    private let canvas = Color(red: 0.965, green: 0.975, blue: 0.978)
    private let blue = Color(red: 0.48, green: 0.82, blue: 0.97)

    var body: some View {
        GeometryReader { geo in
            let compact = geo.size.width < 900

            ZStack {
                canvas.ignoresSafeArea()
                backgroundShapes.ignoresSafeArea().accessibilityHidden(true)

                VStack(spacing: 0) {
                    header
                        .padding(.top, compact ? 12 : 18)
                        .padding(.horizontal, compact ? 36 : max(52, geo.size.width * 0.18))

                    ScrollView {
                        VStack(alignment: .leading, spacing: compact ? 54 : 70) {
                            Text("Does your child have any\nlearning differences?")
                                .font(.system(size: compact ? 46 : 66, weight: .regular, design: .rounded))
                                .tracking(-1.8)
                                .foregroundStyle(ink)
                                .fixedSize(horizontal: false, vertical: true)
                                .padding(.top, compact ? 48 : 68)
                                .accessibilityAddTraits(.isHeader)

                            VStack(alignment: .leading, spacing: 54) {
                                diagnosisOptions(compact: compact)
                                trackingOption
                            }
                        }
                        .frame(maxWidth: 900, alignment: .leading)
                        .frame(maxWidth: .infinity)
                        .padding(.horizontal, compact ? 35 : 40)
                        .padding(.bottom, 30)
                    }
                    .scrollIndicators(.hidden)
                    .opacity(appeared ? 1 : 0)
                    .offset(y: appeared ? 0 : 16)
                    .safeAreaInset(edge: .bottom) {
                        HStack {
                            Spacer()
                            Button(action: onContinue) {
                                Text("Continue")
                                    .font(.system(size: 24, weight: .bold, design: .rounded))
                                    .foregroundStyle(.white)
                                    .frame(width: 180, height: 56)
                                    .background(blue, in: Capsule())
                                    .shadow(color: ink.opacity(0.16), radius: 5, y: 4)
                            }
                            .buttonStyle(LearningPressStyle())
                            .accessibilityHint("Go to step 4 of 6")
                        }
                        .frame(maxWidth: 900)
                        .frame(maxWidth: .infinity)
                        .padding(.horizontal, compact ? 35 : 40)
                        .padding(.top, 12)
                        .padding(.bottom, 18)
                    }
                }
            }
            .frame(width: geo.size.width, height: geo.size.height)
        }
        .preferredColorScheme(.light)
        .onAppear {
            withAnimation(reduceMotion ? nil : .spring(response: 0.65, dampingFraction: 0.85)) {
                appeared = true
            }
        }
    }

    private var header: some View {
        ZStack {
            HStack(spacing: 12) {
                ForEach(0..<6, id: \.self) { index in
                    Circle()
                        .fill(index == 2 ? .black : .black.opacity(0.26))
                        .frame(width: 8, height: 8)
                }
            }
            .accessibilityElement(children: .ignore)
            .accessibilityLabel("Learning differences, page 3 of 6")

            HStack {
                Button(action: onBack) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 22, weight: .medium))
                        .foregroundStyle(ink)
                        .frame(width: 44, height: 44)
                        .background(.white.opacity(0.9), in: Circle())
                }
                .buttonStyle(LearningPressStyle())
                .accessibilityLabel("Back")
                Spacer()
            }
        }
        .frame(height: 52)
    }

    @ViewBuilder
    private func diagnosisOptions(compact: Bool) -> some View {
        if compact {
            VStack(spacing: 18) {
                ForEach(ReadLabDiagnosis.allCases) { choice in diagnosisCard(choice) }
            }
        } else {
            HStack(spacing: 20) {
                ForEach(ReadLabDiagnosis.allCases) { choice in
                    diagnosisCard(choice)
                        .frame(width: 280)
                }
            }
        }
    }

    private func diagnosisCard(_ choice: ReadLabDiagnosis) -> some View {
        let selected = preferences.diagnosis == choice
        return Button {
            withAnimation(reduceMotion ? nil : .spring(response: 0.32, dampingFraction: 0.83)) {
                preferences.diagnosis = choice
            }
        } label: {
            VStack(alignment: .leading, spacing: 12) {
                HStack(alignment: .top, spacing: 10) {
                    Text(choice.rawValue)
                        .font(.system(size: 13, weight: .semibold, design: .rounded))
                        .multilineTextAlignment(.leading)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    Image(systemName: selected ? "circle.fill" : "circle.fill")
                        .font(.system(size: 20))
                        .foregroundStyle(selected ? blue : Color(red: 0.84, green: 0.85, blue: 0.89))
                }
                Spacer(minLength: 6)
                Text(choice.detail)
                    .font(.system(size: 12, design: .rounded))
                    .multilineTextAlignment(.leading)
                    .foregroundStyle(ink.opacity(0.78))
                    .fixedSize(horizontal: false, vertical: true)
            }
            .foregroundStyle(ink)
            .padding(20)
            .frame(maxWidth: .infinity, minHeight: 126, maxHeight: 126)
            .background(.white, in: RoundedRectangle(cornerRadius: 25))
            .overlay {
                RoundedRectangle(cornerRadius: 25)
                    .strokeBorder(selected ? blue : .clear, lineWidth: 4)
            }
            .shadow(color: .black.opacity(0.14), radius: 5, y: 4)
        }
        .buttonStyle(LearningPressStyle())
        .accessibilityElement(children: .combine)
        .accessibilityAddTraits(selected ? .isSelected : [])
    }

    private var trackingOption: some View {
        Toggle(isOn: $preferences.trackReadingProgress) {
            VStack(alignment: .leading, spacing: 22) {
                Text("I’d like to track my child’s reading practice and progress.")
                    .font(.system(size: 20, weight: .semibold, design: .rounded))
                    .foregroundStyle(ink)
                Text("Add a private adult dashboard with analytics.")
                    .font(.system(size: 16, design: .rounded))
                    .foregroundStyle(ink.opacity(0.82))
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .tint(blue)
        .padding(.horizontal, 32)
        .padding(.vertical, 26)
        .background(.white, in: RoundedRectangle(cornerRadius: 25))
        .shadow(color: .black.opacity(0.14), radius: 5, y: 4)
        .accessibilityHint("Enable or disable the optional adult progress dashboard")
    }

    private var backgroundShapes: some View {
        GeometryReader { geo in
            let w = geo.size.width
            let h = geo.size.height
            Ellipse()
                .fill(Color(red: 0.74, green: 0.91, blue: 0.79))
                .frame(width: w * 0.57, height: h * 0.75)
                .rotationEffect(.degrees(-24))
                .position(x: w * 1.03, y: h * 0.12)
            Ellipse()
                .fill(Color(red: 0.77, green: 0.93, blue: 0.95))
                .frame(width: w * 0.68, height: h * 0.62)
                .rotationEffect(.degrees(20))
                .position(x: w * 0.14, y: h * 0.94)
            Ellipse()
                .fill(Color(red: 1.0, green: 0.84, blue: 0.77))
                .frame(width: w * 0.48, height: h * 0.65)
                .rotationEffect(.degrees(-20))
                .position(x: w * 0.88, y: h * 0.96)
        }
    }
}

private struct LearningPressStyle: ButtonStyle {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed && !reduceMotion ? 0.97 : 1)
            .animation(.spring(response: 0.25, dampingFraction: 0.75), value: configuration.isPressed)
    }
}

#Preview("iPad Landscape", traits: .fixedLayout(width: 1366, height: 1024)) {
    ReadLabLearningDifferencesView(preferences: .constant(ReadLabLearningPreferences()), onBack: {}, onContinue: {})
}
