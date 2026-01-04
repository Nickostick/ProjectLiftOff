import SwiftUI

/// Authentication view for login and signup
struct AuthenticationView: View {
    @StateObject private var viewModel = AuthViewModel()
    @FocusState private var focusedField: Field?
    
    enum Field {
        case email, password, confirmPassword, displayName
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 32) {
                    // Logo and Title
                    VStack(spacing: 16) {
                        Image(systemName: "figure.strengthtraining.traditional")
                            .font(.system(size: 80))
                            .foregroundStyle(.blue.gradient)
                        
                        Text("Workout Tracker")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                        
                        Text(viewModel.isSignUpMode ? "Create an account to get started" : "Welcome back!")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.top, 40)
                    
                    // Form
                    VStack(spacing: 16) {
                        if viewModel.isSignUpMode {
                            TextField("Display Name (optional)", text: $viewModel.displayName)
                                .textFieldStyle(.roundedBorder)
                                .textContentType(.name)
                                .autocapitalization(.words)
                                .focused($focusedField, equals: .displayName)
                                .submitLabel(.next)
                                .onSubmit { focusedField = .email }
                        }
                        
                        TextField("Email", text: $viewModel.email)
                            .textFieldStyle(.roundedBorder)
                            .textContentType(.emailAddress)
                            .keyboardType(.emailAddress)
                            .autocapitalization(.none)
                            .autocorrectionDisabled()
                            .focused($focusedField, equals: .email)
                            .submitLabel(.next)
                            .onSubmit { focusedField = .password }
                        
                        SecureField("Password", text: $viewModel.password)
                            .textFieldStyle(.roundedBorder)
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
                            SecureField("Confirm Password", text: $viewModel.confirmPassword)
                                .textFieldStyle(.roundedBorder)
                                .textContentType(.newPassword)
                                .focused($focusedField, equals: .confirmPassword)
                                .submitLabel(.go)
                                .onSubmit {
                                    Task { await viewModel.signUp() }
                                }
                        }
                    }
                    .padding(.horizontal)
                    
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
                            if viewModel.isLoading {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            } else {
                                Text(viewModel.isSignUpMode ? "Sign Up" : "Sign In")
                                    .fontWeight(.semibold)
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(viewModel.isFormValid ? Color.blue : Color.gray)
                        .foregroundStyle(.white)
                        .cornerRadius(Constants.UI.cornerRadius)
                        .disabled(!viewModel.isFormValid || viewModel.isLoading)
                        .padding(.horizontal)
                        
                        if !viewModel.isSignUpMode {
                            Button("Forgot Password?") {
                                viewModel.resetPasswordEmail = viewModel.email
                                viewModel.showResetPasswordAlert = true
                            }
                            .font(.subheadline)
                            .foregroundStyle(.blue)
                        }
                    }
                    
                    // Toggle Mode
                    HStack {
                        Text(viewModel.isSignUpMode ? "Already have an account?" : "Don't have an account?")
                            .foregroundStyle(.secondary)
                        
                        Button(viewModel.isSignUpMode ? "Sign In" : "Sign Up") {
                            withAnimation {
                                viewModel.toggleMode()
                            }
                        }
                        .fontWeight(.semibold)
                    }
                    .font(.subheadline)
                    
                    Spacer(minLength: 50)
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
}

#Preview {
    AuthenticationView()
}
