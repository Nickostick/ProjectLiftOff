import SwiftUI

/// Authentication view for login and signup - Premium dark theme
struct AuthenticationView: View {
    @StateObject private var viewModel = AuthViewModel()
    @FocusState private var focusedField: Field?

    enum Field {
        case email, password, confirmPassword, displayName
    }

    var body: some View {
        ZStack {
            // Dark background
            AppTheme.darkBackground.ignoresSafeArea()

            ScrollView {
                VStack(spacing: 32) {
                    // Logo and Title
                    VStack(spacing: 16) {
                        ZStack {
                            Circle()
                                .fill(AppTheme.neonGreen.opacity(0.15))
                                .frame(width: 120, height: 120)

                            Image(systemName: "figure.strengthtraining.traditional")
                                .font(.system(size: 60))
                                .foregroundStyle(AppTheme.neonGreen)
                        }

                        Text("ProjectLiftOff")
                            .font(.system(size: 32, weight: .bold, design: .rounded))
                            .foregroundStyle(AppTheme.textPrimary)

                        Text(viewModel.isSignUpMode ? "Create an account to get started" : "Welcome back!")
                            .font(AppTheme.Typography.callout)
                            .foregroundStyle(AppTheme.textSecondary)
                    }
                    .padding(.top, 60)

                    // Form
                    VStack(spacing: 16) {
                        if viewModel.isSignUpMode {
                            CustomTextField(
                                icon: "person.fill",
                                placeholder: "Display Name (optional)",
                                text: $viewModel.displayName
                            )
                            .textContentType(.name)
                            .autocapitalization(.words)
                            .focused($focusedField, equals: .displayName)
                            .submitLabel(.next)
                            .onSubmit { focusedField = .email }
                        }

                        CustomTextField(
                            icon: "envelope.fill",
                            placeholder: "Email",
                            text: $viewModel.email
                        )
                        .textContentType(.emailAddress)
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                        .autocorrectionDisabled()
                        .focused($focusedField, equals: .email)
                        .submitLabel(.next)
                        .onSubmit { focusedField = .password }

                        CustomSecureField(
                            icon: "lock.fill",
                            placeholder: "Password",
                            text: $viewModel.password
                        )
                        .textContentType(viewModel.isSignUpMode ? .newPassword : .password)
                        .focused($focusedField, equals: .password)
                        .submitLabel(viewModel.isSignUpMode ? .next : .go)
                        .onSubmit {
                            if viewModel.isSignUpMode {
                                focusedField = .confirmPassword
                            } else {
                                Task { await viewModel.signIn() }
                            }
                        }

                        if viewModel.isSignUpMode {
                            CustomSecureField(
                                icon: "lock.shield.fill",
                                placeholder: "Confirm Password",
                                text: $viewModel.confirmPassword
                            )
                            .textContentType(.newPassword)
                            .focused($focusedField, equals: .confirmPassword)
                            .submitLabel(.go)
                            .onSubmit {
                                Task { await viewModel.signUp() }
                            }
                        }
                    }
                    .padding(.horizontal, AppTheme.Layout.screenPadding)

                    // Action Buttons
                    VStack(spacing: 16) {
                        Button(action: {
                            Task {
                                if viewModel.isSignUpMode {
                                    await viewModel.signUp()
                                } else {
                                    await viewModel.signIn()
                                }
                            }
                        }) {
                            HStack(spacing: 12) {
                                if viewModel.isLoading {
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle(tint: AppTheme.darkBackground))
                                } else {
                                    Image(systemName: viewModel.isSignUpMode ? "person.badge.plus" : "arrow.right.circle.fill")
                                        .font(.system(size: 20))
                                    Text(viewModel.isSignUpMode ? "Create Account" : "Sign In")
                                        .font(AppTheme.Typography.headline)
                                }
                            }
                            .foregroundStyle(AppTheme.darkBackground)
                            .frame(maxWidth: .infinity)
                            .frame(height: 56)
                            .background(
                                viewModel.isFormValid && !viewModel.isLoading
                                    ? AppTheme.neonGreen
                                    : AppTheme.textTertiary
                            )
                            .cornerRadius(AppTheme.Layout.buttonCornerRadius)
                        }
                        .disabled(!viewModel.isFormValid || viewModel.isLoading)
                        .padding(.horizontal, AppTheme.Layout.screenPadding)

                        if !viewModel.isSignUpMode {
                            Button("Forgot Password?") {
                                viewModel.resetPasswordEmail = viewModel.email
                                viewModel.showResetPasswordAlert = true
                            }
                            .font(AppTheme.Typography.callout)
                            .foregroundStyle(AppTheme.neonGreen)
                        }
                    }

                    // Toggle Mode
                    HStack(spacing: 4) {
                        Text(viewModel.isSignUpMode ? "Already have an account?" : "Don't have an account?")
                            .foregroundStyle(AppTheme.textSecondary)

                        Button(viewModel.isSignUpMode ? "Sign In" : "Sign Up") {
                            withAnimation(AppTheme.Animation.spring) {
                                viewModel.toggleMode()
                            }
                        }
                        .fontWeight(.semibold)
                        .foregroundStyle(AppTheme.neonGreen)
                    }
                    .font(AppTheme.Typography.callout)

                    Spacer(minLength: 50)
                }
            }
        }
        .alert("Error", isPresented: $viewModel.showError) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(viewModel.errorMessage)
        }
        .alert("Reset Password", isPresented: $viewModel.showResetPasswordAlert) {
            TextField("Email", text: $viewModel.resetPasswordEmail)
                .textContentType(.emailAddress)
                .keyboardType(.emailAddress)
                .autocapitalization(.none)

            Button("Send Reset Link") {
                Task { await viewModel.resetPassword() }
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Enter your email to receive a password reset link.")
        }
    }
}

// MARK: - Custom Text Field

struct CustomTextField: View {
    let icon: String
    let placeholder: String
    @Binding var text: String

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 18))
                .foregroundStyle(AppTheme.textSecondary)
                .frame(width: 24)

            TextField(placeholder, text: $text)
                .font(AppTheme.Typography.body)
                .foregroundStyle(AppTheme.textPrimary)
        }
        .padding(16)
        .background(AppTheme.cardBackground)
        .cornerRadius(AppTheme.Layout.cardCornerRadius)
    }
}

// MARK: - Custom Secure Field

struct CustomSecureField: View {
    let icon: String
    let placeholder: String
    @Binding var text: String

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 18))
                .foregroundStyle(AppTheme.textSecondary)
                .frame(width: 24)

            SecureField(placeholder, text: $text)
                .font(AppTheme.Typography.body)
                .foregroundStyle(AppTheme.textPrimary)
        }
        .padding(16)
        .background(AppTheme.cardBackground)
        .cornerRadius(AppTheme.Layout.cardCornerRadius)
    }
}

#Preview {
    AuthenticationView()
}
