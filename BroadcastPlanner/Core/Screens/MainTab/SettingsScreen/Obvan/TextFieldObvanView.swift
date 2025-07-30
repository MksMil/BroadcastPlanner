import SwiftUI

struct TextFieldObvanView: View {
    @FocusState var isTitleEditShown: Bool

    @Binding var text: String
    @Binding var isTitleEdit: Bool
    var body: some View {
        ScrollView{
            VStack{
                TextField("title", text: $text)
                    .onSubmit {
                        isTitleEdit = false
                        isTitleEditShown = false
                    }
                    .autocorrectionDisabled()
                    .keyboardType(.default)
                    .font(.title)
                    .minimumScaleFactor(0.4)
                    .foregroundStyle(Color.black)
                    .padding(5)
                    .background {
                        RoundedRectangle(cornerRadius: 5)
                            .fill(
                                .ultraThickMaterial
                                    .opacity(0.3)
                            )
                            .overlay {
                                RoundedRectangle(cornerRadius: 5)
                                    .stroke(
                                        .ultraThickMaterial
                                            .opacity(0.5),
                                        lineWidth: 2
                                    )
                            }
                    }
                    .padding()
                    .padding(.top,50)
                    .focused($isTitleEditShown)
                    .onAppear {
                        isTitleEditShown = true
                    }
                Spacer()
            }
            .scrollDisabled(true)
        }
        .ignoresSafeArea()
    }
}
