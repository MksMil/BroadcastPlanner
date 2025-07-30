import SwiftUI

@MainActor
class ObvanInfoPanelViewModel: ObservableObject{
    let broadcast: Broadcast
    @Published var selectedObvan: Obvan?
    @Published var previewsCrew: [CrewPreview] = []

    var source: [String] = []
    
    init(broadcast: Broadcast,
         selected: Obvan?){
        self.broadcast = broadcast
        self.selectedObvan = selected
    }
    
    func make(){
        if let selectedObvan {
            var existingCrews = broadcast.viewCrews.filter { crew in
                crew.viewObvanId == selectedObvan.viewId
            }
            var result:[CrewPreview] = []
            selectedObvan.viewTemplateCrews.forEach { template in
                let position = template.viewPosition
                let member = existingCrews.first { crew in
                    crew.viewPosition == position
                }?.member
                let hardware = existingCrews.first { crew in
                    crew.viewPosition == position
                }?.hardware
                result.append(CrewPreview(position: position, member: member, hardware: hardware?.viewType))
                existingCrews.removeAll { crew in
                    crew.member == member
                }
            }
            previewsCrew = result.sorted(by: { first, second in
                source.firstIndex(of: first.position) ?? 0 < source.firstIndex(of: second.position) ?? 0
            })
        } else {
            previewsCrew = []
        }
        
    }
}


struct ObvanInfoPanelView: View {
    @EnvironmentObject var dataManager: DataManager
    @EnvironmentObject var settings: GlobalSettings
    
    @StateObject var vm: ObvanInfoPanelViewModel
    
    @FetchRequest<Obvan>(sortDescriptors: []) var obvans
    
    let broadcast: Broadcast
    
    init(broadcast: Broadcast,
         selectedObvan: Obvan? = nil){
        self.broadcast = broadcast
        self._vm = StateObject(wrappedValue: ObvanInfoPanelViewModel(broadcast: broadcast,selected: selectedObvan))
    }
    
    var body: some View {
#if DEBUG
        let _ = Self._printChanges()
#endif
        VStack{
            //TabView<Obvan>
            DividerWithText(text: "Obvans")
            TabViewList(source: obvans.map{$0}, selectedItem: vm.selectedObvan, pageCount: 2, spacing: 5) { obvan in
                withAnimation{
                    vm.previewsCrew = []
                    vm.selectedObvan = vm.selectedObvan == obvan ? nil : obvan
                    vm.make()

                }
            } content: { obvan in
                obvan.viewImage
                    .resizable()
                    .scaledToFit()
//                    .frame(width: 200,height: 100)
                    .opacity(obvan == vm.selectedObvan ? 1 : 0.5)
            }
            .frame(height:150)
           //Crew list
            DividerWithText(text: "Select Crews")
                ScrollView{
                    VStack(spacing: 6){
                        ForEach(0..<vm.previewsCrew.count, id:\.self){ index in
                            TemplateCrewView(crewPreview: vm.previewsCrew[index]){ crewPreview in
                                vm.previewsCrew[index].member = crewPreview.member
                                vm.previewsCrew[index].hardware = crewPreview.hardware
                            }
                            .frame(height:40)
                        }
                    }
                }
                .padding(.horizontal,5)
//            }
            Button("Status"){
                vm.previewsCrew.forEach { crew in
                    print("\(crew.position): \(crew.member?.viewCompactName ?? "empty"),-, \(crew.hardware ?? "empty")")
                }
            }
            Spacer()
        }
        .padding()
        .onAppear{
            //for alphabet sort of spec positions
            vm.source = settings.userSpecialization
        }
        .environmentObject(vm)
        //confirmation button group ?
        //on confirm -> vm.crews add to broadcast, selectedObvan add to broadcast
    }
}

#if DEBUG
#Preview {
    let dm = DataManager(globalDataManager: NetworkManager())
    let appState = ApplicationState()
    dm.networkManager.eventProgressHandler = appState
    return RootView()
        .environmentObject(GlobalSettings())
        .environmentObject(SessionManager())
        .environmentObject(appState)
        .environmentObject(Router())
        .environmentObject(dm)
        .environment(\.managedObjectContext, dm.mainContext)
}
#endif

//struct TemplateCrewView: View {
//    @EnvironmentObject var settings: GlobalSettings
//    @EnvironmentObject var vm: ObvanInfoPanelViewModel
//    let crewPreview: CrewPreview
//    let action: (CrewPreview)->()
//    @State var selectedMember: Member?
//    @State var selectedHardware: String?
//    @FetchRequest<Member>(sortDescriptors: []) var members
//    
//    init(crewPreview: CrewPreview, action: @escaping (CrewPreview) -> Void) {
//        self.crewPreview = crewPreview
//        self.selectedMember = crewPreview.member
//        self.selectedHardware = crewPreview.hardware
//        self.action = action
// }
//    
//    var body: some View {
//#if DEBUG
//        let _ = Self._printChanges()
//#endif
//        GeometryReader{ geo in
//            HStack{
//                Text(crewPreview.position)
//                    .lineLimit(1)
//                    .font(.system(size: 12))
//                    .minimumScaleFactor(0.3)
//                    .frame(width: geo.size.width / 4,alignment: .leading)
//                Divider()
//                Menu(selectedMember?.viewCompactName ?? (members.isEmpty ? "no crews": "Choose crew")) {
//                    ForEach(members){ member in
//                        //member cell
//                        Button {
//                            selectedMember = selectedMember == member ? nil: member
//                            crewPreview.member = selectedMember == member ? nil: member
//                            action(crewPreview)
//                        } label: {
//                            HStack{
//                                Text(member.viewCompactName)
//                            }
//                        }
//                        //TODO: disablebility and opacity
////                        .disabled(vm.broadcast.viewMembers.contains(member))
////                        .opacity(vm.broadcast.viewMembers.contains(member) ? 0.5:1)
//                    }
//                }
//                .disabled(members.isEmpty)
//                Spacer()
//                Divider()
//                Menu(selectedHardware ?? "Unknown",systemImage: "keyboard"){
//                    ForEach(settings.hardwareType, id:\.self){ type in
//                        Button("\(type)", action: {
//                            selectedHardware = selectedHardware == type ? nil: type
//                            crewPreview.hardware = selectedHardware == type ? nil: type
//                            action(crewPreview)
//                        })
//                    }
//                }
//                .font(.system(size: 12))
//                .minimumScaleFactor(0.4)
//                .frame(width: geo.size.width / 4,alignment: .leading)
//            }
//        }
//        .padding(4)
//        .background {
//            RoundedRectangle(cornerRadius: 5)
//                .fill( .ultraThinMaterial)
//                .overlay {
//                    RoundedRectangle(cornerRadius: 5)
//                        .stroke(.ultraThinMaterial,
//                                lineWidth: 2)
//                }
//        }
////        .task{
////            //TODO: compaund predicate
////            members.nsPredicate = NSPredicate(format: "specializations CONTAINS %@", crewPreview.position)
////        }
//        .onReceive(vm.$previewsCrew) { _ in
//            members.nsPredicate = NSPredicate(format: "specializations CONTAINS %@", crewPreview.position)
//            print("\(crewPreview.position): OnAppear, members: \(members.count)")
//        }
//        
//    }
//}

struct TemplateCrewView: View {
    @EnvironmentObject var settings: GlobalSettings
    @EnvironmentObject var vm: ObvanInfoPanelViewModel
    let crewPreview: CrewPreview
    let action: (CrewPreview) -> Void
    @State var selectedMember: Member?
    @State var selectedHardware: String?
    @State private var predicate: NSPredicate // Состояние для предиката
    private var members: FetchRequest<Member>

    init(crewPreview: CrewPreview, action: @escaping (CrewPreview) -> Void) {
        self.crewPreview = crewPreview
        self.selectedMember = crewPreview.member
        self.selectedHardware = crewPreview.hardware
        self.action = action
        // Инициализация предиката
        self._predicate = State(initialValue: NSPredicate(format: "specializations CONTAINS %@", crewPreview.position))
        // Инициализация FetchRequest с использованием предиката
        self.members = FetchRequest(
                    entity: Member.entity(),
                    sortDescriptors: [],
                    predicate: _predicate.wrappedValue
                )
    }

    var body: some View {
#if DEBUG
        let _ = Self._printChanges()
#endif
        GeometryReader { geo in
            HStack {
                Text(crewPreview.position)
                    .lineLimit(1)
                    .font(.system(size: 12))
                    .minimumScaleFactor(0.3)
                    .frame(width: geo.size.width / 4, alignment: .leading)
                Divider()
                Menu(selectedMember?.viewCompactName ?? (members.wrappedValue.isEmpty ? "no crews": "Choose crew")) {
                    ForEach(members.wrappedValue) { member in
                        Button {
                            selectedMember = selectedMember == member ? nil : member
                            crewPreview.member = selectedMember
                            action(crewPreview)
                        } label: {
                            HStack {
                                Text(member.viewCompactName)
                            }
                        }
                    }
                }
                .disabled(members.wrappedValue.isEmpty)
                Spacer()
                Divider()
                Menu(selectedHardware ?? "Неизвестно", systemImage: "keyboard") {
                    ForEach(settings.hardwareType, id: \.self) { type in
                        Button("\(type)", action: {
                            selectedHardware = selectedHardware == type ? nil : type
                            crewPreview.hardware = selectedHardware
                            action(crewPreview)
                        })
                    }
                }
                .font(.system(size: 12))
                .minimumScaleFactor(0.4)
                .frame(width: geo.size.width / 4, alignment: .leading)
            }
        }
        .padding(4)
        .background {
            RoundedRectangle(cornerRadius: 5)
                .fill(.ultraThinMaterial)
                .overlay {
                    RoundedRectangle(cornerRadius: 5)
                        .stroke(.ultraThinMaterial, lineWidth: 2)
                }
        }
        .onReceive(vm.$previewsCrew) { _ in
            // Обновление предиката при изменении previewsCrew
            predicate = NSPredicate(format: "specializations CONTAINS %@", crewPreview.position)
            print("\(crewPreview.position): OnAppear, members: \(members.wrappedValue.count)")
        }
    }
}

class CrewPreview : Identifiable{
    
    let id = UUID()
    var position: String
    var member: Member?
    var hardware: String?
    
    init(position: String, member: Member? = nil, hardware: String? = nil) {
        self.position = position
        self.member = member
        self.hardware = hardware
    }
}
