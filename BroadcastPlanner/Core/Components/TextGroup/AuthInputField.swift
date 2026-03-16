import SwiftUI

// MARK: - AuthInputField

struct AuthInputField: View {
  let placeholder: String
  @Binding var text: String
  var isSecure: Bool = false
  var icon: String? = nil
  var keyboardType: UIKeyboardType = .default
  var returnKeyType: SubmitLabel = .done
  var maxLength: Int = 64
  var showClearButton: Bool = false
  var onSubmit: (() -> Void)? = nil
  
  @State private var isRevealed: Bool = false
  @FocusState private var isFocused: Bool
  
  var body: some View {
    RoundedRectangle(cornerRadius: 8)
      .fill(.ultraThinMaterial)
      .overlay {
        RoundedRectangle(cornerRadius: 8)
          .stroke(
            isFocused
            ? Color.primary.opacity(0.4)
            : Color.primary.opacity(0.15),
            lineWidth: isFocused ? 1.5 : 1
          )
      }
      .overlay {
        HStack(spacing: 0) {
          // Иконка слева
          if let icon {
            Image(systemName: icon)
              .foregroundStyle(.secondary)
              .frame(width: 40)
            Rectangle()
              .fill(Color.primary.opacity(0.1))
              .frame(width: 1)
              .padding(.vertical, 8)
          }
          
          ZStack{
            SecureField(placeholder, text: $text)
              .opacity((isSecure && !isRevealed) ? 1:0)
            
            TextField(placeholder, text: $text)
              .opacity((isSecure && !isRevealed) ? 0:1)
          }
          .textContentType(.oneTimeCode)
          .textInputAutocapitalization(.never)
          .autocorrectionDisabled()
          .keyboardType(keyboardType)
          
          .focused($isFocused)
          .submitLabel(returnKeyType)
          .onSubmit { onSubmit?() }
          .onChangeCompat(of: text) { _ in
            if text.count > maxLength {
              text = String(text.prefix(maxLength))
            }
          }
          .padding(.horizontal, 12)
          
          // Clear для email
          if showClearButton && !isSecure && !text.isEmpty && isFocused {
            Image(systemName: "xmark.circle.fill")
              .foregroundStyle(.tertiary)
              .frame(width: 36, height: 46)
              .contentShape(Rectangle())
              .onTapGesture { text = "" }
              .transition(.opacity)
          }
          
          // Глазик
          if isSecure {
            Image(systemName: isRevealed ? "eye.slash" : "eye")
              .foregroundStyle(.secondary)
              .frame(width: 40, height: 46)
              .contentShape(Rectangle())
              .onTapGesture {
                isRevealed.toggle()
              }
          }
        }
      }
      .frame(height: 46)
      .animation(.easeInOut(duration: 0.15), value: isFocused)
      .animation(.easeInOut(duration: 0.15), value: text.isEmpty)
    
  }
}
