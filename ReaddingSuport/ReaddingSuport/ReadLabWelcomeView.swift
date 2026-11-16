import SwiftUI

/// First screen of Reading Support / ReadLab.
/// iPadOS 17+, no third-party packages or image assets required.
struct ReadLabWelcomeView: View {
    var onGetStarted: () -> Void

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var hasAppeared = false

    private let ink = Color(red: 0.14, green: 0.21, blue: 0.25)
    private let blue = Color(red: 0.44, green: 0.80, blue: 0.97)

    var body: some View {
        GeometryReader { geometry in
            let isPortrait = geometry.size.height > geometry.size.width

            ZStack {
                Color(red: 0.965, green: 0.975, blue: 0.978)
                    .ignoresSafeArea()

                organicBackground
                    .ignoresSafeArea()
                    .accessibilityHidden(true)

                VStack(spacing: 0) {
                    pageIndicator
                        .padding(.top, isPortrait ? 22 : 38)

                    if isPortrait {
                        portraitLayout(in: geometry.size)
                    } else {
                        landscapeLayout(in: geometry.size)
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            .frame(width: geometry.size.width, height: geometry.size.height)
        }
        .preferredColorScheme(.light)
        .onAppear {
            withAnimation(reduceMotion ? nil : .spring(response: 0.8, dampingFraction: 0.86).delay(0.1)) {
                hasAppeared = true
            }
        }
    }

    private var organicBackground: some View {
        GeometryReader { geo in
            let w = geo.size.width
            let h = geo.size.height

            Ellipse()
                .fill(Color(red: 0.74, green: 0.91, blue: 0.79))
                .frame(width: w * 0.58, height: h * 0.79)
                .position(x: w * 0.88, y: h * 0.11)

            Ellipse()
                .fill(Color(red: 0.76, green: 0.92, blue: 0.94))
                .frame(width: w * 0.90, height: h * 0.66)
                .rotationEffect(.degrees(18))
                .position(x: w * 0.15, y: h * 0.91)

            Ellipse()
                .fill(Color(red: 1.00, green: 0.84, blue: 0.76))
                .frame(width: w * 0.51, height: h * 0.56)
                .rotationEffect(.degrees(-25))
                .position(x: w * 0.87, y: h * 1.02)
        }
    }

    private var pageIndicator: some View {
        HStack(spacing: 12) {
            ForEach(0..<6, id: \.self) { index in
                Circle()
                    .fill(index == 0 ? Color.black : Color.black.opacity(0.27))
                    .frame(width: 8, height: 8)
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Introduction, page 1 of 6")
    }

    private func landscapeLayout(in size: CGSize) -> some View {
        HStack(spacing: 18) {
            copyContent(isPortrait: false)
                .frame(maxWidth: .infinity, alignment: .leading)
                .offset(y: -4)

            ReadLabIcon()
                .frame(width: min(size.width * 0.33, 460),
                       height: min(size.width * 0.33, 460))
                .shadow(color: ink.opacity(0.13), radius: 10, y: 8)
                .frame(maxWidth: .infinity)
                .offset(y: -2)
        }
        .padding(.leading, max(50, size.width * 0.087))
        .padding(.trailing, max(35, size.width * 0.055))
        .frame(maxHeight: .infinity)
        .opacity(hasAppeared ? 1 : 0)
        .offset(y: hasAppeared ? 0 : 18)
    }

    private func portraitLayout(in size: CGSize) -> some View {
        VStack(spacing: 32) {
            ReadLabIcon()
                .frame(width: min(size.width * 0.48, 370),
                       height: min(size.width * 0.48, 370))
                .shadow(color: ink.opacity(0.12), radius: 10, y: 8)
                .padding(.top, 34)

            copyContent(isPortrait: true)
                .frame(maxWidth: 620, alignment: .leading)

            Spacer(minLength: 0)
        }
        .padding(.horizontal, max(44, size.width * 0.09))
        .frame(maxHeight: .infinity)
        .opacity(hasAppeared ? 1 : 0)
        .offset(y: hasAppeared ? 0 : 18)
    }

    private func copyContent(isPortrait: Bool) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("Learn to read with")
                .font(.system(size: isPortrait ? 48 : 65, weight: .regular, design: .rounded))
                .tracking(-2.1)
                .minimumScaleFactor(0.7)
                .lineLimit(1)

            Text("ReadLab.")
                .font(.system(size: isPortrait ? 58 : 70, weight: .bold, design: .rounded))
                .tracking(-2.2)

            Text("A reading journey designed around\neach child's pace and individual needs.")
                .font(.system(size: isPortrait ? 24 : 27, weight: .light, design: .rounded))
                .lineSpacing(5)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.top, isPortrait ? 30 : 75)

            HStack(spacing: 38) {
                Button(action: onGetStarted) {
                    Text("Get Started")
                        .font(.system(size: 24, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)
                        .frame(width: isPortrait ? 235 : 265, height: 85)
                        .background(blue, in: Capsule())
                        .shadow(color: ink.opacity(0.18), radius: 5, y: 4)
                }
                .buttonStyle(WelcomePressStyle())
                .accessibilityHint("Continue to the next introduction screen")

                Text("About 2 minutes")
                    .font(.system(size: 19, weight: .regular, design: .rounded))
                    .fixedSize()
            }
            .padding(.top, isPortrait ? 36 : 64)

            Rectangle()
                .fill(ink.opacity(0.3))
                .frame(height: 1)
                .padding(.top, isPortrait ? 48 : 64)

            HStack(alignment: .top, spacing: 0) {
                feature("4+", subtitle: "Years")
                feature("Playful", subtitle: "Environment")
                feature("Effort", subtitle: "No grades")
            }
            .padding(.top, 42)
        }
        .foregroundStyle(ink)
    }

    private func feature(_ title: String, subtitle: String) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.system(size: 27, weight: .medium, design: .rounded))
            Text(subtitle)
                .font(.system(size: 18, weight: .light, design: .rounded))
                .foregroundStyle(ink.opacity(0.75))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

private struct WelcomePressStyle: ButtonStyle {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed && !reduceMotion ? 0.96 : 1)
            .opacity(configuration.isPressed ? 0.88 : 1)
            .animation(.spring(response: 0.25, dampingFraction: 0.68), value: configuration.isPressed)
    }
}

/// An all-SwiftUI approximation of the supplied ReadLab mark.
/// Can be replaced by the exact logo asset later without changing the layout.
private struct ReadLabIcon: View {
    var body: some View {
        GeometryReader { geo in
            let s = geo.size.width

            ZStack {
                RoundedRectangle(cornerRadius: s * 0.24, style: .continuous)
                    .fill(LinearGradient(
                        colors: [Color(red: 0.59, green: 0.86, blue: 0.98),
                                 Color(red: 0.37, green: 0.75, blue: 0.94)],
                        startPoint: .topLeading, endPoint: .bottomTrailing
                    ))
                    .overlay {
                        RoundedRectangle(cornerRadius: s * 0.24, style: .continuous)
                            .strokeBorder(.white.opacity(0.68), lineWidth: 3)
                    }

                // Open-book silhouette
                Image(systemName: "book.fill")
                    .resizable()
                    .scaledToFit()
                    .foregroundStyle(.white)
                    .frame(width: s * 0.67, height: s * 0.60)
                    .offset(y: s * 0.14)
                    .shadow(color: Color.blue.opacity(0.15), radius: 2, y: 3)

                // Child silhouette above the open book
                Circle()
                    .fill(.white)
                    .frame(width: s * 0.155, height: s * 0.155)
                    .offset(y: -s * 0.31)

                Capsule()
                    .fill(.white)
                    .frame(width: s * 0.16, height: s * 0.34)
                    .offset(y: -s * 0.095)

                Capsule()
                    .fill(.white)
                    .frame(width: s * 0.075, height: s * 0.30)
                    .rotationEffect(.degrees(-45))
                    .offset(x: -s * 0.14, y: -s * 0.195)

                Capsule()
                    .fill(.white)
                    .frame(width: s * 0.075, height: s * 0.30)
                    .rotationEffect(.degrees(45))
                    .offset(x: s * 0.14, y: -s * 0.195)
            }
        }
        .aspectRatio(1, contentMode: .fit)
        .accessibilityHidden(true)
    }
}

#Preview("iPad Landscape", traits: .fixedLayout(width: 1366, height: 1024)) {
    ReadLabWelcomeView(onGetStarted: {})
}

#Preview("iPad Portrait", traits: .fixedLayout(width: 820, height: 1180)) {
    ReadLabWelcomeView(onGetStarted: {})
}
