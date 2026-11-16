import SwiftUI

struct ReadLabSummaryView: View {
    let profile: ReadLabChildProfile
    let preferences: ReadLabLearningPreferences
    let specialist: ReadLabSpecialistInfo
    let selectedFocus: Set<ReadLabReadingFocus>
    let onBack: () -> Void
    let onEditProfile: () -> Void
    let onEditLearning: () -> Void
    let onEditSpecialist: () -> Void
    let onEditFocus: () -> Void
    let onDone: () -> Void

    var body: some View {
        ReadLabStepLayout(
            step: 6,
            yellow: true,
            onBack: onBack,
            actionTitle: "Done",
            actionEnabled: true,
            onAction: onDone
        ) { compact in
            VStack(alignment: .leading, spacing: compact ? 36 : 42) {
                Text("Your learning journey\nis finally ready!")
                    .font(.system(size: compact ? 46 : 66, weight: .regular, design: .rounded))
                    .tracking(-1.8)
                    .foregroundStyle(ReadLabStyle.ink)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.top, compact ? 48 : 62)
                    .accessibilityAddTraits(.isHeader)

                VStack(spacing: 0) {
                    summaryRow("Child Name: \(profile.childName)", action: onEditProfile)
                    summaryRow("Child Age: \(profile.ageRange?.rawValue ?? "Not selected")", action: onEditProfile)
                    summaryRow(profile.readingFamiliarity?.rawValue ?? "Reading familiarity not selected", action: onEditProfile)
                    summaryRow(preferences.diagnosis == .diagnosed ? "Diagnosed Learning Difficulty" : "No Diagnosed Learning Difficulties", action: onEditLearning)
                    if specialist.isFollowedBySpecialist {
                        summaryRow("Specialist: \(specialist.name.isEmpty ? "Yes" : specialist.name)", action: onEditSpecialist)
                    }
                    summaryRow(focusSummary, action: onEditFocus, last: true)
                }
                .padding(.horizontal, compact ? 12 : 16)
                .background(.white, in: RoundedRectangle(cornerRadius: 24))
                .frame(maxWidth: 720)
                .frame(maxWidth: .infinity)
            }
        }
    }

    private var focusSummary: String {
        ReadLabReadingFocus.allCases
            .filter { selectedFocus.contains($0) }
            .map(\.rawValue)
            .joined(separator: " – ")
    }

    private func summaryRow(_ title: String, action: @escaping () -> Void, last: Bool = false) -> some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Text(title)
                    .font(.system(size: 17, design: .rounded))
                    .foregroundStyle(.black)
                    .multilineTextAlignment(.leading)
                Spacer(minLength: 8)
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(.gray.opacity(0.7))
            }
            .frame(maxWidth: .infinity, minHeight: 90, alignment: .leading)
            .contentShape(Rectangle())
        }
        .buttonStyle(ReadLabTapStyle())
        .accessibilityHint("Return to edit this information")
        .overlay(alignment: .bottom) {
            if !last {
                Rectangle()
                    .fill(Color.black.opacity(0.12))
                    .frame(height: 1)
            }
        }
    }
}
