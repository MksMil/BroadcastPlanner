import SwiftUI

struct StaffPanelView: View {
    let event: Broadcast

    @FetchRequest<Member>(sortDescriptors: []) var users
    var availableUsers: [Member] {
        users.filter{$0.isAvailableTo(broadcast: event)}
    }
        
    let addUnitAction: (Member, UserSpecialization, ReplayType?)->()
    let removeUnitAction: (Crew)->()
    let editUnitAction: ()->()
    
    @State private var isAddUnit: Bool = false
    
    init(event: Broadcast,
         addUnitAction: @escaping (Member, UserSpecialization, ReplayType?) -> Void,
         removeUnitAction: @escaping (Crew) -> Void,
         editUnitAction: @escaping () -> Void) {
        self.event = event
        self.addUnitAction = addUnitAction
        self.removeUnitAction = removeUnitAction
        self.editUnitAction = editUnitAction
    }
    
    var body: some View {
        VStack{
            Button("Add new crew"){
                isAddUnit = true
            }
            .padding(8)
            .background {
                RoundedRectangle(cornerRadius: 5)
                    .fill(.white.opacity(0.4))
                    .overlay {
                        RoundedRectangle(cornerRadius: 5)
                            .stroke(.white.opacity(0.4),
                                    lineWidth: 2)
                    }
            }
            .padding(8)
            List{
                ForEach(event.viewCrews){ unit in
                    StaffPanelCellView(unit: unit)
                        .listRowBackground(Color.clear)
                }
                .onDelete { indexSet in
                    guard let index = indexSet.first else { return }
                    let unitToRemove = event.viewCrews[index]
                    removeUnitAction(unitToRemove)
                }
            }
            .scrollContentBackground(.hidden)
            .listStyle(.inset)
        }
        .frame(maxWidth: .infinity)
        .fullScreenCover(isPresented: $isAddUnit) {
            AddUnitFormView(availableUsers: availableUsers){
                isAddUnit = false
            } addAction: {specialization, localUser, hardware in
                isAddUnit = false
                addUnitAction(localUser, specialization, hardware)
            }
            .presentationBackground(Color.black.opacity(0.8))
        }
    }
}

struct StaffPanelCellView: View {
    
    let unit: Crew
    
    var body: some View {
        HStack{
            unit.member?.viewImage
                .resizable()
                .scaledToFill()
                .clipShape(Circle())
                .overlay(content: {
                    Circle().stroke(Color.white, lineWidth: 2)
                })
                .frame(width:30, height: 30)
            VStack(alignment: .leading){
                if let user = unit.member{
                    Text(user.viewCompactName)
                        .font(.system(size: 14))
                        .minimumScaleFactor(0.6)
                } else {
                    Text("---")
                        .font(.system(size: 14))
                        .minimumScaleFactor(0.6)
                }
                    
                Text(unit.viewPosition.rawValue)
                    .font(.system(size: 11))
                    .minimumScaleFactor(0.6)
            }
        }
    }
}

//#Preview(body: {
//    AddUnitFormView(availableUsers: []){
//        
//    } addAction: { _,_,_ in
//        
//    }
//})

#Preview(body: {
    let lm = DataManager(forPreview: true)

    let localEvent = lm.fetchOrCreateObject(ofType: Broadcast.self,
                  predicate: NSPredicate(format: "id == %@", "id"),
                                      in: lm.mainContext) { ctx in
        let newEvent = Broadcast(context: ctx)
        newEvent.id = "id"
        return newEvent
    }
    return StaffPanelView(event:localEvent) { _, _, _ in
        
    } removeUnitAction: { _ in
        
    } editUnitAction: {
        
    }

})
