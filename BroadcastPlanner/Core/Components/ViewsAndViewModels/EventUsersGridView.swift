import SwiftUI

struct EventUsersGridView: View {
    var users: [Member]
    
    
    var body: some View {
        ScrollView{
            SmartLayout(hSpacing: 5, vSpacing: 5){
                ForEach(users){ user in
                    BPUserDataListCellView(user: user, text: "text")
                }
            }
        }
    }
}

//#Preview {
//    EventUsersGridView(members: [])
//        .environmentObject(GlobalStorage())
//}
