//import SwiftUI
//
//struct SheetedTextFieldView: View {
//    let height: Double
//    @Binding var source: String
//    let promptSource: String
//    let fieldType: TextFieldType // for buttons config
//    let isSecure: Bool
//    let action: (String)->()
//    @State private var isTextEnter = false
//
//    var body: some View {
//        RoundedRectangle(cornerRadius: 5)
//            .fill( .ultraThinMaterial)
//            .overlay {
//                RoundedRectangle(cornerRadius: 5)
//                    .stroke(.ultraThinMaterial)
//            }
//            .overlay {
//                HStack {
//                    Text(source.isEmpty ? "Tap to edit" : source)
//                        .foregroundColor(source.isEmpty ? .gray : .primary)
//                        .padding(.leading, 8)
//                    Spacer()
//                }
//            }
//            .padding(.horizontal)
//            .frame(maxWidth: .infinity)
//            .frame(height: height)
//            .onTapGesture {
//                isTextEnter = true
//            }
//            .sheet(isPresented: $isTextEnter) {
//                TextFieldSheetView(source: $source,
//                                   promptSource: promptSource,
//                                   fieldType: fieldType,
//                                   isSecure: isSecure,
//                                   cancelAction: {
//                    
//                }, doneAction: { value in
//                    
//                })
//                .presentationDetents([.medium])
//                .presentationDragIndicator(.visible)
//                .presentationBackground(.ultraThinMaterial)
//            }
//    }
//}
//
//
