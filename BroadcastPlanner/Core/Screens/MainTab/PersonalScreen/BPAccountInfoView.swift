import SwiftUI
import UIKit
import Combine

struct BPAccountInfoView: View {
    
    @EnvironmentObject var globalStorage: GlobalStorage
    
    @State private var isEdit: Bool = false
    @State private var isEditSpecialization: Bool = false
    
    @State var user: BPUser
    @State var image: UIImage?
    
    let saveAction: (BPUser, UIImage?) async -> Void
    
    var body: some View {
        NavigationStack(){
            ZStack{
                MainBackground()
                VStack{
                    InfoBlock(userImage: $image, user: $user, isEdit: $isEdit)
                    SpecializationSection(specialization: $user.specialization, isEditSpecialization: $isEditSpecialization, isEdit: isEdit)
                    Spacer()
                }
                
            }
            .onReceive(globalStorage.$currentUser, perform: { user in
                guard let user else {
                    self.user = BPUser()
                    return
                }
                self.user = user
            })
            .onReceive(globalStorage.$userProfileImage, perform: { image in
                self.image = image
            })
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
                              await saveAction(user,image)
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
    }
}


struct InfoBlock: View {

    @Binding var userImage: UIImage?
    @Binding var user: BPUser
    
    @State var showedImage: Image = Image(systemName: "person.circle")
    
    @Binding var isEdit: Bool
    @State var inputImage: UIImage?
    @State var showImagePicker: Bool = false
    
    var body: some View {
        VStack{
            HStack {
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
                    .onTapGesture {
                        showImagePicker.toggle()
                    }
                  
                VStack(alignment: .leading, spacing: 3){
                    
                    UserInfoTextField(text: $user.firstName, isEdit: isEdit, imageName: "", prompt: "first name", axis: .vertical)
                
                    Divider()
                    
                    UserInfoTextField(text: $user.lastName, isEdit: isEdit, imageName: "", prompt: "last name", axis: .vertical)
                    
                    Divider()
                }
                .font(.title3)
                .bold()
                .frame(maxWidth: .infinity)
                
            }
            .padding(.vertical)
            Section {
                VStack{
                    
                    UserInfoTextField(text: $user.phoneNumber, isEdit: isEdit, imageName: "phone.circle.fill", prompt: "phone number", axis: .horizontal)
                    
                    Divider()
                    
                    UserInfoTextField(text: $user.email, isEdit: isEdit, imageName: "envelope.circle.fill", prompt: "E-mail", axis: .horizontal)
                       
                    
                    Divider()
                    UserInfoTextField(text: $user.homeAddress, isEdit: isEdit, imageName: "map.circle.fill", prompt: "Address", axis: .vertical)
                  
                    Divider()
                }
            }
        }
        .padding(.horizontal,20)
        .padding(.top,10)
        .sheet(isPresented: $showImagePicker) {
            ImagePicker(image: $inputImage)
                .ignoresSafeArea()
        }
        .onChange(of: inputImage, perform: { _ in
            if let image = inputImage {
                    userImage = image
            }
        })
        .onChange(of: userImage, perform: { _ in
            if let image = userImage {
                withAnimation(.easeIn(duration: 0.3)){
                    showedImage = Image(uiImage: image)
                }
            }
        })
        .disabled(!isEdit)
    }
}

struct UserInfoTextField: View {
    @Binding var text: String
    var isEdit: Bool
    var imageName: String
    var prompt: String
    var axis: Axis
    
    var body: some View {
        HStack{
            if !imageName.isEmpty{
                Image(systemName: imageName)
                    .resizable()
                    .frame(width: 30,height: 30)
                    .scaledToFill()
            }
            
            // TODO: Text content type?
            TextField("", text: $text, prompt: Text(prompt), axis: axis)
                .autocorrectionDisabled()
                .padding(.vertical,4)
                .padding(.horizontal,5)
                .background {
                    RoundedRectangle(cornerRadius: 5.0).fill(.ultraThinMaterial).opacity(isEdit ? 0.5 : 0)
                }

        }
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
        
//        .border(Color.black)
        
        .disabled(!isEdit)
    }
}

#Preview {
    BPAccountInfoView(user: BPUser(), saveAction: { user, image in print("\(user.firstName) saved")
        print("specialization: \(user.specialization)")})
    .environmentObject(GlobalStorage())
}

