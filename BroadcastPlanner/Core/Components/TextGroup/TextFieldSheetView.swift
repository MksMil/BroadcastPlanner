import SwiftUI

struct TextFieldSheetView: View {
    @FocusState private var isFocused: Bool
    @Binding var source: String
    let promptSource: String
    let fieldType: TextFieldType
    let isSecure: Bool
    let cancelAction: ()->()
    let doneAction: (String)->()
    var body: some View {
            VStack(spacing: 12) {
                Text(promptSource)
                    .font(.headline)
                    .padding(.top, 16)
                HStack {
                    if isSecure{
                        SecureField("", text: $source)
                            .textContentType(fieldType.contentType)
                            .textInputAutocapitalization(.never)
                            .disableAutocorrection(true)
                            .padding(8)
                            .background(Color(.systemGray6))
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                            .focused($isFocused)
                            .onSubmit {
                                doneAction(source)
                            }
                    }else {
                        TextField("", text: $source)
                            .textContentType(fieldType.contentType)
                            .textInputAutocapitalization(.never)
                            .disableAutocorrection(true)
                            .padding(8)
                            .background(Color(.systemGray6))
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                            .focused($isFocused)
                            .onSubmit {
                                doneAction(source)
                            }
                    }
                    Button(action: {
                        source = ""
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.gray)
                    }
                }
                .padding(.horizontal)
            }
            .padding(.bottom)
            .buttonStyle(.plain)
            .task {
                isFocused = true
            }
    }
}
