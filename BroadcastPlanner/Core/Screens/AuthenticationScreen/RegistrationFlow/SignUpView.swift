import SwiftUI

struct SignUpView: View {
  @EnvironmentObject var sessionManager: SessionManager
  @EnvironmentObject var router: Router

  @State private var email: String = ""
  @State private var password: String = ""
  @State private var confirmPassword: String = ""

  @FocusState private var focus: Field?

  private enum Field { case email, password, confirm }

  private var passwordsMatch: Bool { password == confirmPassword }
  private var canSubmit: Bool {
    !email.isEmpty && !password.isEmpty && !confirmPassword.isEmpty
      && passwordsMatch && !sessionManager.isLoading
  }

  var body: some View {
    ZStack {
      MainBackground()

      ScrollView {
        ZStack {
          Color.white.opacity(0.01).onTapGesture {
            focus = nil
          }
          VStack(spacing: 16) {

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
              .focused($focus, equals: Field.email)
              
              AuthInputField(
                placeholder: "Password",
                text: $password,
                isSecure: true,
                icon: "lock",
                returnKeyType: .done
              )
              .focused($focus, equals: Field.password)
              
              AuthInputField(
                placeholder: "Confirm password",
                text: $confirmPassword,
                isSecure: true,
                icon: "lock.fill",
                returnKeyType: .go
              ){
//                focus = nil
                signUp()
              }
              .focused($focus, equals: Field.confirm)

              // Подсказка о несовпадении паролей
              if !confirmPassword.isEmpty && !passwordsMatch {
                HStack {
                  Image(systemName: "exclamationmark.circle")
                  Text("Passwords don't match")
                }
                .font(.caption)
                .foregroundStyle(.red)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 4)
                .transition(.opacity)
              }
            }
            .padding()
            .background {
              RoundedRectangle(cornerRadius: 8)
                .fill(Color.white.opacity(0.3))
            }
            .padding(.horizontal)
            .padding(.top, 120)
            .animation(.easeInOut(duration: 0.2), value: passwordsMatch)

            // MARK: - Sign Up
            Button(action: signUp) {
              RoundedRectangle(cornerRadius: 8)
                .fill(.ultraThinMaterial)
                .overlay {
                  RoundedRectangle(cornerRadius: 8)
                    .stroke(.ultraThinMaterial, lineWidth: 1.5)
                }
                .overlay {
                  Text("Sign Up")
                    .font(.title3)
                    .fontWeight(.semibold)
                }
                .frame(maxWidth: .infinity)
                .frame(height: 46)
                .padding(.horizontal)
            }
            .disabled(!canSubmit)
            .padding(.bottom, 10)

            Button {
              router.stepBack()
            } label: {
              Text("Cancel")
                .font(.system(size: 20))
            }

            Spacer()
          }
        }
      }
      
      .scrollDisabled(true)
      .transitionWithOpacity()
      .navigationBarBackButtonHidden()

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
    .alert(item: $sessionManager.alertItem) { alert in
      Alert(
        title: Text(alert.title),
        message: Text(alert.message),
        dismissButton: .default(Text("OK"))
      )
    }
    .toolbar {
          ToolbarItemGroup(placement: .keyboard) {
            Button(role: .destructive) {
              if focus == .email { email = "" }
              else if focus == .password { password = "" }
              else if focus == .confirm { confirmPassword = "" }
            } label: {
              Text("Clear")
            }
            Spacer()
            Button {
              if focus == .email { focus = .password }
              else if focus == .password { focus = .confirm }
              else if focus == .confirm {
                focus = nil
                signUp()
              }
            } label: {
              Text("Next")
//              Image(systemName: "arrow.forward.circle.fill")
//                .imageScale(.large)
            }
          }
        }
  }

  private func signUp() {
    focus = nil
    Task {
      await sessionManager.signUp(email: email, password: password)
      if sessionManager.sessionUser != nil {
        //                router.stepBack()
      }
    }
  }
}
