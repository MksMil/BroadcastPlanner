//import SwiftUI
//
//struct LocationPreview: View {
//
//    let image: Image
//    let removeAction: () -> Void
//
//    var body: some View {
//        ZStack(alignment: .topTrailing) {
//            image
//                .resizable()
//                .scaledToFill()
//                .clipShape(RoundedRectangle(cornerRadius: 5))
//                .overlay {
//                    RoundedRectangle(cornerRadius: 5).stroke(
//                        .white, lineWidth: 2)
//                }
//            Image(systemName: "xmark")
//                .resizable()
//                .frame(width: 8, height: 8)
//                .padding(3)
//                .onTapGesture {
//                    //remove photo
//                    removeAction()
//                }
//                .foregroundStyle(.white)
//                .background {
//                    Circle().fill(.gray.opacity(0.7))
//                        .overlay {
//                            Circle().stroke(.white, lineWidth: 1)
//                        }
//                }
//                .padding(3)
//        }
//    }
//}
