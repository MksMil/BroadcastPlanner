import SwiftUI

struct ObvanCollectionView: View {
    @EnvironmentObject var appState: ApplicationState
    @EnvironmentObject var globalSettings: GlobalSettings
    @EnvironmentObject var dataManager: DataManager

    @EnvironmentObject var router: Router
    
    @FetchRequest<Obvan>(sortDescriptors: []) var obvans
    
    @State private var isEdit: Bool = false
    @State private var isRemoveObvanDialog: Bool = false
    @State private var visual: Double = 1
    @State private var selectedObvan: Obvan?
    
    var body: some View {
        ZStack {
            MainBackground()
            ScrollView{
                VStack{
                    ForEach(obvans) { obvan in
                        //TODO: make cell
                        ObvanCollectionCellView(title: obvan.viewName,
                                                count: obvan.viewTemplateCrews.count,
                                                isSelected: obvan == selectedObvan)
//                        .onTapGesture {
//                            withAnimation {
//                                if selectedObvan == obvan {
//                                    //isEdit = false
//                                    selectedObvan = nil
//                                    appState.setIconToPrimaryButton(.plus)
//                                    appState.makeSecondaryButtonEnabled(
//                                        false
//                                    )
//                                } else {
//                                    //isEdit = true
//                                    selectedObvan = obvan
//                                    appState.setIconToPrimaryButton(.edit)
//                                    appState.makeSecondaryButtonEnabled(
//                                        true
//                                    )
//                                }
//                            }
//                        }
                    }
                }
                .padding(10)
            }
            .opacity(visual)
            .scrollContentBackground(.hidden)
            .scrollIndicators(.never)
            .frame(maxWidth: .infinity,maxHeight: .infinity,alignment: .top)
            .padding(.horizontal, 5)
            .padding(.vertical, 5)
            .onTapGesture {
                withAnimation {
                    selectedObvan = nil
//                    appState.setIconToPrimaryButton(.plus)
//                    appState.makeSecondaryButtonEnabled(false)
                }
            }
            .transitionWithOpacity()
        }
        .onAppear {
            selectedObvan = nil
//            appState.primaryAction = {
//                visual = 0
//                var obvanToRoute: Obvan!
//                if let obvan = selectedObvan {
//                    obvanToRoute = obvan
//                } else {
//                    dataManager.mainContext.performAndWait {
//                        obvanToRoute = dataManager.mainContext.fetchOrCreateObject(
//                            withID: UUID().uuidString)
//                        let image: LocalImage = dataManager.mainContext.fetchOrCreateObject(withID: obvanToRoute.viewId)
//                        image.type = GlobalProperties.ImageType.obvan.rawValue
//                        obvanToRoute.image = image
//                        image.addToParentObvan(obvanToRoute)
//                        
//                    }
//                }
////                router.routeTo(path: .addEditObvan(obvanToRoute))
//            }
//            appState.secondaryAction = {
//                isRemoveObvanDialog = true
//            }
//            appState.stepBackAction = {
//                router.stepBack()
//            }
        }
        .navigationBarBackButtonHidden()
        .confirmationDialog(
            Text("Permanently erase the Obvan in the trash?"),
            isPresented: $isRemoveObvanDialog
        ) {
            Button("Remove Obvan", role: .destructive) {
                // Handle empty trash action.
//                if let obvan = selectedObvan {
//                    selectedObvan = nil
//                    let id = obvan.viewId
//                    let imageId: String? = obvan.image?.viewId
//                    
//                    dataManager.mainContext.performAndWait{
//                        dataManager.mainContext.delete(obvan)
//                        try? dataManager.saveAndPublish(
//                            publish: GlobalProperties.PublishChanges.obvans,
//                            id: []
//                        )
//                    }
//                    appState.setIconToPrimaryButton(.plus)
//                    appState.makeSecondaryButtonEnabled(false)
                    //remove from network image & club
//                    Task{
//                        if let imageId{
//                            dataManager.removeImageWithId(id: imageId)
//                        }
//                        await dataManager.networkManager.removeDataOfType(GlobalProperties.Path.obvans, withId: id)
//                    }
                    
//                }
            }
        }
    }
}

//#Preview {
//    ObvanCollectionView()
//}

struct ObvanCollectionCellView: View {
    let title: String
    let count: Int
    let isSelected: Bool
    
    var body: some View {
        VStack(alignment: .leading,spacing: 2){
            Text(title)
                .font(.title)
                .bold()
                .minimumScaleFactor(0.4)
            
            Text("\(count) crews")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity,
               alignment: .leading)
        .padding(.vertical,8)
        .padding(.horizontal,12)
        .background {
            RoundedRectangle(cornerRadius: 5).fill(.ultraThinMaterial)
        }
        .padding(.horizontal)
        .padding(.vertical,5)
        .scaleEffect(isSelected ? 1.05: 1)
        .opacity(isSelected ? 1 : 0.65)
    }
}
