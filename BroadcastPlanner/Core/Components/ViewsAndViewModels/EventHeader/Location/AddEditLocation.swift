import SwiftUI
import UIKit
import PhotosUI

struct AddEditLocation: View {
    let lenght: Double = 75
    
    let location: LocalLocation
    
//    @EnvironmentObject var globalStorage: GlobalStorage
    @Environment(\.dismiss) var dismiss
    
    @State private var title: String = ""
    @State private var address: String = ""

    @State private var locationPhotos: [PhotosPickerItem] = []
    @State private var localImages: [Image] = []
    
    @State private var eventBackground: PhotosPickerItem?
    @State private var locationBackground: Image = Image(systemName:"compass.drawing")
    
    @State private var isShowingDialog: Bool = false
    @State private var removedPhotoIndex: Int?
    
    @State private var isBackSheetShowed: Bool = false
    
//    @State var backgroundImages: [Image] = []
//    
//    @FetchRequest<LocalImage>(sortDescriptors: [],predicate: NSPredicate(format: "type == %@", GlobalProperties.ImageType.eventBackground.rawValue)) var backgroundLocalImages
    
    var body: some View {
        VStack{
                HStack{
                    Button {
                        //                    cancelAction()
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
                
                Text("Location Title")
                    .font(.title3)
                    .bold()
                TextField("enter title", text: $title)
                    .padding(.horizontal)
                    .textFieldStyle(.roundedBorder)
                    .autocorrectionDisabled()
                
                Divider()
                
                Text("Location Address")
                    .font(.title3)
                    .bold()
                TextField("enter address", text: $address,axis: .vertical)
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
                                ForEach(0..<localImages.count, id: \.self) { index in
                                    ZStack(alignment: .topTrailing){
                                        localImages[index]
                                            .resizable()
                                            .scaledToFill()
                                            .frame(width: lenght, height: lenght)
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
                                                removedPhotoIndex = index
                                                isShowingDialog = true
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
                                    .frame(width: lenght, height: lenght)
                                }
                            }
                        }
                        .padding(.horizontal)
                        .scrollIndicators(.hidden)
                    }
                PhotosPicker(selection: $locationPhotos) {
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
//                    globalStorage.conteiner.removeLocalLocation(location,inContext: .main)
//                    globalStorage.conteiner.saveContext(type: .main)
                    dismiss()
                }
                .buttonStyle(.borderedProminent)
            }
            .padding()
            .fullScreenCover(isPresented: $isBackSheetShowed, content: {
              
                AddEditEventBackgroundView(/*backgroundImages: backgroundImages*/){ uiimage, image in
                    locationBackground = image
//                    globalStorage.conteiner.backgroundContext.perform{
//                        locationBackground = image
//                        Task{
//                            let localImage = globalStorage.conteiner.createOrUpdateLocalImageWithId(UUID().uuidString, withImage: uiimage, andType: GlobalProperties.ImageType.eventBackground.rawValue)
//                            location.background = localImage
//                            localImage.parentLocationBackground = location
//                            globalStorage.conteiner.saveContext()
//                        }
//                    }
                } addExistBackgroundAction: { num in
//                    locationBackground = image
//                    globalStorage.conteiner.backgroundContext.perform{
//                        location.background = localImage
//                        localImage.parentLocationBackground = location
//                        globalStorage.conteiner.saveContext()
//                    }

                }

            })
            .onChange(of: locationPhotos) { photos in
                Task{
                    for photo in photos{
                        guard let imageData = try? await photo.loadTransferable(type: Data.self),
                              let uiimage = UIImage(data: imageData) else { continue }
                        let localImage = Image(uiImage: uiimage)
                        withAnimation{
                            localImages.append(localImage)
                            locationPhotos = []
                        }
                    }
                }
            }
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
                    guard let removedPhotoIndex else { return }
                    withAnimation{
                        let _ = localImages.remove(at: removedPhotoIndex)
                    }
                    self.removedPhotoIndex = nil
                }
            }
        }
        
        .task {
            title = location.viewTitle
            address = location.viewAddress
            locationBackground = Image(uiImage: location.viewBackground)
            localImages = location.viewImages
        }
    }
    
   
}

#Preview {
    AddEditLocation(location: LocalLocation(context: DataManager.shared.moc))
        .environment(\.managedObjectContext, DataManager.shared.moc)
}
