import SwiftUI
import SDWebImageSwiftUI

struct BPUserProfileView: View {
    var globalStorage: GlobalStorage
    
    @State var viewModel: BPUserProfileViewModel
   
    init(globalStorage: GlobalStorage, user: BPUserLocalData) {
        self.globalStorage = globalStorage
        self.viewModel = BPUserProfileViewModel(user: user)
        self.viewModel.globalStorage = globalStorage
    }
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
            .navigationTitle(Text(viewModel.user.isOnline ? "Online": "Offline"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                }
            }
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarBackground(.ultraThinMaterial, for: .navigationBar)
        }
    }
    
    
    
    @ViewBuilder func infoBlock() -> some View{
        VStack{
            //photo here
            HStack {
                WebImage(url: URL(string: viewModel.user.photoURL)) { image in
                    image
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
                        .padding(.trailing,15)
                } placeholder: {
                    Image(systemName: "person.crop.circle")
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
                        .padding(.trailing,15)
                }
                
                    VStack(alignment: .trailing){
                        Text(viewModel.user.firstName)
                            .padding(.vertical,4)
                            .padding(.horizontal,5)
                        Divider()
                        Text(viewModel.user.lastName)
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
                        Link(viewModel.user.phoneNumber,
                             destination: URL(string:"tel:\(viewModel.user.phoneNumber)")!)
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
                        Link(viewModel.user.email,
                             destination: URL(string: "mailto:\(viewModel.user.email)")!)
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
                        Text(viewModel.user.homeAddress)
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
                ForEach(viewModel.user.specialization,id: \.self) { text in
                    BPSpecializationCellView(text: text)
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
    BPUserProfileView(globalStorage: GlobalStorage(), 
                      user: MockData.sampleUser)
}
