import SwiftUI
import UIKit
import PhotosUI

struct AddEditEventBackgroundView: View {
    @EnvironmentObject var mdm: MainDataManager
    
    @State private var isRemoveEventTeamplate: Bool = false
    @State var selectedImage: LocalImage?
    @State var eventBackgroundItem: PhotosPickerItem?{
        willSet{
            guard let item = newValue else { return }
            Task{
                if let data = try? await item.loadTransferable(type: Data.self),
                   let uiimage = UIImage(data: data){
                    mdm.createNewLocalImageWith(uiimage: uiimage)
                }
            }
        }
        didSet{
            eventBackgroundItem = nil
        }
    }
    @FetchRequest<LocalImage>(sortDescriptors: [],
                              predicate: NSPredicate(format: "type == %@",
                                                     GlobalProperties.ImageType.eventTemplate.rawValue),
                              animation: .easeInOut) var backgroundLocalImages
    
    let cancellAction: ()->Void
    let acceptAction: (LocalImage?) -> Void
    
    @Namespace var ns
    
    var body: some View {
        VStack{
            ConfirmationButtonGroupView(isAcceptDisabled: selectedImage == nil,
                                        cancelAction: {
                cancellAction()
            }, acceptAction: {
                acceptAction(selectedImage)
            }, content: {
                Image(systemName: "trash.square")
                    .resizable()
                    .scaledToFit()
                    .onTapGesture {
                        isRemoveEventTeamplate.toggle()
                    }
                    .foregroundStyle(.black, .gray)
                    .fontWeight(.light)
                    .disabled(selectedImage == nil)
                    .opacity(selectedImage == nil ? 0.3: 1)
            })
            .padding(.horizontal)
            
            ScrollView{
                SmartLayout(hSpacing: 4, vSpacing: 4){
                    PhotosPicker(selection: $eventBackgroundItem) {
                        Image(systemName: "plus")
                            .resizable()
                            .scaledToFit()
                            .padding(20)
                            .background {
                                RoundedRectangle(cornerRadius: 5).fill(.white.opacity(0.4))
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
                                    (selectedImage == image) ? (selectedImage = nil): (selectedImage = image)
                                }
                            }
                    }
                }
                .overlay {
                    if let selectedImage {
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
                       mdm.removeImage(selectedImage: selectedImage)
                   }
               }
    }
}

#Preview {
    AddEditEventBackgroundView(cancellAction: {},acceptAction: {_ in })
}
