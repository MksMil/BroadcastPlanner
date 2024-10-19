import SwiftUI
import UIKit
import Combine
import PhotosUI

struct BPAccountInfoView: View {
    
    @EnvironmentObject var globalStorage: GlobalStorage
    
    @FetchRequest<LocalUser>(sortDescriptors: []) var localUser
    
    @State private var isEdit: Bool = false
    @State private var isEditSpecialization: Bool = false
    
    @State var showedImage: Image = Image(systemName: "person")
    
    @State var selectedPhoto: PhotosPickerItem?

    @State var inputImage: UIImage?
    
    @State private var firstName = ""
    @State private var lastName = ""
    @State private var email = ""
    @State private var address = ""
    @State private var phoneNumber = ""
    
    @State var userSpecialization: [String] = []
    
    var body: some View {
        NavigationStack(){
            ZStack{
                MainBackground()
                VStack{
                    VStack{
                        HStack {
                            PhotosPicker(selection: $selectedPhoto,
                                         matching: .images,
                                         photoLibrary: .shared()) {
                            showedImage
                                .resizable()
                                .scaledToFill()
                                .frame(width: 100,height: 100)
                                .clipShape(Circle())
                                .background{
                                    Circle()
                                        .fill(.ultraThickMaterial)
                                        .opacity(isEdit ? 0.8: 0.3)
                                        .frame(width: 110,height: 110)
                                }
                                .padding(.trailing,15)
                            }
                            VStack(alignment: .leading, spacing: 3){
                                
                                UserInfoTextField(text: $firstName,
                                                  isEdit: isEdit,
                                                  imageName: "",
                                                  prompt: "first name",
                                                  axis: .vertical)
                            
                                Divider()
                                
                                UserInfoTextField(text: $lastName,
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
                            VStack{
                                
                                UserInfoTextField(text: $phoneNumber,
                                                  isEdit: isEdit,
                                                  imageName: "phone.circle.fill",
                                                  prompt: "phone number",
                                                  axis: .horizontal)
                                
                                Divider()
                                
                                UserInfoTextField(text: $email,
                                                  isEdit: isEdit,
                                                  imageName: "envelope.circle.fill",
                                                  prompt: "E-mail",
                                                  axis: .horizontal)
                                   
                                Divider()
                                UserInfoTextField(text: $address,
                                                  isEdit: isEdit,
                                                  imageName: "map.circle.fill",
                                                  prompt: "Address",
                                                  axis: .vertical)
                                Divider()
                            }
                        }
                    }
                    .padding(.horizontal,20)
                    .padding(.top,10)
                    .disabled(!isEdit)
                    
                    .onChange(of: selectedPhoto) { value in
                        Task{
                            guard let item = selectedPhoto,
                                  let data = try? await item.loadTransferable(type: Data.self),
                                  let image = UIImage(data: data)
                            else { return }
                            withAnimation{
                                inputImage = image
                                showedImage = Image(uiImage: image)
                            }
                        }
                    }

                    SpecializationSection(specialization: $userSpecialization,
                                          isEditSpecialization: $isEditSpecialization,
                                          isEdit: isEdit)
                    Spacer()
                }
            }
            .navigationTitle(Text("My Info"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button{
                        withAnimation {
                            isEdit.toggle()
                            if isEditSpecialization {
                                isEditSpecialization.toggle()
                            }
                        }
                        if !isEdit {
                            Task{
                                updateUser()
                                await globalStorage.saveUser(userImage: inputImage)
                            }
                        }
                    }label: {
                        Text( isEdit ? "Save":"Edit")
                    }
                    .frame(alignment: .center)
                    .font(.headline)
                    .foregroundStyle(.blue)
                }
            }
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarBackground(.ultraThinMaterial, for: .navigationBar)
        }
        .onReceive(globalStorage.$localUser, perform: { user in
            
            firstName = user.userFirstName
            lastName = user.userLastName
            email = user.userEmail
            phoneNumber = user.userPhoneNumber
            address = user.userAddress
           
            showedImage =  user.userImage
            userSpecialization = user.userSpecialization.map{$0.rawValue}
        })
        .onAppear{
            localUser.nsPredicate = NSPredicate(format:"id == %@", globalStorage.id)
            guard let user = localUser.first else { return }
            
            firstName = user.userFirstName
            lastName = user.userLastName
            email = user.userEmail
            phoneNumber = user.userPhoneNumber
            address = user.userAddress
           
            showedImage =  user.userImage
            userSpecialization = user.userSpecialization.map{$0.rawValue}
        }
    }
    
    func updateUser(){
        globalStorage.localUser.firstName = firstName
        globalStorage.localUser.lastName = lastName
        globalStorage.localUser.email = email
        globalStorage.localUser.phoneNumber = phoneNumber
        globalStorage.localUser.homeAddress = address
        globalStorage.localUser.specializations = userSpecialization.joined(separator: ",")
        if let inputImage{
            globalStorage.localUser.image?.imageData = inputImage.pngData()
        }
        globalStorage.container.saveContext()
        
    }
}

struct SpecializationSection: View {
    
    @Binding var specialization: [String]
    @Binding var isEditSpecialization: Bool
    var isEdit: Bool
    
    var body: some View {
        VStack{
            AnyContentView(sourceContent: UserSpecialization.allCases.map{ $0.rawValue},
                           selectedContent: $specialization,
                           isEdit: $isEditSpecialization) {
                RoundedRectangle(cornerRadius: 10.0).fill(.ultraThinMaterial).opacity(isEdit ? 0.5 : 0)
            } cellView: { text in
                BPSpecializationCellView(text: text)
            } buttonView: {
                Text("Done")
                    .fixedSize()
                    .padding(.horizontal,20)
                    .padding(.vertical,4)
                    .background{
                        RoundedRectangle(cornerRadius: 10).fill(.ultraThinMaterial)
                    }
            } promptView: {
                Text("Tap to make choise of specialization")
                    .font(.body)
                    .fontWeight(.light)
                    .foregroundStyle(Color(.systemGray))
            }
            .padding(.vertical,0)
            .padding(.horizontal)
            Divider()
                .padding(.vertical,0)
                .padding(.horizontal,20)
        }
        .disabled(!isEdit)
    }
}

#Preview {
    BPAccountInfoView()
        .environmentObject(GlobalStorage(localUser: LocalUser(context: DataManager.preview.moc),networkManager: NetworkManager()))
        .environment(\.managedObjectContext, DataManager.preview.moc)
}

