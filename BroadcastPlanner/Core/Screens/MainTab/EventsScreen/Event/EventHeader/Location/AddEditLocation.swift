import SwiftUI
import UIKit
import PhotosUI

struct AddEditLocation: View {
    
    @StateObject var vm: AddEditLocationViewModel
    
    let lenght: Double = 75
    
    let location: LocalLocation
    
    let cancelAction: ()->Void
    let acceptAction: (LocalLocation)->Void
    
    @Environment(\.dismiss) var dismiss
    
    @State private var title: String = ""
    @State private var address: String = ""

//    @State private var locationPhotos: [PhotosPickerItem] = []
//    @State private var localImages: [Image] = []
    
    @State private var eventBackground: PhotosPickerItem?
    @State private var locationBackground: Image = Image(systemName:"compass.drawing")
    
    @State private var isShowingDialog: Bool = false
    @State private var removedLocalImage: LocalImage?
    
    @State private var isBackSheetShowed: Bool = false
    
//    @State var backgroundImages: [Image] = []
//    
//    @FetchRequest<LocalImage>(sortDescriptors: [],predicate: NSPredicate(format: "type == %@", GlobalProperties.ImageType.eventBackground.rawValue)) var backgroundLocalImages
    
    init(location: LocalLocation, cancelAction: @escaping ()->Void, acceptAction: @escaping (LocalLocation)->Void){
        self.location = location
        self._vm = StateObject(wrappedValue: AddEditLocationViewModel(location: location))
        self.cancelAction = cancelAction
        self.acceptAction = acceptAction
    }
    
    
    var body: some View {
        VStack{
            ConfirmationButtonGroupView(isAcceptDisabled: .constant(false), cancelAction: {
                cancelAction()
            }, acceptAction: {
                acceptAction(location)
            })
                .padding(.horizontal)
                .font(.title)
                .bold()
                
            ScrollView{
                // TODO: Make component for title and textfield
                Text("Location Title")
                    .font(.title3)
                    .bold()
                TextField("enter title", text: $vm.title)
                    .padding(.horizontal)
                    .textFieldStyle(.roundedBorder)
                    .autocorrectionDisabled()
                
                Divider()
                
                Text("Location Address")
                    .font(.title3)
                    .bold()
                TextField("enter address", text: $vm.address,axis: .vertical)
                    .lineLimit(3)
                    .padding(.horizontal)
                    .textFieldStyle(.roundedBorder)
                    .autocorrectionDisabled()
                
                Divider()
                    .padding(.vertical)
                //location photos collection
                
                RoundedRectangle(cornerRadius: 5).fill(.gray.opacity(0.3))
                    .frame(height: lenght + 10)
                    .overlay {
                        ScrollView(.horizontal){
                            HStack{
                                ForEach(vm.localImages){ image in
                                    LocationPreview(image: image,
                                                    removeAction: {
                                        removedLocalImage = image
                                        isShowingDialog.toggle()
                                    })
                                .frame( height: lenght)
                                
                                }
                            }
                        }
                        .padding(.horizontal)
                        .scrollIndicators(.hidden)
                    }
                PhotosPicker(selection: $vm.locationPhotos) {
                    Text("Add background photos")
                        .padding(5)
                        .padding(.horizontal,10)
                        .background {
                            Capsule().fill(.gray.opacity(0.4))
                        }
                }
                .padding(.vertical,10)
                Divider()
                    .padding(.vertical,5)
                
                
                //event background representation

                    locationBackground
                        .resizable()
                        .scaledToFit()
                        .frame(height: 100)
                        .clipShape(RoundedRectangle(cornerRadius: 5))
                        .padding()
                        .background {
                            RoundedRectangle(cornerRadius: 5).fill(.gray.opacity(0.2))
                        }
                        .onTapGesture {
                            isBackSheetShowed.toggle()
                        }
                Text("Add event background")
                        .padding(5)
                        .padding(.horizontal,10)
                        .background {
                            Capsule().fill(.gray.opacity(0.4))
                        }
                        .onTapGesture {
                            isBackSheetShowed.toggle()
                        }
                .padding(.vertical,10)
                
                Spacer(minLength: 50)
                
                Button("Remove location"){
//                    dismiss()
                    Task{
                        DataManager.shared.removeLocalLocation(location, inContext: .main)
                        
                    }
                }
                .buttonStyle(.borderedProminent)
            }
            .padding()
            .fullScreenCover(isPresented: $isBackSheetShowed, content: {
              
                AddEditEventBackgroundView(){ _ in
                }

            })

            .onChange(of: eventBackground) { bgItem in
//                Task{
//                    guard let item = bgItem,
//                          let data = try? await item.loadTransferable(type: Data.self),
//                          let uiimage = UIImage(data: data) else { return }
////                    locationBackground = Image(uiImage: uiimage)
//                    let newLocalImage = globalStorage.conteiner.createOrUpdateLocalImageWithId(UUID().uuidString, withImage: uiimage, andType: GlobalProperties.ImageType.eventBackground.rawValue)
//                    eventBackground = nil
//                }
            }
            .confirmationDialog(
                Text("Permanently erase the items in the trash?"),
                isPresented: $isShowingDialog
            ) {
                Button("Remove Photo", role: .destructive) {
                    // Handle empty trash action.
                    guard let removedLocalImage else { return }
                    print("remove")
                    withAnimation{
//                        let _ = localImages.remove(at: removedPhotoIndex)
                    }
//                    self.removedPhotoIndex = nil
                }
            }
        }
        
        .task {
            title = location.viewTitle
            address = location.viewAddress
            locationBackground = Image(uiImage: location.viewBackground)
//            localImages = location.viewImages
        }
    }
    
   
}

#Preview {
    AddEditLocation(location: LocalLocation(context: DataManager.shared.moc),cancelAction: {}, acceptAction: {_ in })
        .environment(\.managedObjectContext, DataManager.shared.moc)
}


struct LocationPreview: View {
    
    let image: LocalImage
    let removeAction: ()->Void
    
    var body: some View {
        ZStack(alignment: .topTrailing){
            image.mediumImage
            .resizable()
            .scaledToFill()
            .clipShape(RoundedRectangle(cornerRadius: 5))
            .overlay {
                RoundedRectangle(cornerRadius: 5).stroke(.white, lineWidth: 2)
            }
            Image(systemName: "xmark")
                .resizable()
                .frame(width: 8, height: 8)
                .padding(3)
                .onTapGesture {
                    //remove photo
                    removeAction()
                }
                .foregroundStyle(.white)
                .background {
                    Circle().fill(.gray.opacity(0.7))
                        .overlay {
                            Circle().stroke(.white, lineWidth: 2)
                        }
                }
                .padding(3)
        }
    }
}
