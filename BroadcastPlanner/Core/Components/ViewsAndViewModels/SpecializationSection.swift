import SwiftUI

struct SpecializationSection: View {
    @EnvironmentObject var settings: GlobalSettings
    @Binding var specialization: [String]
    @Binding var isEditSpecialization: Bool
    
    var isEdit: Bool

    var body: some View {
        VStack {
            AnyContentView(
                sourceContent: $settings.userSpecialization,
                selectedContent: $specialization,
                isEdit: $isEditSpecialization
            ) {
                RoundedRectangle(cornerRadius: 10.0).fill(.white.opacity(0.4))
                    .opacity(isEdit ? 0.5 : 0)
            } cellView: { text in
                BPSpecializationCellView(text: text)
            }  promptView: {
                Text("Add specialization")
                    .font(.body)
                    .fontWeight(.light)
                    .foregroundStyle(Color(.systemGray))
            }
        }
        .disabled(!isEdit)
    }
}
