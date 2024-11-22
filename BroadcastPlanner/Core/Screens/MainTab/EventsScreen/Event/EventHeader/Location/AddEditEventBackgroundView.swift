import SwiftUI
import UIKit
import PhotosUI

struct AddEditEventBackgroundView: View {
    @StateObject var vm = AddEditEventBackgroundViewViewModel()
    @Namespace var ns
    @FetchRequest<LocalImage>(sortDescriptors: [],predicate: NSPredicate(format: "type == %@", GlobalProperties.ImageType.eventTemplate.rawValue)) var backgroundLocalImages
    let cancellAction: ()->Void
    let acceptAction: (LocalImage?) -> Void
    
    
    var body: some View {
#if DEBUG
        let _ = Self._printChanges()
#endif
        VStack{
            ConfirmationButtonGroupView(isAcceptDisabled: false,
                                        cancelAction: {
                cancellAction()
            }, acceptAction: {
                acceptAction(vm.selectedImage)
            })
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
    AddEditEventBackgroundView(cancellAction: {},acceptAction: {_ in })
        .environment(\.managedObjectContext, DataManager.shared.moc)
}
