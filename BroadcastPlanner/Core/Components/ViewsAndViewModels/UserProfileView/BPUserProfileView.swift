import SwiftUI
import SDWebImageSwiftUI

struct BPUserProfileView: View {
    
    var user: BPUser
    var image: UIImage?
    
    var body: some View {
            
            ZStack{
                MainBackground()
                VStack{
                    infoBlock()
                    specializationSection()
                        .disabled(true)
                    Spacer()
                }
            }
            .navigationTitle(Text(user.isOnline ? "Online": "Offline"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                }
            }
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarBackground(.ultraThinMaterial, for: .navigationBar)
        
    }
   
    @ViewBuilder func infoBlock() -> some View{
        VStack{
            //photo here
            HStack {
                    makeImage()
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
                
                    VStack(alignment: .leading){
                        Text(user.firstName)
                            .padding(.vertical,4)
                            .padding(.horizontal,5)
                        Divider()
                        Text(user.lastName)
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
                        
                        Link(user.phoneNumber,
                             destination: URL(string:"tel:\(user.phoneNumber)")!)
                            .padding(.vertical,4)
                            .padding(.horizontal,5)
                        Spacer()
                    }
                    Divider()
                    HStack{
                        Image(systemName: "envelope.circle.fill")
                            .resizable()
                            .frame(width: 30,height: 30)
                            .scaledToFill()
                        
                        Link(user.email,
                             destination: URL(string: "mailto:\(user.email)")!)
                            .padding(.vertical,4)
                            .padding(.horizontal,5)
                        Spacer()
                    }
                    Divider()
                    HStack{
                        Image(systemName: "map.circle.fill")
                            .resizable()
                            .frame(width: 30,height: 30)
                            .scaledToFill()

                        Text(user.homeAddress)
                            .padding(.vertical,4)
                            .padding(.horizontal,5)
                        Spacer()
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
                ForEach(user.specialization,id: \.self) { text in
                    BPSpecializationCellView(text: text)
                }
            }
            .padding(.horizontal,20)
            .padding(.vertical,5)
            Divider()
                .padding(.horizontal,20)
        }
    }
    
    
    // MARK: - Image loader
    func makeImage() -> Image{
        guard let image else {
            return Image(systemName: "person.crop.circle")
        }
        return Image(uiImage: image)
    }
}

//#Preview {
//    BPUserProfileView(user: MockData.sampleUser)
//}
