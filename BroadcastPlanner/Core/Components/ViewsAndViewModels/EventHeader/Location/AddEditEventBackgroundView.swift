import SwiftUI
import UIKit
import PhotosUI

struct AddEditEventBackgroundView: View {
    @StateObject var vm = AddEditEventBackgroundViewViewModel()
    @Environment(\.dismiss) var dismiss
    @Namespace var ns
    @FetchRequest<LocalImage>(sortDescriptors: [],predicate: NSPredicate(format: "type == %@", GlobalProperties.ImageType.eventTemplate.rawValue)) var backgroundLocalImages
    
    let acceptAction: (LocalImage) -> Void
    
    
    var body: some View {
#if DEBUG
        let _ = Self._printChanges()
#endif
        VStack{
            HStack{
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "xmark")
                        .resizable()
                        .scaledToFit()
                        .bold()
                        .padding()
                        .background {
                            Rectangle()
                                .fill(.red
                                    .opacity(0.3))
                                .overlay {
                                    Rectangle()
                                        .stroke(Color
                                            .red
                                            .opacity(0.5),
                                                lineWidth: 2)
                                }
                        }
                        .frame(width: 50)
                }
                .frame(alignment: .leading)
                
                Spacer()
                
                Button{
                    //                    saveAction()
                    dismiss()
                } label: {
                    Image(systemName: "checkmark")
                        .resizable()
                        .scaledToFit()
                        .bold()
                        .padding()
                        .background {
                            Rectangle().fill(.green.opacity(0.3))
                                .overlay {
                                    Rectangle().stroke(Color.green.opacity(0.5),
                                                       lineWidth: 2)
                                }
                        }
                        .frame(width: 50)
                }
                .frame( alignment: .trailing)
            }
            .padding(.horizontal)
            .font(.title)
            .bold()
            ScrollView{
                SmartLayout(hSpacing: 4, vSpacing: 4){
                    PhotosPicker(selection: $vm.eventBackgroundItem) {
                        Image(systemName: "plus")
                            .resizable()
                            .scaledToFit()
                            .padding(20)
                            .background {
                                RoundedRectangle(cornerRadius: 5).fill(.ultraThinMaterial)
                            }
                            .frame(width: 100, height: 100)
                    }
                    ForEach(backgroundLocalImages){ image in
                        CellImage(image: image)
                            .matchedGeometryEffect(id: image.viewId,
                                                   in: ns,
                                                   isSource: true)
                            .onTapGesture {
                                withAnimation{
                                    vm.selectedImage = image
                                }
                            }
                    }
                }
                .overlay {
                    if let selectedImage = vm.selectedImage{
                        RoundedRectangle(cornerRadius: 5).stroke(Color.green,
                                                                 lineWidth: 4)
                        .frame(width: 100, height: 100)
                        .matchedGeometryEffect(id: selectedImage.viewId,
                                               in: ns,
                                               isSource: false)
                    }
                }
            }
            .scrollIndicators(.hidden)
            .padding()
        }
    }
}

#Preview {
    AddEditEventBackgroundView(acceptAction: {_ in })
        .environment(\.managedObjectContext, DataManager.shared.moc)
}
