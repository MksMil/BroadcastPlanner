import SwiftUI
import UIKit

struct BPAccountInfoView: View {
    
    @State private var isEdit: Bool = false
    @State private var isEditSpecialization: Bool = false
    
    @State var user: BPUser
    @State var image: UIImage?
    
    let saveAction: (BPUser, UIImage?) -> Void
    
    var body: some View {
        NavigationStack(){
            ZStack{
                MainBackground()
                VStack{
                    InfoBlock(userImage: $image, user: $user, isEdit: isEdit)
                    SpecializationSection(specialization: $user.specialization, isEditSpecialization: $isEditSpecialization, isEdit: isEdit)
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
                               saveAction(user,image)
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
    
    var isEdit: Bool
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
//                    .animation(.easeIn(duration: 0.5), value: showedImage)
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
                    .disabled(!isEdit)
                
                VStack{
                    
                    UserInfoTextField(text: $user.firstName, isEdit: isEdit, imageName: "", prompt: "first name", axis: .vertical)
                    
                    Divider()
                    
                    UserInfoTextField(text: $user.lastName, isEdit: isEdit, imageName: "", prompt: "last name", axis: .vertical)
                    
                    Divider()
                }
                .font(.title2)
                .bold()
                .frame(maxWidth: .infinity)
                
            }
            .padding(.vertical)
            Section {
                VStack{
                    
                    UserInfoTextField(text: $user.phoneNumber, isEdit: isEdit, imageName: "phone.circle.fill", prompt: "phone number", axis: .vertical)
                    
                    Divider()
                    
                    UserInfoTextField(text: $user.email, isEdit: isEdit, imageName: "envelope.circle.fill", prompt: "E-mail", axis: .vertical)
                    
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
                withAnimation(.easeIn(duration: 0.2)) {
                    showedImage = Image(uiImage: image)
                    userImage = image
                }
            }
        })
        
    }
}

struct UserInfoTextField: View {
    
    @Binding var text: String
    var isEdit: Bool
    var imageName: String
    var prompt: String
    var axis: Axis
    
    var body: some View {
        HStack(alignment: .center){
            Label("", systemImage: imageName)
                .labelStyle(.iconOnly)
                .font(.title)
            
            TextField("", text: $text, prompt: Text(prompt), axis: axis)
                .font(.title3)
                .padding(5)
                .background {
                    RoundedRectangle(cornerRadius: 10.0).fill(.ultraThinMaterial).opacity(isEdit ? 0.5 : 0)
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
            .padding(.horizontal)
            Divider()
                .padding(.horizontal,20)
        }
        .disabled(!isEdit)
    }
}

#Preview {
    BPAccountInfoView(user: BPUser(), saveAction: { user, image in print("\(user.firstName) saved")
        print("specialization: \(user.specialization)")})
}

