import SwiftUI

struct EventUsersGridView: View {
    var users: [BPUser]
    var images: [String: UIImage]
    
    var body: some View {
        ScrollView{
            SmartLayout(hSpacing: 5, vSpacing: 5){
                ForEach(users, id: \.id){ user in
                    BPUserDataListCellView(text: user.firstName,
                                           image: images[user.id])
                }
            }
        }
    }
}

//#Preview {
//    EventUsersGridView(users: [])
//        .environmentObject(GlobalStorage())
//}
