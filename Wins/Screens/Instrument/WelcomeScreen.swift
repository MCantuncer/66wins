import SwiftUI
import AuthenticationServices

// MARK: - Welcome: sign up and log in are the same screen
//
// SSO only: "Continue with Apple" and "Continue with Google". New users get an account, returning users
// are signed in. App Store guideline 4.8 requires Sign in with Apple whenever Google sign-in is offered.
// The real build uses the official Google button asset from the GoogleSignIn SDK; the "G" here is a stand-in.

struct WelcomeInstrumentScreen: View {
    var onApple: (Result<ASAuthorization, Error>) -> Void = { _ in }
    var onGoogle: () -> Void = {}
    /// Debug builds only: continue without an account while sign-in is being set up.
    var onSkip: (() -> Void)? = nil
    var message: String? = nil
    @State private var apple = AppleSignInCoordinator()

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
                SSOButton(title: "Continue with Apple", action: { apple.start(onApple) }) {
                    Image(systemName: "apple.logo")
                        .font(.system(size: 19, weight: .medium))
                        .offset(y: -1)
                }
                SSOButton(title: "Continue with Google", action: onGoogle) {
                    GoogleMark()
                }

                if let message {
                    Text(message)
                        .textStyle(.caption)
                        .foregroundStyle(Theme.textSecondary)
                        .multilineTextAlignment(.center)
                }
                if let onSkip {
                    Button("Continue without an account", action: onSkip)
                        .textStyle(.meta)
                        .foregroundStyle(Theme.textSecondary)
                }
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

/// One style for every sign-in option: same fill, font, height and icon position.
/// The icon sits at a fixed inset on the left; the title is centred on the button.
struct SSOButton<Icon: View>: View {
    let title: String
    let action: () -> Void
    @ViewBuilder let icon: () -> Icon

    var body: some View {
        Button(action: action) {
            ZStack {
                Text(title)
                    .textStyle(.button)
                    .frame(maxWidth: .infinity)
                HStack {
                    icon().frame(width: 22, height: 22)
                    Spacer()
                }
                .padding(.leading, 22)
            }
            .foregroundStyle(Theme.background)
            .frame(maxWidth: .infinity, minHeight: Layout.primaryHeight)
            .background(Theme.textPrimary, in: Capsule())
            .contentShape(Capsule())
        }
        .buttonStyle(.plain)
        .accessibilityLabel(title)
    }
}

/// Runs Sign in with Apple from a custom button.
final class AppleSignInCoordinator: NSObject, ASAuthorizationControllerDelegate,
                                    ASAuthorizationControllerPresentationContextProviding {
    private var completion: (Result<ASAuthorization, Error>) -> Void = { _ in }

    func start(_ completion: @escaping (Result<ASAuthorization, Error>) -> Void) {
        self.completion = completion
        let request = ASAuthorizationAppleIDProvider().createRequest()
        request.requestedScopes = [.fullName]
        let controller = ASAuthorizationController(authorizationRequests: [request])
        controller.delegate = self
        controller.presentationContextProvider = self
        controller.performRequests()
    }

    func authorizationController(controller: ASAuthorizationController,
                                 didCompleteWithAuthorization authorization: ASAuthorization) {
        completion(.success(authorization))
    }

    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        completion(.failure(error))
    }

    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        UIApplication.shared.connectedScenes
            .compactMap { ($0 as? UIWindowScene)?.keyWindow }
            .first ?? ASPresentationAnchor()
    }
}

/// Stand-in for Google's official "G" mark (replaced by the SDK asset in the real build).
private struct GoogleMark: View {
    var body: some View {
        ZStack {
            Circle().fill(Color.white)
            Text("G").font(.system(size: 14, weight: .bold)).foregroundStyle(Color(red: 0.26, green: 0.52, blue: 0.96))
        }
        .frame(width: 22, height: 22)
        .accessibilityHidden(true)
    }
}

#Preview("Welcome") { WelcomeInstrumentScreen().preferredColorScheme(.dark) }
