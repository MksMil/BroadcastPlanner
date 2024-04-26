//
//  BPAccountInfoView.swift
//  BroadcastPlanner
//
//  Created by Миляев Максим on 04.04.2024.
//

import SwiftUI

struct BPAccountInfoView: View {
    @EnvironmentObject var globalStorage: GlobalStorage
    
    // TODO: vm or something with environment must be here
    
    @State var personalImage: Image = Image(systemName: "person.circle")
    @State var inputImage: UIImage?
    @State var showImagePicker: Bool = false
    
    var cells: [UserSpecialization]
    @State var firstName: String = ""
    @State var middleName: String = ""
    @State var lastName: String = ""
    @State var phoneNumber: String = ""
    @State var email: String = ""
    @State var address: String = ""
    @State var tags: [UserSpecialization] = []
    @State var textInfo: String = "About you"
    
    @State var isEdit: Bool = false
    @State var editOn = false
    
    
    
    var body: some View {
        ZStack{
            BackgroundTabItem()
            ScrollViewReader { scrollViewProxy in
                ScrollView {
                        infoBlock()
                        specializationTagSection()
                            .id("tagID")
                            .onChange(of: isEdit, perform: { value in
                                    scrollViewProxy.scrollTo("tagID",
                                                             anchor: .center)
                            })
//
                        TextEditor(text: $textInfo)
                            .redacted(reason: .placeholder)
                            .scrollContentBackground(.hidden)
                            .foregroundStyle(.black)
                            .padding()
                            .concaveWith(color: .mainBackground, cornerRadius: 10)
                            .frame(minHeight: 200)
                            .padding(.horizontal)
                        
                        Spacer(minLength: isEdit ? 300: 100)
                            .id("Editor bottom spacer")
                            .onChange(of: textInfo, perform: { value in
                                scrollViewProxy.scrollTo("Editor bottom spacer",
                                                         anchor: .bottom)
                            })
                        
                    }
                .padding(.bottom, isEdit ? 0 :60)
                }
                
//            }
            
            if !isEdit {
                VStack{
                    Spacer()
                    
                    Button(action: {
//                        isEdit.toggle()
                    }, label: {
                        Text("Save")
                            .padding()
                            .padding(.horizontal,60)
                            .background {
                                RoundedRectangle(cornerRadius: 10).fill(.regularMaterial)
                            }
                    })
                    //                .padding(.bottom)
                }
                .frame(maxWidth: .infinity)
                .foregroundColor(.accent)
            }
        }
        
        .sheet(isPresented: $showImagePicker) {
            ImagePicker(image: $inputImage)
                .ignoresSafeArea()
        }
        .onChange(of: inputImage, perform: { _ in
            if let image = inputImage {
                withAnimation(.easeIn(duration: 0.2)) {
                    personalImage = Image(uiImage: image)
                }
            }
        })
    }
    @ViewBuilder func infoBlock() -> some View{
        VStack{
            //photo here
            personalImage
                .resizable()
                .scaledToFill()
                .frame(width: 100,height: 100)
                .clipShape(Circle())
                .padding(10)
                .concaveWith(color: .mainBackground, cornerRadius: 60)
                .onTapGesture {
                    showImagePicker.toggle()
                }
            
            Section {
                VStack(alignment: .leading){
                    TextField("FirstName", text: $firstName)
                    Divider()
                    TextField("MiddleName", text: $middleName)
                    Divider()
                    TextField("LastName", text: $lastName)
                }
                .bold()
                .frame(maxWidth: .infinity,alignment: .leading)
            } header: {
                Text("Personal Info")
                    .padding(8)
            }
            
            Section {
                VStack{
                    TextField("PhoneNumber", text: $phoneNumber)
                    Divider()
                    TextField("E-mail", text: $email)
                    Divider()
                    TextField("Address", text: $address)
                }
                //        Text("homeAddress") // map?
                
            } header: {
                Text("Contacts")
                    .padding(8)
            }
        }
        .padding()
        .concaveWith(color: .mainBackground, cornerRadius: 15)
        .padding()
    }
    @ViewBuilder func specializationTagSection() -> some View{
        AnyContentView(sourceContent: UserSpecialization.allCases,
                       selectedContent: $tags,
                       isEdit: $isEdit) {
            RoundedRectangle(cornerRadius: 10)
                .fill(.clear)
                .concaveWith(color: .mainBackground, cornerRadius: 10)
        } cellView: { tag in
            BPSpecializationCellView(specialization: tag,textColor: .black)
                .concavable(cornerRadius: 5,
                            color: tags.contains(tag) ? .mainBackground :.gray.opacity(0.15),
                            isSelected: tags.contains(tag))
        } buttonView: {
            Text(isEdit ? "Done":"Choose")
                .padding()
                .convex(color: .mainBackground, cornerRad: 15)
               
        } promptView: {
            Text("Choose specialization")
                .padding(3)
                .foregroundStyle(.secondary)
        }
        
        .padding()
    }
}

#Preview {
    BPAccountInfoView(cells: UserSpecialization.allCases)
        .environmentObject(GlobalStorage())
}
