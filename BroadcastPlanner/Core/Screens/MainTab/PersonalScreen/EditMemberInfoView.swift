import PhotosUI
import SwiftUI

struct EditMemberInfoView: View {
  @EnvironmentObject var dataManager: DataManager
  @EnvironmentObject var router: Router
  @EnvironmentObject var appState: ApplicationState
  @EnvironmentObject var settings: GlobalSettings

  @State private var vm: EditMemberViewModel = EditMemberViewModel()
  @State private var isEdit: Bool = false

//  let member: Member
  //    @State var selectedPhoto: PhotosPickerItem?

  @State var userSpecialization: [String] = []

  var body: some View {

    ZStack {
      MainBackground()
//      VStack {
//        Section {
//          HStack {
//            PhotosPicker(
//              selection: $vm.selectedPhoto,
//              matching: .images,
//              photoLibrary: .shared()
//            ) {
//              ImageWrapper(
//                id: member.viewId,
//                type: .member,
//                imageSize: ImageSizes.mediumImages,
//                placeHolder: "person.circle"
//              )
//              .aspectRatio(contentMode: .fill)
//              .frame(width: 100, height: 100)
//              .clipShape(Circle())
//              .background {
//                Circle()
//                  .fill(.ultraThickMaterial)
//                  .opacity(isEdit ? 0.8 : 0.3)
//                  .frame(width: 110, height: 110)
//              }
//              .padding(.trailing, 15)
//            }
//            VStack(alignment: .leading, spacing: 3) {
//
//              MemberDataTextCellView(
//                text: member.viewFirstName,
//                isEdit: isEdit,
//                imageName: "",
//                prompt: "first name",
//                scaleFactor: 0.2
//              )
//              .onTapGesture {
//                appState.cleanTFInfo()
//                appState.textfieldSource = member.viewFirstName
//                appState.promptString = "Enter first name, please"
//                appState.fieldType = .custom([])
//                appState.openTextFieldWithAction { name in
//                  member.firstName = name
//                }
//              }
//
//              Divider()
//
//              MemberDataTextCellView(
//                text: member.viewLastName,
//                isEdit: isEdit,
//                imageName: "",
//                prompt: "last name",
//                scaleFactor: 0.2
//              )
//              .onTapGesture {
//                appState.cleanTFInfo()
//                appState.textfieldSource = member.viewLastName
//                appState.promptString = "Enter last name, please"
//                appState.fieldType = .custom([])
//                appState.openTextFieldWithAction { name in
//                  member.lastName = name
//                }
//              }
//
//              Divider()
//            }
//            .font(.title3)
//            .bold()
//            .frame(maxWidth: .infinity)
//
//          }
//
//          VStack {
//            MemberDataTextCellView(
//              text: member.viewPhoneNumber,
//              isEdit: isEdit,
//              imageName: "phone.circle.fill",
//              prompt: "phone number",
//              scaleFactor: 0.2
//            )
//            .onTapGesture {
//              appState.cleanTFInfo()
//              appState.textfieldSource = member.viewPhoneNumber
//              appState.promptString = "Enter phone number, please"
//              appState.fieldType = .custom([])
//              appState.openTextFieldWithAction { number in
//                member.phoneNumber = number
//              }
//            }
//
//            Divider()
//
//            MemberDataTextCellView(
//              text: member.viewEmail,
//              isEdit: isEdit,
//              imageName: "envelope.circle.fill",
//              prompt: "E-mail",
//              scaleFactor: 0.2
//            )
//            .onTapGesture {
//              appState.cleanTFInfo()
//              appState.textfieldSource = member.viewEmail
//              appState.promptString = "Enter e-mail, please"
//              appState.fieldType = .email
//              appState.openTextFieldWithAction { email in
//                member.email = email
//              }
//            }
//
//            Divider()
//
//            MemberDataTextCellView(
//              text: member.viewAddress,
//              isEdit: isEdit,
//              imageName: "map.circle.fill",
//              prompt: "Address",
//              scaleFactor: 0.2
//            )
//            .onTapGesture {
//              appState.cleanTFInfo()
//              appState.textfieldSource = member.viewAddress
//              appState.promptString = "Enter your address, please"
//              appState.fieldType = .custom([])
//              appState.openTextFieldWithAction { address in
//                member.homeAddress = address
//              }
//            }
//            Divider()
//          }
//        }
//        .padding(.top, 10)
//        .disabled(!isEdit)
//
//        VStack(alignment: .leading) {
//          GeometryReader { geo in
//            let cellWidth = (geo.size.width - 24) / 3
//
//            SelectableSmartCollectionView(
//              sourceContent: settings.userSpecialization,
//              selectedContent: $userSpecialization,
//              isEdit: $isEdit
//            ) {
//              RoundedRectangle(cornerRadius: 10.0).fill(.white.opacity(0.4))
//                .opacity(isEdit ? 0.5 : 0)
//            } cellView: { text in
//              SpecializationCellView(cellWidth: cellWidth, text: text)
//            } promptView: {
//              Text("Add specialization")
//                .font(.body)
//                .fontWeight(.light)
//                .foregroundStyle(Color(.systemGray))
//            }
//          }
//        }
//        .frame(maxWidth: .infinity)
//        //                Divider()
//        Spacer()
//      }
//      .frame(maxWidth: .infinity)
//      .padding(.horizontal)
//      .transitionWithOpacity()
    }
//    .ignoresSafeArea(.keyboard)
//    .navigationBarBackButtonHidden()
//    .onAppear {
//      userSpecialization = member.viewSpecialization
//      appState.primaryAction = {
//        if isEdit {
//          appState.setIconToPrimaryButton(.edit)
//          member.specializations = userSpecialization.joined(separator: ",")
//          member.lastUpdated = Date.now
//          try? dataManager.saveAndPublish(
//            publish: GlobalProperties.PublishChanges.members,
//            id: [member.viewId]
//          )
//          isEdit = false
//        } else {
//          appState.setIconToPrimaryButton(.accept)
//          isEdit = true
//        }
//      }
//      appState.secondaryAction = {}
//      appState.stepBackAction = {
//        appState.setMenuState(state: .none)
//        router.stepBack()
//      }
//    }
//    .onReceive(vm.$selectedPhoto) { newValue in
//      Task {
//        guard let item = newValue,
//          let data = try? await item.loadTransferable(
//            type: Data.self
//          ),
//          let uiimage = UIImage(data: data)
//        else { return }
//        await dataManager.updateImageWith(
//          uiimage: uiimage,
//          id: member.viewId,
//          type: GlobalProperties.ImageType.member,
//          lastUpdated: .now
//        )
//        dataManager.updatePublisher.send(
//          (GlobalProperties.PublishChanges.images, [member.viewId])
//        )
//      }
//    }
  }
}
//
//#if DEBUG
//  #Preview {
//    let dm = DataManager(globalDataManager: NetworkManager())
//    let appState = ApplicationState()
//    dm.networkManager.eventProgressHandler = appState
//    return RootView()
//      .environmentObject(GlobalSettings())
//      .environmentObject(SessionManager())
//      .environmentObject(appState)
//      .environmentObject(Router())
//      .environmentObject(dm)
//      .environment(\.managedObjectContext, dm.mainContext)
//  }
//#endif
