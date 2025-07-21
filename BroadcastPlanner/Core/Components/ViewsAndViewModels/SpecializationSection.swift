import SwiftUI

struct SpecializationSection: View {
    @EnvironmentObject var settings: GlobalSettings
    @Binding var specialization: [String]
    @Binding var isEditSpecialization: Bool
    
    var isEdit: Bool

    var body: some View {
        VStack {
            AnyContentView(
                sourceContent: settings.userSpecialization,
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
