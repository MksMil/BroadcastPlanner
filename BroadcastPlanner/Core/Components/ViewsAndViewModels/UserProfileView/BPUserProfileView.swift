import SwiftUI
//import SDWebImageSwiftUI

struct BPUserProfileView: View {
    
    let user: Member
    
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
    }
   
    @ViewBuilder func infoBlock() -> some View{
        VStack{
            //photo here
            HStack {
                user.viewImage
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
                        //configure minimum scale factor
                    VStack(alignment: .leading){
                        Text(user.viewFirstName)
                            .padding(.vertical,4)
                            .padding(.horizontal,5)
                        Divider()
                        //configure minimum scale factor
                        Text(user.viewLastName)
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
                        //configure minimum scale factor
                        Link(user.viewPhoneNumber,
                             destination: URL(string:"tel:\(user.viewPhoneNumber)")!)
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
                        //configure minimum scale factor
                        Link(user.viewEmail,
                             destination: URL(string: "mailto:\(user.viewEmail)")!)
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
                        //configure minimum scale factor
                        Text(user.viewAddress)
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
//        VStack{
//            SmartLayout(hSpacing: 5, vSpacing: 5){
//                ForEach(member.userSpecialization,id: \.self) { text in
//                    BPSpecializationCellView(text: text.rawValue)
//                }
//            }
//            .padding(.horizontal,20)
//            .padding(.vertical,5)
//            Divider()
//                .padding(.horizontal,20)
//        }
        VStack {
            AnyContentView(
                sourceContent: UserSpecialization.allCases.map { $0.rawValue },
                selectedContent: .constant(user.viewSpecialization.map {$0.rawValue}),
                isEdit: .constant(false)
            ) {
                RoundedRectangle(cornerRadius: 10.0).fill(.white.opacity(0.4))
                    
            } cellView: { text in
                BPSpecializationCellView(text: text)
            } buttonView: {
                EmptyView()
//                Text("Done")
//                    .fixedSize()
//                    .padding(.horizontal, 20)
//                    .padding(.vertical, 4)
//                    .background {
//                        RoundedRectangle(cornerRadius: 10).fill(
//                            .white.opacity(0.4))
//                    }
            } promptView: {
                EmptyView()
//                Text("Tap to make choise of specialization")
//                    .font(.body)
//                    .fontWeight(.light)
//                    .foregroundStyle(Color(.systemGray))
            }
        }
        .disabled(true)
    }

}

//#Preview {
//    BPUserProfileView(member: MockData.sampleUser)
//}
