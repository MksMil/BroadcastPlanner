//
//  BPAccountInfoView.swift
//  BroadcastPlanner
//
//  Created by Миляев Максим on 04.04.2024.
//

import SwiftUI
import UIKit

struct BPAccountInfoView: View {
    @EnvironmentObject var globalStorage: GlobalStorage
//    @State var user: BPUser?
    @StateObject private var viewModel: UserViewModel = UserViewModel()
    @State var showImagePicker: Bool = false
  
    @State var inputImage: UIImage?
    @State var isEdit: Bool = false
    @State var isEditSpec: Bool = false
    
    var body: some View {
        NavigationStack{
            
            ZStack{
                MainBackground()
                Color.clear
                VStack{
                    infoBlock()
                    specializationSection()
                        .disabled(!isEdit)
                    Spacer()
                }
            }
            .navigationTitle(Text("Hello, \(viewModel.firstName.isEmpty ? "Guest":viewModel.firstName)"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button{
                        withAnimation {
                            isEdit.toggle()
                            if isEditSpec {
                                isEditSpec.toggle()
                            }
                        }
                        if !isEdit {
                            Task{
                                await viewModel.save(in: globalStorage)
                            }
                        }
                    }label: {
                        Text(isEdit ? "Save":"Edit")
                    }
                    .frame(alignment: .center)
                    .font(.headline)
                    .foregroundStyle(.blue)
                    
                }
                
            }
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarBackground(.ultraThinMaterial, for: .navigationBar)
        }
        .sheet(isPresented: $showImagePicker) {
            ImagePicker(image: $inputImage)
                .ignoresSafeArea()
        }
        .onChange(of: inputImage, perform: { _ in
            if let image = inputImage {
                withAnimation(.easeIn(duration: 0.2)) {
                    viewModel.userImage = Image(uiImage: image)
                }
            }
        })
        .onChange(of: globalStorage.currentUser, perform: { value in
            viewModel.user = globalStorage.currentUser
        })
    }
    
    
    
    @ViewBuilder func infoBlock() -> some View{
        VStack{
            //photo here
            HStack {
                viewModel.userImage
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
                    .onTapGesture {
                        showImagePicker.toggle()
                    }
                    .disabled(!isEdit)
                
                
                    VStack(alignment: .leading){
                        TextField("FirstName", text: $viewModel.firstName,axis: .vertical)
                            .multilineTextAlignment(.trailing)
                            .padding(.vertical,4)
                            .padding(.horizontal,5)
                            .background{
                                RoundedRectangle(cornerRadius: 8).fill(.ultraThickMaterial).opacity(isEdit ? 0.3: 0)
                            }
                            .disabled(!isEdit)
                        Divider()
                        TextField("LastName", text: $viewModel.lastName,axis: .vertical)
                            .multilineTextAlignment(.trailing)
                            .padding(.vertical,4)
                            .padding(.horizontal,5)
                            .background{
                                RoundedRectangle(cornerRadius: 8).fill(.ultraThickMaterial).opacity(isEdit ? 0.3: 0)
                            }
                            .disabled(!isEdit)
                        Divider()
                    }
                    .font(.title2)
                    .bold()
                    .frame(maxWidth: .infinity,alignment: .leading)
                
            }
            .padding(.vertical)
            Section {
                VStack{
                    HStack{
                        Image(systemName: "phone.circle.fill")
                            .resizable()
                            .frame(width: 30,height: 30)
                            .scaledToFill()
                        TextField("PhoneNumber", text: $viewModel.phoneNumber)
                        //                        .textFieldStyle(.roundedBorder)
                            .multilineTextAlignment(.trailing)
                            .padding(.vertical,4)
                            .padding(.horizontal,5)
                            .background{
                                RoundedRectangle(cornerRadius: 8).fill(.ultraThickMaterial).opacity(isEdit ? 0.3: 0)
                            }
                            .disabled(!isEdit)
                    }
                    Divider()
                    HStack{
                        Image(systemName: "envelope.circle.fill")
                            .resizable()
                            .frame(width: 30,height: 30)
                            .scaledToFill()
                        TextField("E-mail", text: $viewModel.email,axis: .vertical)
                            .multilineTextAlignment(.trailing)
                            .padding(.vertical,4)
                            .padding(.horizontal,5)
                            .background{
                                RoundedRectangle(cornerRadius: 8).fill(.ultraThickMaterial).opacity(isEdit ? 0.3: 0)
                            }
                            .disabled(!isEdit)
                    }
                    Divider()
                    HStack{
                        Image(systemName: "map.circle.fill")
                            .resizable()
                            .frame(width: 30,height: 30)
                            .scaledToFill()
                        TextField("Address", text: $viewModel.homeAddress,axis: .vertical)
                            .multilineTextAlignment(.trailing)
                            .padding(.vertical,4)
                            .padding(.horizontal,5)
                            .background{
                                RoundedRectangle(cornerRadius: 8).fill(.ultraThickMaterial).opacity(isEdit ? 0.3: 0)
                            }
                            .disabled(!isEdit)
                    }
                    Divider()

                }
            }
        }
        .padding(.horizontal,20)
        .padding(.top,10)
    }
    @ViewBuilder func specializationSection() -> some View {
        VStack{
            AnyContentView(sourceContent: UserSpecialization.allCases.map{ $0.rawValue},
                           selectedContent: $viewModel.specialization,
                           isEdit: $isEditSpec) {
                RoundedRectangle(cornerRadius: 10.0).fill(.ultraThinMaterial).opacity(isEdit ? 0.5 : 0)
//                                    .randomColorBackground()

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
                Text("choose specialization")
                    .font(.body)
                    .fontWeight(.light)
                    .foregroundStyle(Color(.systemGray))
            }
            .padding(.horizontal)
            Divider()
                .padding(.horizontal,20)
        }
    }
}

#Preview {
    BPAccountInfoView()
    .environmentObject(GlobalStorage())
}

//user: BPUser(id: "",
//                               email: "денег@net.com",
//                               firstName: "Олег",
//                               phNum: "0123456789",
//                               homeAddress: "Kyiv city",
//                               specialization: [UserSpecialization.cameramen,UserSpecialization.director])
