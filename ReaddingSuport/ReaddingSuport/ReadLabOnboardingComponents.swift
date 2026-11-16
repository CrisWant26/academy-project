import SwiftUI

// Shared visual language for screens 4–6.
enum ReadLabStyle {
    static let ink = Color(red: 0.14, green: 0.21, blue: 0.25)
    static let background = Color(red: 0.965, green: 0.975, blue: 0.978)
    static let blue = Color(red: 0.37, green: 0.80, blue: 0.97)
    static let muted = Color(red: 0.85, green: 0.86, blue: 0.90)
}

struct ReadLabPastelBackground: View {
    let yellow: Bool

    var body: some View {
        GeometryReader { geometry in
            let w = geometry.size.width
            let h = geometry.size.height
            ZStack {
                ReadLabStyle.background
                Ellipse()
                    .fill(yellow ? Color(red: 1, green: 0.92, blue: 0.59) : Color(red: 0.75, green: 0.91, blue: 0.80))
                    .frame(width: w * 0.78, height: h * 0.85)
                    .rotationEffect(.degrees(-22))
                    .position(x: w * 0.90, y: h * 0.09)
                Ellipse()
                    .fill(Color(red: 0.84, green: 0.79, blue: 0.94))
                    .frame(width: w * 0.45, height: h * 0.95)
                    .rotationEffect(.degrees(-20))
                    .position(x: -w * 0.06, y: h * 0.62)
                Ellipse()
                    .fill(Color(red: 0.77, green: 0.93, blue: 0.95))
                    .frame(width: w * 0.75, height: h * 0.66)
                    .rotationEffect(.degrees(23))
                    .position(x: w * 0.08, y: h * 1.04)
                Ellipse()
                    .fill(Color(red: 1, green: 0.84, blue: 0.77))
                    .frame(width: w * 0.54, height: h * 0.62)
                    .rotationEffect(.degrees(-16))
                    .position(x: w * 0.97, y: h * 1.03)
            }
            .frame(width: w, height: h)
            .clipped()
        }
        .ignoresSafeArea()
        .accessibilityHidden(true)
    }
}

struct ReadLabStepHeader: View {
    let step: Int
    let onBack: () -> Void

    var body: some View {
        ZStack {
            HStack(spacing: 12) {
                ForEach(0..<6, id: \.self) { index in
                    Circle()
                        .fill(index == step - 1 ? Color.black : Color.black.opacity(0.27))
                        .frame(width: 8, height: 8)
                }
            }
            .accessibilityElement(children: .ignore)
            .accessibilityLabel("Page \(step) of 6")

            HStack {
                Button(action: onBack) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 20, weight: .medium))
                        .foregroundStyle(ReadLabStyle.ink)
                        .frame(width: 44, height: 44)
                        .background(.white.opacity(0.96), in: Circle())
                }
                .buttonStyle(ReadLabTapStyle())
                .accessibilityLabel("Back")
                Spacer()
            }
        }
        .frame(height: 52)
    }
}

struct ReadLabTapStyle: ButtonStyle {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed && !reduceMotion ? 0.97 : 1)
            .animation(reduceMotion ? nil : .spring(response: 0.28, dampingFraction: 0.8), value: configuration.isPressed)
    }
}

struct ReadLabActionButton: View {
    let title: String
    let action: () -> Void
    var enabled: Bool = true

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 24, weight: .bold, design: .rounded))
                .foregroundStyle(.white)
                .frame(minWidth: 180, minHeight: 56)
                .background(ReadLabStyle.blue, in: Capsule())
                .shadow(color: .black.opacity(0.16), radius: 5, y: 4)
        }
        .disabled(!enabled)
        .opacity(enabled ? 1 : 0.48)
        .buttonStyle(ReadLabTapStyle())
    }
}

struct ReadLabChoiceCard: View {
    let title: String
    let subtitle: String
    let selected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 14) {
                HStack(alignment: .top, spacing: 10) {
                    Text(title)
                        .font(.system(size: 18, weight: .semibold, design: .rounded))
                        .multilineTextAlignment(.leading)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    Circle()
                        .fill(selected ? ReadLabStyle.blue : ReadLabStyle.muted)
                        .frame(width: 20, height: 20)
                }
                Spacer(minLength: 0)
                Text(subtitle)
                    .font(.system(size: 12, design: .rounded))
                    .foregroundStyle(ReadLabStyle.ink.opacity(0.78))
                    .multilineTextAlignment(.leading)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .foregroundStyle(ReadLabStyle.ink)
            .padding(20)
            .frame(maxWidth: .infinity, minHeight: 126, maxHeight: 126)
            .background(.white, in: RoundedRectangle(cornerRadius: 24))
            .overlay {
                RoundedRectangle(cornerRadius: 24)
                    .strokeBorder(selected ? ReadLabStyle.blue : .clear, lineWidth: 4)
            }
            .shadow(color: .black.opacity(0.14), radius: 5, y: 4)
        }
        .buttonStyle(ReadLabTapStyle())
        .accessibilityElement(children: .combine)
        .accessibilityAddTraits(selected ? .isSelected : [])
    }
}

/// Layout for the final three steps, including an anchored bottom action.
struct ReadLabStepLayout<Content: View>: View {
    let step: Int
    let yellow: Bool
    let onBack: () -> Void
    let actionTitle: String
    let actionEnabled: Bool
    let onAction: () -> Void
    let content: (Bool) -> Content

    init(
        step: Int,
        yellow: Bool,
        onBack: @escaping () -> Void,
        actionTitle: String,
        actionEnabled: Bool,
        onAction: @escaping () -> Void,
        @ViewBuilder content: @escaping (Bool) -> Content
    ) {
        self.step = step
        self.yellow = yellow
        self.onBack = onBack
        self.actionTitle = actionTitle
        self.actionEnabled = actionEnabled
        self.onAction = onAction
        self.content = content
    }

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var appeared = false

    var body: some View {
        GeometryReader { geometry in
            let compact = geometry.size.width < 900
            ZStack {
                ReadLabPastelBackground(yellow: yellow)

                VStack(spacing: 0) {
                    ReadLabStepHeader(step: step, onBack: onBack)
                        .padding(.top, compact ? 12 : 18)
                        .padding(.horizontal, compact ? 36 : max(52, geometry.size.width * 0.18))

                    ScrollView {
                        content(compact)
                            .frame(maxWidth: 900, alignment: .leading)
                            .frame(maxWidth: .infinity)
                            .padding(.horizontal, compact ? 35 : 40)
                            .padding(.bottom, 30)
                    }
                    .scrollIndicators(.hidden)
                    .scrollDismissesKeyboard(.interactively)
                    .opacity(appeared ? 1 : 0)
                    .offset(y: appeared ? 0 : 14)
                    .safeAreaInset(edge: .bottom) {
                        HStack {
                            Spacer()
                            ReadLabActionButton(title: actionTitle, action: onAction, enabled: actionEnabled)
                        }
                        .frame(maxWidth: 900)
                        .frame(maxWidth: .infinity)
                        .padding(.horizontal, compact ? 35 : 40)
                        .padding(.top, 14)
                        .padding(.bottom, 18)
                    }
                }
            }
        }
        .preferredColorScheme(.light)
        .onAppear {
            withAnimation(reduceMotion ? nil : .spring(response: 0.6, dampingFraction: 0.85)) {
                appeared = true
            }
        }
    }
}
