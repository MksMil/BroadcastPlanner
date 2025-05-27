import PhotosUI
import SwiftUI

struct BPAccountInfoView: View {
    @EnvironmentObject var mdm: MainDataManager
    
    @StateObject var vm: PersonalScreenViewModel
    
    @State private var isEdit: Bool = false
    @State private var isEditSpecialization: Bool = false

    init(user: Member) {
        self._vm = StateObject(wrappedValue: PersonalScreenViewModel(localUser: user))
    }

    var body: some View {

        NavigationStack {
            ZStack {
                MainBackground()
                VStack {
                    VStack {
                        HStack {
                            PhotosPicker(
                                selection: $vm.selectedPhoto,
                                matching: .images,
                                photoLibrary: .shared()
                            ) {
                                vm.showedImage
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: 100, height: 100)
                                    .clipShape(Circle())
                                    .background {
                                        Circle()
                                            .fill(.ultraThickMaterial)
                                            .opacity(isEdit ? 0.8 : 0.3)
                                            .frame(width: 110, height: 110)
                                    }
                                    .padding(.trailing, 15)
                            }
                            VStack(alignment: .leading, spacing: 3) {

                                UserInfoTextField(
                                    text: $vm.firstName,
                                    isEdit: isEdit,
                                    imageName: "",
                                    prompt: "first name",
                                    scaleFactor: 0.2)

                                Divider()

                                UserInfoTextField(
                                    text: $vm.lastName,
                                    isEdit: isEdit,
                                    imageName: "",
                                    prompt: "last name",
                                    scaleFactor: 0.2)

                                Divider()
                            }
                            .font(.title3)
                            .bold()
                            .frame(maxWidth: .infinity)

                        }
                        .padding(.vertical)
                        Section {
                            VStack {

                                UserInfoTextField(
                                    text: $vm.phoneNumber,
                                    isEdit: isEdit,
                                    imageName: "phone.circle.fill",
                                    prompt: "phone number",
                                    scaleFactor: 0.2)

                                Divider()

                                UserInfoTextField(
                                    text: $vm.email,
                                    isEdit: isEdit,
                                    imageName: "envelope.circle.fill",
                                    prompt: "E-mail",
                                    scaleFactor: 0.2)

                                Divider()
                                UserInfoTextField(
                                    text: $vm.address,
                                    isEdit: isEdit,
                                    imageName: "map.circle.fill",
                                    prompt: "Address",
                                    scaleFactor: 0.2)
                                Divider()
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 10)
                    .disabled(!isEdit)
                    SpecializationSection(
                        specialization: $vm.userSpecialization,
                        isEditSpecialization: $isEditSpecialization,
                        isEdit: isEdit
                    )
                    .padding(.vertical, 0)
                    .padding(.horizontal)
                    Divider()
                        .padding(.vertical, 0)
                        .padding(.horizontal, 20)
                    Spacer()
                }
//                .randomColorBackground()

            }
            .navigationTitle(Text("My Info"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        withAnimation {
                            isEdit.toggle()
                            if isEditSpecialization {
                                isEditSpecialization.toggle()
                            }
                        }
                        if !isEdit {
                            Task{
                                await mdm.updateUserData(firstName: vm.firstName,
                                                         lastName: vm.lastName,
                                                         email: vm.email,
                                                         phoneNumber: vm.phoneNumber,
                                                         address: vm.address,
                                                         userSpecialization: vm.userSpecialization,
                                                         inputImage: vm.inputImage)
                            }
                        }
                    } label: {
                        Text(isEdit ? "Save" : "Edit")
                    }
                    .frame(alignment: .center)
                    .font(.headline)
                    .foregroundStyle(.blue)
                }
            }
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarBackground(.white.opacity(0.4), for: .navigationBar)
        }
        .onReceive(mdm.localDataManager.updatePublisher, perform: { value in
            if value.0 == .members, value.1.contains(where: { $0 == mdm.currentId
            }){
                vm.updateData()
            }
        })
        
    }
}



#Preview {
    let mdm = MainDataManager(localDataManager: DataManager(),
                              globalDataManager: NetworkManager(),
                              userId: "123")
    return BPAccountInfoView(user: mdm.currentUser)
        .environment(\.managedObjectContext, mdm.localDataManager.mainContext)
        .environmentObject(mdm)
}
