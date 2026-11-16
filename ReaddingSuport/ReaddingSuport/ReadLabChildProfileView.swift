import SwiftUI

/// Onboarding step 2: parent/guardian enters a child's reading profile.
/// The data stays in memory until the app chooses how to store it.
struct ReadLabChildProfile: Equatable {
    var childName = ""
    var ageRange: ReadLabAgeRange? = nil
    var readingFamiliarity: ReadLabReadingFamiliarity? = nil
}

enum ReadLabAgeRange: String, CaseIterable, Identifiable {
    case fourFive = "4–5"
    case sixSeven = "6–7"
    case eightNine = "8–9"
    case tenPlus = "10+"
    var id: String { rawValue }
}

enum ReadLabReadingFamiliarity: String, CaseIterable, Identifiable {
    case notIndependent = "Not Reading Independently"
    case learning = "Learning to Read"
    case independent = "Reading Independently"
    var id: String { rawValue }

    var detail: String {
        switch self {
        case .notIndependent: "Enjoys listening, sounds, pictures and shared stories."
        case .learning: "Reads short sentences with some help and enjoys simple stories."
        case .independent: "Reads medium-length stories alone and is building fluency."
        }
    }
}

struct ReadLabChildProfileView: View {
    @Binding var profile: ReadLabChildProfile
    let onBack: () -> Void
    let onContinue: () -> Void

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @FocusState private var childNameFocused: Bool
    @State private var appeared = false

    private let ink = Color(red: 0.14, green: 0.21, blue: 0.25)
    private let canvas = Color(red: 0.965, green: 0.975, blue: 0.978)
    private let blue = Color(red: 0.36, green: 0.80, blue: 0.97)

    private var valid: Bool {
        !profile.childName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        profile.readingFamiliarity != nil
    }

    var body: some View {
        GeometryReader { geo in
            let compact = geo.size.width < 900
            ZStack {
                canvas.ignoresSafeArea()
                backgroundShapes
                    .ignoresSafeArea()
                    .accessibilityHidden(true)

                VStack(spacing: 0) {
                    header
                        .padding(.top, compact ? 12 : 18)
                        .padding(.horizontal, compact ? 36 : max(52, geo.size.width * 0.18))

                    ScrollView {
                        VStack(alignment: .leading, spacing: compact ? 42 : 70) {
                            Text("Let’s know about your child.")
                                .font(.system(size: compact ? 46 : 66, weight: .regular, design: .rounded))
                                .tracking(-1.8)
                                .minimumScaleFactor(0.75)
                                .foregroundStyle(ink)
                                .padding(.top, compact ? 48 : 68)

                            formContent(compact: compact)
                        }
                        .frame(maxWidth: 900, alignment: .leading)
                        .frame(maxWidth: .infinity)
                        .padding(.horizontal, compact ? 35 : 40)
                        .padding(.bottom, 32)
                    }
                    .scrollIndicators(.hidden)
                    .scrollDismissesKeyboard(.interactively)
                    .opacity(appeared ? 1 : 0)
                    .offset(y: appeared ? 0 : 14)
                    .safeAreaInset(edge: .bottom) {
                        HStack {
                            Spacer()
                            Button {
                                childNameFocused = false
                                onContinue()
                            } label: {
                                Text("Continue")
                                    .font(.system(size: 24, weight: .bold, design: .rounded))
                                    .foregroundStyle(.white)
                                    .frame(width: 180, height: 56)
                                    .background(blue, in: Capsule())
                                    .shadow(color: ink.opacity(0.18), radius: 5, y: 4)
                            }
                            .disabled(!valid)
                            .opacity(valid ? 1 : 0.48)
                            .buttonStyle(ReadLabPressStyle())
                            .accessibilityHint(valid ? "Go to the next setup screen" : "Enter a child name and select a reading familiarity level")
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
                        .fill(index == 1 ? Color.black : Color.black.opacity(0.26))
                        .frame(width: 8, height: 8)
                }
            }
            .accessibilityElement(children: .ignore)
            .accessibilityLabel("Child profile, page 2 of 6")

            HStack {
                Button {
                    childNameFocused = false
                    onBack()
                } label: {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 22, weight: .medium))
                        .foregroundStyle(ink)
                        .frame(width: 44, height: 44)
                        .background(.white.opacity(0.9), in: Circle())
                }
                .buttonStyle(ReadLabPressStyle())
                .accessibilityLabel("Back")
                Spacer()
            }
        }
        .frame(height: 52)
    }

    private func formContent(compact: Bool) -> some View {
        VStack(alignment: .leading, spacing: 42) {
            VStack(alignment: .leading, spacing: 9) {
                fieldLabel("CHILD NAME*")
                TextField("e.g. Luca", text: $profile.childName)
                    .font(.system(size: 18, design: .rounded))
                    .textContentType(.givenName)
                    .textInputAutocapitalization(.words)
                    .autocorrectionDisabled()
                    .submitLabel(.done)
                    .focused($childNameFocused)
                    .onSubmit { childNameFocused = false }
                    .padding(.horizontal, 20)
                    .frame(width: compact ? nil : 382, height: 63)
                    .frame(maxWidth: compact ? 420 : nil)
                    .background(.white, in: RoundedRectangle(cornerRadius: 17))
                    .readLabCardShadow()
                    .accessibilityLabel("Child name, required")
            }

            VStack(alignment: .leading, spacing: 9) {
                fieldLabel("AGE RANGE")
                LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 18), count: 4), spacing: 12) {
                    ForEach(ReadLabAgeRange.allCases) { age in
                        let selected = profile.ageRange == age
                        Button {
                            childNameFocused = false
                            withAnimation(.easeInOut(duration: 0.18)) { profile.ageRange = age }
                        } label: {
                            Text(age.rawValue)
                                .font(.system(size: compact ? 17 : 21, design: .rounded))
                                .foregroundStyle(ink)
                                .frame(maxWidth: .infinity)
                                .frame(height: 54)
                                .background(selected ? blue.opacity(0.22) : .white,
                                            in: RoundedRectangle(cornerRadius: 16))
                                .overlay {
                                    RoundedRectangle(cornerRadius: 16)
                                        .strokeBorder(selected ? blue : .clear, lineWidth: 2)
                                }
                                .readLabCardShadow()
                        }
                        .buttonStyle(ReadLabPressStyle())
                        .accessibilityAddTraits(selected ? .isSelected : [])
                    }
                }
                .frame(maxWidth: compact ? 500 : 496)
            }

            VStack(alignment: .leading, spacing: 12) {
                fieldLabel("READING FAMILIARITY*")
                ViewThatFits(in: .horizontal) {
                    familiarityCards
                    familiarityCardsVertical
                }
            }
        }
    }

    private var familiarityCards: some View {
        HStack(spacing: 20) {
            ForEach(ReadLabReadingFamiliarity.allCases) { level in
                familiarityCard(level)
            }
        }
    }

    private var familiarityCardsVertical: some View {
        VStack(spacing: 14) {
            ForEach(ReadLabReadingFamiliarity.allCases) { level in
                familiarityCard(level)
            }
        }
    }

    private func familiarityCard(_ level: ReadLabReadingFamiliarity) -> some View {
        let selected = profile.readingFamiliarity == level
        return Button {
            childNameFocused = false
            withAnimation(.easeInOut(duration: 0.18)) { profile.readingFamiliarity = level }
        } label: {
            VStack(alignment: .leading, spacing: 12) {
                HStack(alignment: .top, spacing: 8) {
                    Text(level.rawValue)
                        .font(.system(size: 13, weight: .semibold, design: .rounded))
                        .multilineTextAlignment(.leading)
                        .lineLimit(2)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    Image(systemName: selected ? "checkmark.circle.fill" : "circle.fill")
                        .foregroundStyle(selected ? blue : Color(red: 0.84, green: 0.85, blue: 0.89))
                        .font(.system(size: 20))
                }
                Spacer(minLength: 6)
                Text(level.detail)
                    .font(.system(size: 12, weight: .regular, design: .rounded))
                    .multilineTextAlignment(.leading)
                    .foregroundStyle(ink.opacity(0.78))
                    .fixedSize(horizontal: false, vertical: true)
            }
            .foregroundStyle(ink)
            .padding(20)
            .frame(maxWidth: .infinity, minHeight: 126, maxHeight: 126)
            .background(selected ? blue.opacity(0.15) : .white,
                        in: RoundedRectangle(cornerRadius: 25))
            .overlay {
                RoundedRectangle(cornerRadius: 25)
                    .strokeBorder(selected ? blue : .clear, lineWidth: 2)
            }
            .readLabCardShadow()
        }
        .buttonStyle(ReadLabPressStyle())
        .accessibilityElement(children: .combine)
        .accessibilityAddTraits(selected ? .isSelected : [])
    }

    private func fieldLabel(_ value: String) -> some View {
        Text(value)
            .font(.system(size: 10, weight: .bold, design: .rounded))
            .foregroundStyle(ink)
    }

    private var backgroundShapes: some View {
        GeometryReader { geo in
            let w = geo.size.width
            let h = geo.size.height
            Ellipse()
                .fill(Color(red: 1.0, green: 0.956, blue: 0.805))
                .frame(width: w * 1.04, height: h * 0.92)
                .rotationEffect(.degrees(18))
                .position(x: w * 0.76, y: -h * 0.04)
            Ellipse()
                .fill(Color(red: 0.86, green: 0.82, blue: 0.95))
                .frame(width: w * 0.35, height: h * 1.15)
                .rotationEffect(.degrees(-12))
                .position(x: -w * 0.04, y: h * 0.63)
            Ellipse()
                .fill(Color(red: 0.76, green: 0.92, blue: 0.94))
                .frame(width: w * 0.55, height: h * 0.60)
                .rotationEffect(.degrees(30))
                .position(x: w * 0.94, y: h * 1.01)
        }
    }
}

private struct ReadLabPressStyle: ButtonStyle {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed && !reduceMotion ? 0.97 : 1)
            .animation(.spring(response: 0.25, dampingFraction: 0.75), value: configuration.isPressed)
    }
}

private struct ReadLabCardShadow: ViewModifier {
    func body(content: Content) -> some View {
        content.shadow(color: .black.opacity(0.14), radius: 5, y: 4)
    }
}
private extension View {
    func readLabCardShadow() -> some View { modifier(ReadLabCardShadow()) }
}

#Preview("Landscape", traits: .fixedLayout(width: 1366, height: 1024)) {
    ReadLabChildProfileView(profile: .constant(ReadLabChildProfile()), onBack: {}, onContinue: {})
}
