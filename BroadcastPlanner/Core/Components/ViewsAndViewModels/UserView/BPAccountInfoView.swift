//
//  BPAccountInfoView.swift
//  BroadcastPlanner
//
//  Created by Миляев Максим on 04.04.2024.
//

import SwiftUI
import UIKit

struct BPAccountInfoView: View {
    
    var globalStorage: GlobalStorage
    
    var body: some View {
        NavigationStack{
            ZStack{
                MainBackground()
                VStack{
                    InfoBlock(viewModel: globalStorage.accountInfoViewModel)
                    SpecializationSection(viewModel: globalStorage.accountInfoViewModel)
                    Spacer()
                }
            }
            .navigationTitle(Text("My Info"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button{
                        withAnimation {
                            globalStorage.accountInfoViewModel.isEdit.toggle()
                            if globalStorage.accountInfoViewModel.isEditSpec {
                                globalStorage.accountInfoViewModel.isEditSpec.toggle()
                            }
                        }
                        if !globalStorage.accountInfoViewModel.isEdit {
                            Task{
                                await globalStorage.accountInfoViewModel.save()
                            }
                        }
                    }label: {
                        EditButtonText(vm: globalStorage.accountInfoViewModel)
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

struct EditButtonText: View {
    @StateObject var vm: BPAccountInfoViewModel
    var body: some View {
        Text(vm.isEdit ? "Save":"Edit")
    }
}

struct InfoBlock: View {
    
    @StateObject var viewModel: BPAccountInfoViewModel
    @State var inputImage: UIImage?
    @State var showImagePicker: Bool = false
//    var tapAction: ()->()
    
    var body: some View {
        VStack{
            HStack {
                viewModel.userImage
                    .resizable()
                    .scaledToFill()
                    .frame(width: 100,height: 100)
                    .clipShape(Circle())
                    .background{
                        Circle()
                            .fill(.ultraThickMaterial)
                            .opacity(viewModel.isEdit ? 0.8: 0.3)
                            .frame(width: 110,height: 110)
                    }
                    .padding(.trailing,15)
                    .onTapGesture {
//                        tapAction()
                        showImagePicker.toggle()
                    }
                    .disabled(!viewModel.isEdit)
                
                
                VStack{
                    BPInfoTextFieldWithIcon(
                        viewModel: viewModel,
                        text: $viewModel.firstName,
                        iconName: "",
                        promptText: "First Name"
                    )
                    Divider()
                    BPInfoTextFieldWithIcon(
                        viewModel: viewModel,
                        text: $viewModel.lastName,
                        iconName: "",
                        promptText: "Last Name"
                    )
                    Divider()
                }
                .font(.title2)
                .bold()
                .frame(maxWidth: .infinity)
                
            }
            .padding(.vertical)
            Section {
                VStack{
                    BPInfoTextFieldWithIcon(
                        viewModel: viewModel,
                        text: $viewModel.phoneNumber,
                        iconName: "phone.circle.fill",
                        promptText: "PhoneNumber"
                    )
                    Divider()
                    BPInfoTextFieldWithIcon(
                        viewModel: viewModel,
                        text: $viewModel.email,
                        iconName: "envelope.circle.fill",
                        promptText: "E-mail"
                    )
                    
                    Divider()
                    BPInfoTextFieldWithIcon(
                        viewModel: viewModel,
                        text: $viewModel.homeAddress,
                        iconName: "map.circle.fill",
                        promptText: "Address"
                    )
//                    
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
                    viewModel.userImage = Image(uiImage: image)
                }
            }
        })
        
    }
}

struct SpecializationSection: View {
    
    @StateObject var viewModel: BPAccountInfoViewModel
    
    var body: some View {
        VStack{
            AnyContentView(sourceContent: UserSpecialization.allCases.map{ $0.rawValue},
                           selectedContent: $viewModel.specialization,
                           isEdit: $viewModel.isEditSpec) {
                RoundedRectangle(cornerRadius: 10.0).fill(.ultraThinMaterial).opacity(viewModel.isEdit ? 0.5 : 0)
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
        .disabled(!viewModel.isEdit)
    }
}

#Preview {
    BPAccountInfoView(globalStorage: GlobalStorage())
}

