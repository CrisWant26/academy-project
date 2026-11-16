import SwiftUI

/// A single navigation owner keeps all six onboarding screens in sync.
struct ReadingSupportOnboarding: View {
    @State private var path: [Step] = []
    @State private var profile = ReadLabChildProfile()
    @State private var learningPreferences = ReadLabLearningPreferences()
    @State private var specialist = ReadLabSpecialistInfo()
    @State private var focus: Set<ReadLabReadingFocus> = [.recognition, .fluency]

    private enum Step: Hashable {
        case childProfile, learningDifferences, specialist, focus, summary, completed
    }

    var body: some View {
        NavigationStack(path: $path) {
            ReadLabWelcomeView { path.append(.childProfile) }
                .navigationDestination(for: Step.self) { step in
                    switch step {
                    case .childProfile:
                        ReadLabChildProfileView(profile: $profile, onBack: goBack) {
                            path.append(.learningDifferences)
                        }
                    case .learningDifferences:
                        ReadLabLearningDifferencesView(preferences: $learningPreferences, onBack: goBack) {
                            path.append(.specialist)
                        }
                    case .specialist:
                        ReadLabSpecialistView(specialist: $specialist, onBack: goBack) {
                            path.append(.focus)
                        }
                    case .focus:
                        ReadLabFocusView(selected: $focus, onBack: goBack) {
                            path.append(.summary)
                        }
                    case .summary:
                        ReadLabSummaryView(
                            profile: profile,
                            preferences: learningPreferences,
                            specialist: specialist,
                            selectedFocus: focus,
                            onBack: goBack,
                            onEditProfile: { navigateBack(to: .childProfile) },
                            onEditLearning: { navigateBack(to: .learningDifferences) },
                            onEditSpecialist: { navigateBack(to: .specialist) },
                            onEditFocus: { navigateBack(to: .focus) },
                            onDone: { path.append(.completed) }
                        )
                    case .completed:
                        completionView
                    }
                }
                .toolbar(.hidden, for: .navigationBar)
        }
    }

    private var completionView: some View {
        VStack(spacing: 22) {
            Image(systemName: "book")
                .font(.system(size: 76))
                .foregroundStyle(ReadLabStyle.blue)
            Text("You're all set!")
                .font(.system(size: 46, weight: .semibold, design: .rounded))
            Text("\(profile.childName)'s reading journey can begin.")
                .font(.title3)
            Text("Connect your reading library here when the next part of the app is ready.")
                .font(.body)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
            Button("Review setup") { navigateBack(to: .summary) }
                .buttonStyle(.borderedProminent)
                .tint(ReadLabStyle.blue)
        }
    }

    private func goBack() {
        guard !path.isEmpty else { return }
        path.removeLast()
    }

    private func navigateBack(to step: Step) {
        guard let index = path.firstIndex(of: step) else { return }
        path = Array(path.prefix(through: index))
    }
}

#Preview("Six-screen onboarding") {
    ReadingSupportOnboarding()
}
