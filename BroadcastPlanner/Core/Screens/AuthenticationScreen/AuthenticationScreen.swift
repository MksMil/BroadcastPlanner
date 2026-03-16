import AuthenticationServices
import GoogleSignIn
import GoogleSignInSwift
import SwiftUI

struct AuthenticationScreen: View {
  @EnvironmentObject var sessionManager: SessionManager
  @EnvironmentObject var router: Router

  @State private var email: String = ""
  @State private var password: String = ""

  @FocusState private var focus: Field?

  private enum Field { case email, password }

  var body: some View {
    ZStack {
      MainBackground()
      
      ScrollView {
        ZStack {
          Color.white.opacity(0.01).onTapGesture {
            focus = nil
          }
          
          
          VStack(spacing: 5) {
            
            // MARK: - Logo
            Circle()
              .opacity(0.8)
              .overlay {
                Text("LOGO")
                  .font(.title)
                  .bold()
                  .foregroundStyle(.white)
              }
              .frame(width: 150, height: 150)
            
            Divider()
            
            // MARK: - Fields
            VStack(spacing: 12) {
              AuthInputField(
                placeholder: "E-mail",
                text: $email,
                icon: "envelope",
                keyboardType: .emailAddress,
                returnKeyType: .done,
                showClearButton: true
              )
              .focused($focus, equals: .email)
              
              AuthInputField(
                placeholder: "Password",
                text: $password,
                isSecure: true,
                icon: "lock",
                returnKeyType: .go
              ){
                signIn()
              }
              .focused($focus, equals: .password)
            }
            .padding(.horizontal)
            .padding(.top, 8)
            
            // MARK: - Forgot password
            HStack {
              Spacer()
              Button("Forget password") {
                Task { await sessionManager.sendPasswordReset(to: email) }
              }
              .font(.footnote)
              .disabled(email.isEmpty)
            }
            .padding(.horizontal)
            .padding(.top, 4)
            
            // MARK: - Sign In
            Button(action: signIn) {
              RoundedRectangle(cornerRadius: 8)
                .fill(Color.white.opacity(0.7))
                .overlay {
                  Text("Sign In")
                    .foregroundStyle(.primary)
                    .fontWeight(.medium)
                }
                .frame(height: 46)
                .padding(.horizontal)
            }
            .padding(.vertical, 16)
            .disabled(
              sessionManager.isLoading || email.isEmpty || password.isEmpty
            )
            
            // MARK: - Google
            GoogleSignInButton(
              viewModel: GoogleSignInButtonViewModel(
                scheme: .light,
                style: .wide,
                state: .normal
              )
            ) {
              Task { await sessionManager.signInWithGoogle() }
            }
            .frame(width: 200, height: 44)
            .padding(.bottom, 10)
            
            // MARK: - Apple
            SignInWithAppleButton { request in
              let r = sessionManager.makeAppleRequestSync()
              request.requestedScopes = r.requestedScopes
              request.nonce = r.nonce
            } onCompletion: { result in
              Task { await sessionManager.signInWithApple(result: result) }
            }
            .signInWithAppleButtonStyle(.black)
            .frame(width: 200, height: 44)
            .padding(.bottom, 20)
            
            // MARK: - Sign Up
            Spacer()
            Button {
              router.authPath.append(.signUp)
            } label: {
              Text("Not Registered?   Sign Up!")
                .frame(maxWidth: .infinity)
                .padding()
            }
          }
        }
      }
      .scrollDisabled(true)
      .transitionWithOpacity()
      
      // MARK: - Loading
      if sessionManager.isLoading {
        ProgressView()
          .progressViewStyle(.circular)
          .padding(24)
          .background(
            .ultraThinMaterial,
            in: RoundedRectangle(cornerRadius: 12)
          )
      }
    }
    .ignoresSafeArea(.keyboard)
    .navigationBarBackButtonHidden()
    .alert(item: $sessionManager.alertItem) { alert in
      Alert(
        title: Text(alert.title),
        message: Text(alert.message),
        dismissButton: .default(Text("OK"))
      )
    }
    .onDisappear {
      email = ""
      password = ""
      focus = nil
    }
    .toolbar {
          ToolbarItemGroup(placement: .keyboard) {
            Button(role: .destructive) {
              if focus == .email { email = "" }
              else if focus == .password { password = "" }
            } label: {
              Text("Clear")
            }
            Spacer()
            Button {
              if focus == .email { focus = .password }
              else if focus == .password { focus = nil; signIn() }
            } label: {
              Text("Next")
//              Image(systemName: "arrow.forward.circle.fill")
//                .imageScale(.large)
            }
          }
        }
    .animation(.easeInOut(duration: 1), value: focus)
  }

  private func signIn() {
    focus = nil
    Task { await sessionManager.signIn(email: email, password: password) }
  }
}

// MARK: - Preview
#Preview {
  AuthenticationScreen()
    .environmentObject(SessionManager())
    .environmentObject(Router())
}
