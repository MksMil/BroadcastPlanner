import SwiftUI

struct PanelUserCollectionView: View {
    
    let users: [Member]
    let availableUsers: [Member]
    let addAction: (Member)->()
    let removeAction: (Member)->()
    
    
    @State private var isSelect: Bool = false
    @State private var isConfirm: Bool = false
    @State private var userToRemove: Member?
    
    init(users: [Member],availableUsers: [Member],addAction: @escaping (Member)->(), removeAction: @escaping (Member)->()) {
        self.users = users
        self.availableUsers = availableUsers
        self.addAction = addAction
        self.removeAction = removeAction
    }
    
    var body: some View {
        ScrollView{
            Button{
                isSelect = true
            } label: {
                HStack(spacing: 0){
                    Image(systemName: "plus")
                        .resizable()
                        .scaledToFit()
                        .padding(5)
                        .background {
                            Circle().fill(.ultraThinMaterial)
                        }
                        .padding(3)
                    Divider()
                        .padding(.vertical,3)
                    
                    Text("Add user")
                        .font(.system(size: 14))
                        .lineLimit(1)
                        .minimumScaleFactor(0.2)
                        .padding(.horizontal,5)
                    Spacer()
                }
                .frame(maxWidth: .infinity)
                .frame(height: 40)
                .background(.ultraThinMaterial)
                .overlay {
                    RoundedRectangle(cornerRadius: 5).stroke(.ultraThickMaterial, lineWidth: 2)
                }
                .padding(2)
            }
            
            ForEach(users){user in
                BPUserImageNameCompactCell(user: user){
                    userToRemove = user
                    isConfirm = true
                }
            }
            
       }
        .sheet(isPresented: $isSelect) {
            List{
                ForEach(availableUsers){ user in
                    //user cell
//                    Text("\(user.userFirstName) \(user.userLastName)")
                    AddUnitFormUserCell(user: user, infoAction: {
                        
                    })
                        .onTapGesture {
                            addAction(user)
                            isSelect = false
                        }
                }
                .listRowBackground(Color.clear)
            }
            .scrollContentBackground(.hidden)
            .listStyle(.inset)
            .presentationBackground(.ultraThinMaterial)
            .presentationDetents([.fraction(0.5)])
        }
        .confirmationDialog("", isPresented: $isConfirm) {
            Button("Remove user", role: .destructive) {
                if let userToRemove{
                    removeAction(userToRemove)
                }
            }
        }
    }
}
