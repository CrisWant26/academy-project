import SwiftUI

enum ReadLabReadingFocus: String, CaseIterable, Identifiable, Hashable {
    case recognition = "Word Recognition"
    case accuracy = "Reading Accuracy"
    case fluency = "Reading Fluency"

    var id: String { rawValue }
    var detail: String {
        switch self {
        case .recognition: "Recognizing familiar words easily."
        case .accuracy: "Reading words accurately as written in the text."
        case .fluency: "Reading smoothly and regularly."
        }
    }
}

struct ReadLabFocusView: View {
    @Binding var selected: Set<ReadLabReadingFocus>
    let onBack: () -> Void
    let onContinue: () -> Void

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        ReadLabStepLayout(
            step: 5,
            yellow: false,
            onBack: onBack,
            actionTitle: "Continue",
            actionEnabled: !selected.isEmpty,
            onAction: onContinue
        ) { compact in
            VStack(alignment: .leading, spacing: compact ? 54 : 110) {
                VStack(alignment: .leading, spacing: 30) {
                    Text("What would your child\nlike to focus on?")
                        .font(.system(size: compact ? 46 : 66, weight: .regular, design: .rounded))
                        .tracking(-1.8)
                        .foregroundStyle(ReadLabStyle.ink)
                        .fixedSize(horizontal: false, vertical: true)
                        .accessibilityAddTraits(.isHeader)
                    Text("You can choose more than one topic.")
                        .font(.system(size: 20, design: .rounded))
                        .foregroundStyle(ReadLabStyle.ink)
                }
                .padding(.top, compact ? 48 : 68)

                if compact {
                    VStack(spacing: 18) { focusCards }
                } else {
                    HStack(spacing: 16) { focusCards }
                }
            }
        }
    }

    @ViewBuilder
    private var focusCards: some View {
        ForEach(ReadLabReadingFocus.allCases) { focus in
            ReadLabChoiceCard(
                title: focus.rawValue,
                subtitle: focus.detail,
                selected: selected.contains(focus)
            ) {
                withAnimation(reduceMotion ? nil : .spring(response: 0.3, dampingFraction: 0.85)) {
                    if selected.contains(focus) {
                        selected.remove(focus)
                    } else {
                        selected.insert(focus)
                    }
                }
            }
        }
    }
}

#Preview("Focus") {
    ReadLabFocusView(selected: .constant([.recognition, .fluency]), onBack: {}, onContinue: {})
}
