import SwiftUI

struct ObvanInfoPanelView: View {
    @EnvironmentObject var dataManager: DataManager
    @EnvironmentObject var settings: GlobalSettings

    @EnvironmentObject var vm: AddEditPointOrObvanViewModel
        
    let broadcast: Broadcast
    @State var selectedObvan: Obvan?
    
    @State var source: [ObvanTemplateCrew]
    @FetchRequest<Obvan>(sortDescriptors: []) var obvans
    
    init(broadcast:Broadcast,selectedObvan: Obvan? = nil){
        self.broadcast = broadcast
        self.selectedObvan = selectedObvan
        
        if let selectedObvan {
            self.source = selectedObvan.viewTemplateCrews.sorted(by: { first, second in
                first.viewPosition < second.viewPosition
            })
        } else {
            self.source = []
        }
    }
    
    var body: some View {
        VStack{
            DividerWithText(text: "Obvans")
            TabViewList(source: obvans.compactMap{
                if $0 == selectedObvan{
                    return $0
                }
                return broadcast.viewObvans.contains($0) ? nil: $0
            },
                        selectedItem: selectedObvan,
                        pageCount: 2,
                        spacing: 5) { obvan in
                selectedObvan = selectedObvan == obvan ? nil : obvan
                vm.selectedObvan = vm.selectedObvan == obvan ? nil : obvan
                updateSource()
            } content: { obvan in
                VStack(spacing: 0){
                    Text(obvan.viewName)
                        .font(.title)
                        .minimumScaleFactor(0.5)
                    ImageWrapper(id: obvan.viewId, type: .obvan,imageSize: ImageSizes.mediumImages)
                        .scaledToFit()
                }
                    .opacity(obvan == selectedObvan ? 1 : 0.5)
            }
            .frame(height:150)
           //Crew list
            DividerWithText(text: "Select Crews")
                ScrollView{
                    VStack(spacing: 6){
                        ForEach(source){ crew in
                            TemplateCrewView(broadcast: broadcast,
                                             template: crew)
                            .frame(height:40)
                        }
                    }
                }
                .padding(.horizontal,5)
            Spacer()
        }
        .padding()
    }
    
    func updateSource(){
        if let selectedObvan {
            self.source = selectedObvan.viewTemplateCrews.sorted(by: { first, second in
                first.viewPosition < second.viewPosition
            })
        } else {
            self.source = []
        }
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






