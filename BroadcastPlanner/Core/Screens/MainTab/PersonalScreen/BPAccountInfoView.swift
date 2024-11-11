import Combine
import PhotosUI
import SwiftUI
import UIKit

struct BPAccountInfoView: View {

    @StateObject var vm: PersonalScreenViewModel

    @FetchRequest<LocalUser>(sortDescriptors: []) var localUser

    @State private var isEdit: Bool = false
    @State private var isEditSpecialization: Bool = false

    init(id: String) {
        self._vm = StateObject(wrappedValue: PersonalScreenViewModel(id: id))
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
                                    .scaledToFill()
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
                                    axis: .vertical)

                                Divider()

                                UserInfoTextField(
                                    text: $vm.lastName,
                                    isEdit: isEdit,
                                    imageName: "",
                                    prompt: "last name",
                                    axis: .vertical)

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
                                    axis: .horizontal)

                                Divider()

                                UserInfoTextField(
                                    text: $vm.email,
                                    isEdit: isEdit,
                                    imageName: "envelope.circle.fill",
                                    prompt: "E-mail",
                                    axis: .horizontal)

                                Divider()
                                UserInfoTextField(
                                    text: $vm.address,
                                    isEdit: isEdit,
                                    imageName: "map.circle.fill",
                                    prompt: "Address",
                                    axis: .vertical)
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
                                await vm.saveNewDataToLocalUser()
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
            .toolbarBackground(.ultraThinMaterial, for: .navigationBar)
        }
        .onReceive(DataManager.shared.updatePublisher, perform: { value in
            if value.0 == .users, value.1.contains(where: { $0 == vm.id
            }){
                vm.updateData()
            }
        })

    }
}

struct SpecializationSection: View {

    @Binding var specialization: [String]
    @Binding var isEditSpecialization: Bool
    var isEdit: Bool

    var body: some View {
        VStack {
            AnyContentView(
                sourceContent: UserSpecialization.allCases.map { $0.rawValue },
                selectedContent: $specialization,
                isEdit: $isEditSpecialization
            ) {
                RoundedRectangle(cornerRadius: 10.0).fill(.ultraThinMaterial)
                    .opacity(isEdit ? 0.5 : 0)
            } cellView: { text in
                BPSpecializationCellView(text: text)
            } buttonView: {
                Text("Done")
                    .fixedSize()
                    .padding(.horizontal, 20)
                    .padding(.vertical, 4)
                    .background {
                        RoundedRectangle(cornerRadius: 10).fill(
                            .ultraThinMaterial)
                    }
            } promptView: {
                Text("Tap to make choise of specialization")
                    .font(.body)
                    .fontWeight(.light)
                    .foregroundStyle(Color(.systemGray))
            }
        }
        .disabled(!isEdit)
    }
}

#Preview {
    BPAccountInfoView(id: "123")
        .environment(\.managedObjectContext, DataManager.shared.moc)
}
