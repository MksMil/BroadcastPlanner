import PhotosUI
import SwiftUI
import UIKit

struct AddEditLocation: View {

    let lenght: Double = 75
    let location: LocalLocation

    let cancelAction: () -> Void
    let acceptAction: () -> Void
    let removeAction: () -> Void

    @StateObject var vm: AddEditLocationViewModel

    @State private var isShowingDialog: Bool = false
    @State private var isRemoveLocationDialog: Bool = false
    @State private var isBackSheetShowed: Bool = false

    init(
        location: LocalLocation, cancelAction: @escaping () -> Void,
        acceptAction: @escaping () -> Void, removeAction: @escaping () -> Void
    ) {
        self.location = location
        self._vm = StateObject(
            wrappedValue: AddEditLocationViewModel(location: location))
        self.cancelAction = cancelAction
        self.acceptAction = acceptAction
        self.removeAction = removeAction
    }

    var body: some View {
        ZStack{
            Color.mainBackground.ignoresSafeArea()
            VStack {
                ConfirmationButtonGroupView(
                    isAcceptDisabled: false,
                    cancelAction: {
                        cancelAction()
                    },
                    acceptAction: {
                        Task {
                            await vm.updateLocation()
                            acceptAction()
                        }
                    },
                    content: {
                        Image(systemName: "trash.square")
                            .resizable()
                            .scaledToFit()
                            .onTapGesture {
                                isRemoveLocationDialog.toggle()
                            }
                            .fontWeight(.light)
                            .foregroundStyle(.black, .gray)
                    }
                )
                .padding(.top, 10)
                .padding(.horizontal)
                
                ScrollView {
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
                    TextField("enter address", text: $vm.address)
                        .padding(.horizontal)
                        .textFieldStyle(.roundedBorder)
                        .autocorrectionDisabled(true)
                    Divider()
                    //                    .padding(.vertical)
                    //location photos collection
                    
                    RoundedRectangle(cornerRadius: 5).fill(.gray.opacity(0.3))
                        .frame(height: lenght + 10)
                        .overlay {
                            ScrollView(.horizontal) {
                                HStack {
                                    //saved in locationEntity photos
                                    ForEach(vm.localImages) { localImage in
                                        LocationPreview(
                                            image: localImage.mediumImage,
                                            removeAction: {
                                                vm.localImageToRemove = localImage
                                                isShowingDialog.toggle()
                                            }
                                        )
                                        .frame(height: lenght)
                                    }
                                    //newAdded photos
                                    ForEach(0..<vm.newImages.count, id: \.self) {
                                        index in
                                        LocationPreview(
                                            image: Image(
                                                uiImage: vm.newImages[index])
                                        ) {
                                            vm.indexSetToRemove = index
                                            isShowingDialog.toggle()
                                        }
                                        .frame(height: lenght)
                                    }
                                }
                            }
                            .padding(.horizontal)
                            .scrollIndicators(.hidden)
                        }
                    PhotosPicker(selection: $vm.locationPhotos) {
                        Text("Add background photos")
                            .padding(5)
                            .padding(.horizontal, 10)
                            .background {
                                Capsule().fill(.gray.opacity(0.7))
                            }
                    }
                    .padding(.vertical, 10)
                    Divider()
                    //event background representation
                    vm.locationBackgroundPreview
                        .resizable()
                        .scaledToFit()
                        .frame(height: 100)
                        .clipShape(RoundedRectangle(cornerRadius: 5))
                        .padding()
                        .background {
                            RoundedRectangle(cornerRadius: 5).fill(
                                .gray.opacity(0.2))
                        }
                        .onTapGesture {
                            isBackSheetShowed.toggle()
                        }
                    Text("Add event background")
                        .padding(5)
                        .padding(.horizontal, 10)
                        .background {
                            Capsule().fill(.gray.opacity(0.7))
                        }
                        .onTapGesture {
                            isBackSheetShowed.toggle()
                        }
                        .padding(.vertical, 10)
                    
                    Spacer(minLength: 50)
                }
                .padding()
                .scrollDismissesKeyboard(.immediately)
                
                .fullScreenCover(
                    isPresented: $isBackSheetShowed,
                    content: {
                        AddEditEventBackgroundView {
                            isBackSheetShowed.toggle()
                        } acceptAction: { localImage in
                            guard let localImage else {
                                isBackSheetShowed.toggle()
                                return
                            }
                            vm.locationBackground = localImage
                            isBackSheetShowed.toggle()
                        }
                        
                    }
                )
                //background photo remove confirmation dialog
                .confirmationDialog(
                    Text("Permanently erase the photo in the trash?"),
                    isPresented: $isShowingDialog
                ) {
                    Button("Remove Photo", role: .destructive) {
                        // Handle empty trash action.
                        withAnimation {
                            if let localImageToRemove = vm.localImageToRemove {
                                vm.localImages.removeAll {
                                    $0 == localImageToRemove
                                }
                                DataManager.shared.removeLocalImage(
                                    localImageToRemove, inContext: .main)
                                Task {
                                    await DataManager.shared.saveContext(
                                        type: .main, publish: .none, id: [])
                                }
                            } else if let index = vm.indexSetToRemove {
                                vm.removeElementAtIndex(index)
                            }
                        }
                    }
                }
                //location remove confirmation dialog
                .confirmationDialog(
                    Text("Permanently erase the Location in the trash?"),
                    isPresented: $isRemoveLocationDialog
                ) {
                    Button("Remove Location", role: .destructive) {
                        // Handle empty trash action.
                        
                        Task {
                            await NetworkManager.shared.removeLocationWithId(location.viewId)
                            DataManager.shared.removeLocalLocation(
                                location, inContext: .main)
                            await DataManager.shared.saveContext(
                                type: .main, publish: .locations, id: [])
                            removeAction()
                        }
                    }
                }
            }
        }
        .navigationBarBackButtonHidden()
    }
}

#Preview {
    AddEditLocation(
        location: DataManager.shared.fetchOrCreateLocationWithId(
            "123", inContext: .main), cancelAction: {}, acceptAction: {},
        removeAction: {}
    )
    .environment(\.managedObjectContext, DataManager.shared.moc)
}

struct LocationPreview: View {

    let image: Image
    let removeAction: () -> Void

    var body: some View {
        ZStack(alignment: .topTrailing) {
            image
                .resizable()
                .scaledToFill()
                .clipShape(RoundedRectangle(cornerRadius: 5))
                .overlay {
                    RoundedRectangle(cornerRadius: 5).stroke(
                        .white, lineWidth: 2)
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
                            Circle().stroke(.white, lineWidth: 1)
                        }
                }
                .padding(3)
        }
    }
}
