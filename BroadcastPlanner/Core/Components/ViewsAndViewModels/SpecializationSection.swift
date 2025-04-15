import SwiftUI

struct SpecializationSection: View {

    @Binding var specialization: [String]
    @Binding var isEditSpecialization: Bool
    var isEdit: Bool

    var body: some View {
        VStack {
            AnyContentView(
                sourceContent: UserSpecialization.allCases.map { $0.rawValue },
                selectedContent: $specialization,
                isEdit: $isEditSpecialization
            ) {
                RoundedRectangle(cornerRadius: 10.0).fill(.white.opacity(0.4))
                    .opacity(isEdit ? 0.5 : 0)
            } cellView: { text in
                BPSpecializationCellView(text: text)
            } buttonView: {
                Text("Done")
                    .fixedSize()
                    .padding(.horizontal, 20)
                    .padding(.vertical, 4)
                    .background {
                        RoundedRectangle(cornerRadius: 10).fill(
                            .white.opacity(0.4))
                    }
            } promptView: {
                Text("Tap to make choise of specialization")
                    .font(.body)
                    .fontWeight(.light)
                    .foregroundStyle(Color(.systemGray))
            }
        }
        .disabled(!isEdit)
    }
}
