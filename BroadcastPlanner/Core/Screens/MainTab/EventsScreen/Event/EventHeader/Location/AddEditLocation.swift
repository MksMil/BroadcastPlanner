import SwiftUI
import UIKit
import PhotosUI

struct AddEditLocation: View {

    let lenght: Double = 75
    let location: LocalLocation
    
    let cancelAction: ()->Void
    let acceptAction: ()->Void
//    let removeAction:

    @StateObject var vm: AddEditLocationViewModel
    @FetchRequest<LocalImage>(sortDescriptors: []) var images
            
    @State private var removedLocalImage: LocalImage?
    @State private var isShowingDialog: Bool = false
    @State private var isBackSheetShowed: Bool = false
    
    init(location: LocalLocation, cancelAction: @escaping ()->Void, acceptAction: @escaping ()->Void){
        self.location = location
        self._vm = StateObject(wrappedValue: AddEditLocationViewModel(location: location))
        self.cancelAction = cancelAction
        self.acceptAction = acceptAction
    }
    
    
    var body: some View {
#if DEBUG
        let _ = Self._printChanges()
#endif
        VStack{
            ConfirmationButtonGroupView(isAcceptDisabled: false, cancelAction: {
                cancelAction()
            }, acceptAction: {
                acceptAction()
            })
                .padding(.top,10)
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
                                ForEach(images){ image in
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
                vm.locationBackground
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
                    Task{
                        DataManager.shared.removeLocalLocation(location, inContext: .main)
                        
                    }
                }
                .buttonStyle(.borderedProminent)
            }
//            .task{
//                images.nsPredicate = NSPredicate(format: "parentLocationImage == %@", location)
//            }
            
            .padding()
            .fullScreenCover(isPresented: $isBackSheetShowed, content: {
                AddEditEventBackgroundView {
                    isBackSheetShowed.toggle()
                } acceptAction: { localImage in
                    guard let localImage else {
                        isBackSheetShowed.toggle()
                        return
                    }
                    vm.locationBackground = localImage.mediumImage
                    isBackSheetShowed.toggle()
                }


            })
            .confirmationDialog(
                Text("Permanently erase the items in the trash?"),
                isPresented: $isShowingDialog
            ) {
                Button("Remove Photo", role: .destructive) {
                    // Handle empty trash action.
                    guard let removedLocalImage else { return }
                    print("remove")
                    DataManager.shared.removeLocalImage(removedLocalImage, inContext: .main)
                    DataManager.shared.saveContext(type: .main, publish: .none, id: [])
                }
            }
        }
//        .task{
//            Task{
//                let request = LocalImage.fetchRequest()
//                let images = try  DataManager.shared.moc.fetch(request)
//                for image in images {
//                    DataManager.shared.removeLocalImage(image, inContext: .main)
//                    print("deleted")
//                    DataManager.shared.saveContext(type: .main, publish: .none, id: [])
//                }
//            }
//            
//        }
    }
}

#Preview {
    AddEditLocation(location: LocalLocation(context: DataManager.shared.moc),cancelAction: {}, acceptAction: { })
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
