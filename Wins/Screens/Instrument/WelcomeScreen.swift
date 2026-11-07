import SwiftUI
import AuthenticationServices

// MARK: - Welcome: sign up and log in are the same screen
//
// SSO only: "Continue with Apple" and "Continue with Google". New users get an account, returning users
// are signed in. App Store guideline 4.8 requires Sign in with Apple whenever Google sign-in is offered.
// The real build uses the official Google button asset from the GoogleSignIn SDK; the "G" here is a stand-in.

struct WelcomeInstrumentScreen: View {
    @Environment(\.colorScheme) private var scheme

    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: Spacing.xs) {
                Text("66wins").textStyle(.headline).foregroundStyle(Theme.textPrimary)
                Spacer()
            }
            .padding(.horizontal, Layout.margin)
            .padding(.top, Spacing.sm)

            Spacer(minLength: Spacing.md)

            DayDial(wins: TonightStory.wins, size: 236,
                    states: Dictionary(uniqueKeysWithValues: TonightStory.wins.map { ($0.id, DialSegmentState.dimmed) }),
                    nowHour: 6.5) {
                VStack(spacing: 0) {
                    Text("66").textStyle(.numeralHero).foregroundStyle(Theme.textPrimary)
                    Text("days to make it yours").textStyle(.caption).foregroundStyle(Theme.textSecondary)
                }
            }

            VStack(spacing: Spacing.xs) {
                Text("Plan tonight.\nWin tomorrow.")
                    .textStyle(.reason)
                    .foregroundStyle(Theme.textPrimary)
                    .multilineTextAlignment(.center)
                Text("One tap to start. Your days stay safe on every device.")
                    .textStyle(.body)
                    .foregroundStyle(Theme.textSecondary)
                    .multilineTextAlignment(.center)
            }
            .padding(.top, Spacing.lg)
            .padding(.horizontal, Layout.margin)

            Spacer(minLength: Spacing.lg)

            VStack(spacing: Spacing.sm) {
                SignInWithAppleButton(.continue, onRequest: { _ in }, onCompletion: { _ in })
                    .signInWithAppleButtonStyle(scheme == .dark ? .white : .black)
                    .frame(height: Layout.primaryHeight)
                    .clipShape(Capsule())

                Button {} label: {
                    HStack(spacing: Spacing.xs) {
                        GoogleMark()
                        Text("Continue with Google")
                    }
                    .textStyle(.button)
                    .frame(maxWidth: .infinity, minHeight: Layout.primaryHeight)
                }
                .buttonStyle(.glass)
                .buttonBorderShape(.capsule)
                .tint(Theme.textPrimary)

                Text("By continuing you agree to the Terms and Privacy Policy.")
                    .textStyle(.caption)
                    .foregroundStyle(Theme.textTertiary)
                    .multilineTextAlignment(.center)
                    .padding(.top, Spacing.xs)
            }
            .padding(.horizontal, Layout.margin)
            .padding(.bottom, Spacing.xs)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .screenBackground()
    }
}

/// Stand-in for Google's official "G" mark (replaced by the SDK asset in the real build).
private struct GoogleMark: View {
    var body: some View {
        ZStack {
            Circle().fill(Color.white)
            Text("G").font(.system(size: 13, weight: .bold)).foregroundStyle(Color(red: 0.26, green: 0.52, blue: 0.96))
        }
        .frame(width: 22, height: 22)
        .accessibilityHidden(true)
    }
}

#Preview("Welcome") { WelcomeInstrumentScreen().preferredColorScheme(.dark) }
