import SwiftUI

struct ObvanInfoPanelView: View {
    @EnvironmentObject var dataManager: DataManager
    @EnvironmentObject var settings: GlobalSettings

    @EnvironmentObject var vm: AddEditPointOrObvanViewModel
    
    @FetchRequest<Obvan>(sortDescriptors: []) var obvans
    
    let sourceObvan: Obvan?
    
    init(selectedObvan: Obvan? = nil){
        self.sourceObvan = selectedObvan
    }
    
    var body: some View {
//#if DEBUG
//        let _ = Self._printChanges()
//#endif
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
//            Button("Status"){
//                vm.previewsCrew.forEach { crew in
//                    print("\(crew.position): \(crew.member?.viewCompactName ?? "empty"),-, \(crew.hardware ?? "empty")")
//                }
//            }
            Spacer()
        }
        .padding()
    }
}

//#if DEBUG
//#Preview {
//    let dm = DataManager(globalDataManager: NetworkManager())
//    let appState = ApplicationState()
//    dm.networkManager.eventProgressHandler = appState
//    return RootView()
//        .environmentObject(GlobalSettings())
//        .environmentObject(SessionManager())
//        .environmentObject(appState)
//        .environmentObject(Router())
//        .environmentObject(dm)
//        .environment(\.managedObjectContext, dm.mainContext)
//}
//#endif






