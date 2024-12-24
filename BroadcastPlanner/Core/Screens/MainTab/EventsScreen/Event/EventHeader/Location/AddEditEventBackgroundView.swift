import SwiftUI
import UIKit
import PhotosUI

struct AddEditEventBackgroundView: View {
    @StateObject var vm = AddEditEventBackgroundViewViewModel()
    @State private var isRemoveEventTeamplate: Bool = false
    @Namespace var ns
    @FetchRequest<LocalImage>(sortDescriptors: [],predicate: NSPredicate(format: "type == %@", GlobalProperties.ImageType.eventTemplate.rawValue),animation: .easeInOut) var backgroundLocalImages
    let cancellAction: ()->Void
    let acceptAction: (LocalImage?) -> Void
    
    
    var body: some View {
        VStack{
            ConfirmationButtonGroupView(isAcceptDisabled: vm.selectedImage == nil,
                                        cancelAction: {
                cancellAction()
            }, acceptAction: {
                acceptAction(vm.selectedImage)
            }, content: {
                Image(systemName: "trash.square")
                    .resizable()
                    .scaledToFit()
                    .onTapGesture {
                        isRemoveEventTeamplate.toggle()
                    }
                    .foregroundStyle(.black, .gray)
                    .fontWeight(.light)
                    .disabled(vm.selectedImage == nil)
                    .opacity(vm.selectedImage == nil ? 0.3: 1)
            })
            .padding(.horizontal)
            
            
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
                                    (vm.selectedImage == image) ? (vm.selectedImage = nil): (vm.selectedImage = image)
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
        //background template remove confirmation dialog
               .confirmationDialog(
                   Text("Permanently erase background template in the trash?"),
                   isPresented: $isRemoveEventTeamplate
               ) {
                   Button("Remove Background Template", role: .destructive) {
                       // Handle empty trash action.
                           vm.removeImage()
                   }
               }
    }
}

#Preview {
    AddEditEventBackgroundView(cancellAction: {},acceptAction: {_ in })
        .environment(\.managedObjectContext, DataManager.shared.moc)
}
