import PhotosUI
import SwiftUI
import UIKit

struct AddEditLocation: View {

    let lenght: Double = 75
    let location: LocalLocation

    let acceptAction: (String,String,[UIImage],LocalImage?) -> Void
    let cancelAction: () -> Void
    let removeAction: () -> Void

    @StateObject var vm: AddEditLocationViewModel
    @EnvironmentObject var mdm: MainDataManager

    @State private var isShowingDialog: Bool = false
    @State private var isRemoveLocationDialog: Bool = false
    @State private var isBackSheetShowed: Bool = false

    init(
        location: LocalLocation,
        acceptAction: @escaping (String,String,[UIImage],LocalImage?) -> Void,
        cancelAction: @escaping () -> Void,
        removeAction: @escaping () -> Void
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
                            //update location with fotos
                            acceptAction(vm.title,vm.address,vm.newImages,vm.locationBackground)
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
                            .foregroundStyle(.black, .white)
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
                    
                    //location photos collection
                    RoundedRectangle(cornerRadius: 5).fill(.white.opacity(0.3))
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
                                Capsule().fill(.white.opacity(0.7))
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
                                .white.opacity(0.2))
                        }
                        .onTapGesture {
                            isBackSheetShowed.toggle()
                        }
                    Text("Add event background")
                        .padding(5)
                        .padding(.horizontal, 10)
                        .background {
                            Capsule().fill(.white.opacity(0.7))
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
                                mdm.removeImage(selectedImage: localImageToRemove)
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
                        Task{
                           await mdm.removeLocation(location)
                            removeAction()
                        }
                    }
                }
            }
        }
        .navigationBarBackButtonHidden()
    }
}



