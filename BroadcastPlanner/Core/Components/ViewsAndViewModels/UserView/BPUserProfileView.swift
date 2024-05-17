//
//  BPUserProfileView.swift
//  BroadcastPlanner
//
//  Created by Миляев Максим on 15.05.2024.
//

import SwiftUI

struct BPUserProfileView: View {
    @EnvironmentObject var globalStorage: GlobalStorage
    @State var user: BPUser
    @StateObject private var viewModel: UserViewModel = UserViewModel()
    
    var body: some View {
        NavigationStack{
            
            ZStack{
                MainBackground()
                VStack{
                    infoBlock()
                    specializationSection()
                        .disabled(true)
                    Spacer()
                }
            }
            .navigationTitle(Text(viewModel.isOnline ? "Online": "Offline"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .primaryAction) {

                    
                }
                
            }
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarBackground(.ultraThinMaterial, for: .navigationBar)
        }
        .onAppear {
            viewModel.user = user
            viewModel.setup()
        }
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
                            .opacity(0.3)
                            .frame(width: 110,height: 110)
                    }
                
                    VStack(alignment: .trailing){
                        Text(viewModel.firstName)
                            .padding(.vertical,4)
                            .padding(.horizontal,5)
                        Divider()
                        Text(viewModel.lastName)
                            .padding(.vertical,4)
                            .padding(.horizontal,5)
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
                        Spacer()
                        Link(viewModel.phoneNumber,destination: URL(string:"tel:\(viewModel.phoneNumber)")!)
                            .padding(.vertical,4)
                            .padding(.horizontal,5)
                    }
                    Divider()
                    HStack{
                        Image(systemName: "envelope.circle.fill")
                            .resizable()
                            .frame(width: 30,height: 30)
                            .scaledToFill()
                        Spacer()
                        Link(viewModel.email, destination: URL(string: "mailto:\(viewModel.email)")!)
                            .padding(.vertical,4)
                            .padding(.horizontal,5)
                    }
                    Divider()
                    HStack{
                        Image(systemName: "map.circle.fill")
                            .resizable()
                            .frame(width: 30,height: 30)
                            .scaledToFill()
                        Spacer()
                        Text(viewModel.homeAddress)
                            .padding(.vertical,4)
                            .padding(.horizontal,5)
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
            SmartLayout(hSpacing: 5, vSpacing: 5){
                ForEach(viewModel.specialization.indices, id:\.self) { index in
                    Text(viewModel.specialization[index])
                        .padding(.horizontal,8)
                        .padding(.vertical,4)
                        .background {
                            RoundedRectangle(cornerRadius: 5).fill(.thinMaterial)
                        }
                }
            }
            .padding(.horizontal,20)
            .padding(.vertical,5)
            Divider()
                .padding(.horizontal,20)
        }
    }
}

#Preview {
    BPUserProfileView(user: BPUser(id: "",
                                   email: "денег@net.com",
                                   firstName: "Олег",
                                   phNum: "380951917323",
                                   homeAddress: "Kyiv city", specialization: [UserSpecialization.cameramen]))
        .environmentObject(GlobalStorage())
}
