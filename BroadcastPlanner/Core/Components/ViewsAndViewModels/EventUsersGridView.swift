import SwiftUI

struct EventUsersGridView: View {
    var users: [LocalUser]
    
    
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
//    EventUsersGridView(users: [])
//        .environmentObject(GlobalStorage())
//}
