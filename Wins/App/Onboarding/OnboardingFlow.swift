import SwiftUI
import SwiftData
import AuthenticationServices

// MARK: - First open: Welcome → Your rhythm → Your reason → Your topics
//
// About 90 seconds. Every answer is only a starting point; all of it can be changed later.

struct OnboardingFlow: View {
    @Environment(\.modelContext) private var context
    let profile: Profile?

    @State private var step: Step = .welcome
    @State private var message: String?

    enum Step { case welcome, rhythm, reason, topics }

    var body: some View {
        Group {
            switch step {
            case .welcome:
                WelcomeInstrumentScreen(
                    onApple: handleApple,
                    onGoogle: { message = GoogleAuth.notReadyMessage },
                    onSkip: debugSkip,
                    message: message)
            case .rhythm:
                RhythmStep(profile: ensureProfile()) { step = .reason }
            case .reason:
                ReasonStep(profile: ensureProfile()) { step = .topics }
            case .topics:
                TopicsStep(profile: ensureProfile()) { finish() }
            }
        }
        .animation(.smooth(duration: 0.3), value: step)
        .onAppear {
            if let p = profile, !p.userID.isEmpty { step = .rhythm }
        }
    }

    private var debugSkip: (() -> Void)? {
        #if DEBUG
        return { signIn(provider: "local", userID: UUID().uuidString, name: "") }
        #else
        return nil
        #endif
    }

    private func handleApple(_ result: Result<ASAuthorization, Error>) {
        switch result {
        case .success(let auth):
            guard let cred = auth.credential as? ASAuthorizationAppleIDCredential else { return }
            let name = cred.fullName?.givenName ?? ""
            signIn(provider: "apple", userID: cred.user, name: name)
        case .failure(let error):
            if (error as? ASAuthorizationError)?.code == .canceled { return }
            message = "Apple sign-in didn't work on this build. \(error.localizedDescription)"
        }
    }

    private func signIn(provider: String, userID: String, name: String) {
        let p = ensureProfile()
        p.provider = provider
        p.userID = userID
        if !name.isEmpty { p.name = name }
        try? context.save()
        step = .rhythm
    }

    @discardableResult
    private func ensureProfile() -> Profile {
        if let profile { return profile }
        let p = Profile()
        context.insert(p)
        return p
    }

    private func finish() {
        let p = ensureProfile()
        p.onboarded = true
        try? context.save()
        Task {
            await Reminders.requestPermission()
            Reminders.reschedule(plan: nil, profile: p)
        }
    }
}

/// Google sign-in needs an OAuth client ID from Google Cloud for this app's bundle ID.
enum GoogleAuth {
    static let notReadyMessage = "Google sign-in is switched on once its client ID is added to the app."
}

// MARK: - Shared step layout

struct StepScaffold<Content: View>: View {
    let index: Int
    let title: String
    let subtitle: String
    let buttonTitle: String
    var canContinue: Bool = true
    let onNext: () -> Void
    @ViewBuilder let content: () -> Content

    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: Spacing.xxs) {
                ForEach(0..<3, id: \.self) { i in
                    Capsule()
                        .fill(i <= index ? Theme.textPrimary : Theme.markTrack)
                        .frame(height: 3)
                }
            }
            .padding(.horizontal, Layout.margin)
            .padding(.top, Spacing.sm)

            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    Text(title)
                        .textStyle(.reason)
                        .foregroundStyle(Theme.textPrimary)
                        .fixedSize(horizontal: false, vertical: true)
                    Text(subtitle)
                        .textStyle(.body)
                        .foregroundStyle(Theme.textSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                        .padding(.top, Spacing.xs)
                    content()
                        .padding(.top, Spacing.xl)
                }
                .padding(.horizontal, Layout.margin)
                .padding(.top, Spacing.xl)
                .padding(.bottom, Spacing.lg)
            }
            .scrollIndicators(.hidden)
            .scrollDismissesKeyboard(.interactively)

            PrimaryButton(title: buttonTitle, systemImage: "arrow.right", action: onNext)
                .disabled(!canContinue)
                .opacity(canContinue ? 1 : 0.4)
                .padding(.horizontal, Layout.margin)
                .padding(.top, Spacing.sm)
                .padding(.bottom, Spacing.xs)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .screenBackground()
    }
}

/// A row with an icon, a label and a time picker bound to an hour value.
struct HourRow: View {
    let systemImage: String
    let label: String
    @Binding var hour: Double

    var body: some View {
        HStack(spacing: Spacing.md) {
            Image(systemName: systemImage)
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(Theme.textSecondary)
                .frame(width: 28)
            Text(label)
                .textStyle(.headline)
                .foregroundStyle(Theme.textPrimary)
            Spacer()
            DatePicker(label, selection: Binding(
                get: { DayKey.hourDate(hour) },
                set: { hour = DayKey.hour($0) }),
                displayedComponents: .hourAndMinute)
                .labelsHidden()
        }
        .frame(minHeight: 52)
    }
}

// MARK: - 1. Your rhythm (3 questions)

struct RhythmStep: View {
    @Bindable var profile: Profile
    let onNext: () -> Void

    var body: some View {
        StepScaffold(index: 0, title: "Your rhythm",
                     subtitle: "Three answers place your day on the dial. You can change them any time.",
                     buttonTitle: "Next", onNext: {
                         // Eight hours of sleep before the wake time.
                         profile.sleep = (profile.wake - 8 + 24).truncatingRemainder(dividingBy: 24)
                         onNext()
                     }) {
            VStack(alignment: .leading, spacing: Spacing.lg) {
                VStack(spacing: 0) {
                    HourRow(systemImage: "alarm.fill", label: "I wake up at", hour: $profile.wake)
                    Divider().overlay(Theme.separator)
                    HourRow(systemImage: "briefcase.fill", label: "Work starts", hour: $profile.workStart)
                    Divider().overlay(Theme.separator)
                    HourRow(systemImage: "briefcase", label: "Work ends", hour: $profile.workEnd)
                }

                Text("I have the most energy")
                    .textStyle(.eyebrow)
                    .foregroundStyle(Theme.textSecondary)
                HStack(spacing: Spacing.sm) {
                    choice(true, "In the morning", "sunrise.fill")
                    choice(false, "In the evening", "moon.stars.fill")
                }
            }
        }
    }

    private func choice(_ morning: Bool, _ title: String, _ symbol: String) -> some View {
        let on = profile.isMorningPerson == morning
        return Button {
            profile.isMorningPerson = morning
        } label: {
            VStack(alignment: .leading, spacing: Spacing.sm) {
                Image(systemName: symbol).font(.system(size: 20, weight: .semibold))
                Text(title).textStyle(.headline)
            }
            .foregroundStyle(on ? Theme.textPrimary : Theme.textSecondary)
            .frame(maxWidth: .infinity, minHeight: 96, alignment: .leading)
            .padding(Spacing.md)
            .background(Theme.surfaceRaised, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
            .overlay(RoundedRectangle(cornerRadius: 18, style: .continuous)
                .strokeBorder(on ? Theme.accent : .clear, lineWidth: 2))
        }
        .buttonStyle(.plain)
        .sensoryFeedback(.selection, trigger: on)
    }
}

// MARK: - 2. Your reason

struct ReasonStep: View {
    @Bindable var profile: Profile
    let onNext: () -> Void
    @FocusState private var focused: Bool

    private let examples = [
        "Finish the first chapter before anyone else is awake.",
        "Be the parent who has energy at 6 pm.",
        "Get strong enough to carry my own bags at 80.",
    ]

    var body: some View {
        StepScaffold(index: 1, title: "Why does tomorrow matter?",
                     subtitle: "One sentence. It's the first thing you see every morning.",
                     buttonTitle: "Next",
                     canContinue: !profile.reason.trimmingCharacters(in: .whitespaces).isEmpty,
                     onNext: onNext) {
            VStack(alignment: .leading, spacing: Spacing.lg) {
                TextField("My reason", text: $profile.reason, axis: .vertical)
                    .textStyle(.reasonCompact)
                    .foregroundStyle(Theme.textPrimary)
                    .lineLimit(2...4)
                    .focused($focused)
                    .padding(Spacing.md)
                    .background(Theme.surfaceRaised, in: RoundedRectangle(cornerRadius: 18, style: .continuous))

                Text("Or start from one of these")
                    .textStyle(.eyebrow)
                    .foregroundStyle(Theme.textSecondary)
                ForEach(examples, id: \.self) { e in
                    Button { profile.reason = e } label: {
                        Text(e)
                            .textStyle(.body)
                            .foregroundStyle(Theme.textSecondary)
                            .multilineTextAlignment(.leading)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .onAppear { focused = profile.reason.isEmpty }
    }
}

// MARK: - 3. Your topics

struct TopicsStep: View {
    @Bindable var profile: Profile
    let onNext: () -> Void

    var body: some View {
        StepScaffold(index: 2, title: "What do you want to win?",
                     subtitle: "Pick what goes on your dial. Fewer is easier to keep.",
                     buttonTitle: "Plan my first day",
                     canContinue: !profile.topicKeys.isEmpty,
                     onNext: onNext) {
            VStack(spacing: Spacing.sm) {
                ForEach(Topic.allCases) { t in
                    topicRow(t)
                }
            }
        }
        .onAppear {
            if profile.topicKeys.isEmpty { profile.topicKeys = Topic.allCases.map(\.rawValue) }
        }
    }

    private func topicRow(_ t: Topic) -> some View {
        let on = profile.topicKeys.contains(t.rawValue)
        return Button {
            if on { profile.topicKeys.removeAll { $0 == t.rawValue } } else { profile.topicKeys.append(t.rawValue) }
        } label: {
            HStack(spacing: Spacing.md) {
                BadgedIcon(systemImage: t.symbol, purpose: t.purpose, size: 40)
                VStack(alignment: .leading, spacing: 2) {
                    Text(t.name).textStyle(.headline).foregroundStyle(Theme.textPrimary)
                    Text(t.why).textStyle(.caption).foregroundStyle(Theme.textSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
                Spacer(minLength: Spacing.xs)
                Image(systemName: on ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 22))
                    .foregroundStyle(on ? Theme.accent : Theme.textTertiary)
            }
            .padding(Spacing.md)
            .background(Theme.surfaceRaised, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
        }
        .buttonStyle(.plain)
        .sensoryFeedback(.selection, trigger: on)
    }
}
