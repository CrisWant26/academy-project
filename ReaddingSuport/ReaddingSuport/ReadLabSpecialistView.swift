import SwiftUI

struct ReadLabSpecialistInfo: Equatable {
    var isFollowedBySpecialist = false
    var profession = ""
    var name = ""
}

struct ReadLabSpecialistView: View {
    @Binding var specialist: ReadLabSpecialistInfo
    let onBack: () -> Void
    let onContinue: () -> Void

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        ReadLabStepLayout(
            step: 4,
            yellow: true,
            onBack: onBack,
            actionTitle: "Continue",
            actionEnabled: true,
            onAction: onContinue
        ) { compact in
            VStack(alignment: .leading, spacing: compact ? 44 : 70) {
                Text("Is your child followed by\na specialist?")
                    .font(.system(size: compact ? 46 : 66, weight: .regular, design: .rounded))
                    .tracking(-1.8)
                    .foregroundStyle(ReadLabStyle.ink)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.top, compact ? 48 : 68)
                    .accessibilityAddTraits(.isHeader)

                VStack(alignment: .leading, spacing: 60) {
                    if compact {
                        VStack(spacing: 18) { choices }
                    } else {
                        HStack(spacing: 20) { choices }
                            .frame(maxWidth: 580)
                    }

                    ViewThatFits(in: .horizontal) {
                        HStack(spacing: 20) { fields }
                        VStack(spacing: 20) { fields }
                    }
                    .frame(maxWidth: 580)
                }
            }
        }
    }

    @ViewBuilder
    private var choices: some View {
        ReadLabChoiceCard(
            title: "Yes",
            subtitle: "My child is followed by a specialist.",
            selected: specialist.isFollowedBySpecialist
        ) { choose(true) }
        ReadLabChoiceCard(
            title: "No",
            subtitle: "My child is not followed by a specialist.",
            selected: !specialist.isFollowedBySpecialist
        ) { choose(false) }
    }

    private func choose(_ value: Bool) {
        withAnimation(reduceMotion ? nil : .spring(response: 0.3, dampingFraction: 0.85)) {
            specialist.isFollowedBySpecialist = value
        }
    }

    @ViewBuilder
    private var fields: some View {
        input("SPECIALIST PROFESSION", placeholder: "e.g. Speech and Language Therapist", text: $specialist.profession)
        input("SPECIALIST NAME", placeholder: "e.g. Dr. Schettino", text: $specialist.name)
    }

    private func input(_ label: String, placeholder: String, text: Binding<String>) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(label)
                .font(.system(size: 10, weight: .semibold, design: .rounded))
                .foregroundStyle(ReadLabStyle.ink)
            TextField(placeholder, text: text)
                .font(.system(size: 14, design: .rounded))
                .padding(.horizontal, 19)
                .frame(height: 62)
                .background(.white, in: RoundedRectangle(cornerRadius: 17))
                .shadow(color: .black.opacity(0.13), radius: 5, y: 4)
                .textInputAutocapitalization(.words)
                .disabled(!specialist.isFollowedBySpecialist)
                .opacity(specialist.isFollowedBySpecialist ? 1 : 0.58)
                .accessibilityLabel(label.capitalized)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

#Preview("Specialist") {
    ReadLabSpecialistView(specialist: .constant(.init()), onBack: {}, onContinue: {})
}
