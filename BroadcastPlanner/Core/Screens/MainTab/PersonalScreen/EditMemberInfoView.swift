import PhotosUI
import SwiftUI

struct EditMemberInfoView: View {
    @EnvironmentObject var dataManager: DataManager
    @EnvironmentObject var router: Router
    @EnvironmentObject var appState: ApplicationState
    
    @StateObject var vm: EditMemberViewModel
    @State private var isEdit: Bool = false
    @State private var isEditSpecialization: Bool = false

    let user: Member
    
    init(user: Member) {
        self.user = user
        self._vm = StateObject(wrappedValue: EditMemberViewModel(localUser: user))
    }

    var body: some View {

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
                .transitionWithOpacity()
            }
            .navigationBarBackButtonHidden()
            .onAppear{
                appState.primaryAction = {
                    if isEdit {
                        appState.setIconToPrimaryButton(.edit)
                         dataManager
                                .updateUserData(
                                    firstName: vm.firstName,
                                    lastName: vm.lastName,
                                    email: vm.email,
                                    phoneNumber: vm.phoneNumber,
                                    address: vm.address,
                                    userSpecialization: vm.userSpecialization,
                                    inputImage: vm.inputImage
                                )
                        isEdit = false
                        isEditSpecialization = false
                    } else {
                        appState.setIconToPrimaryButton(.accept)
                        isEdit = true
                        isEditSpecialization = true
                    }
                }
                appState.secondaryAction = {}
                appState.stepBackAction = {
                    appState.setMenuState(state: .none)
                    router.stepBack()
                }
            }
        }
}

#if DEBUG
#Preview {
    let dm = DataManager(globalDataManager: NetworkManager())
    let appState = ApplicationState()
    dm.networkManager.eventProgressHandler = appState
    return RootView()
        .environmentObject(GlobalSettings())
        .environmentObject(SessionManager())
        .environmentObject(appState)
        .environmentObject(Router())
        .environmentObject(dm)
        .environment(\.managedObjectContext, dm.mainContext)
}
#endif

