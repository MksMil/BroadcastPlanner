import SwiftUI
@MainActor
class ObvanCollectionViewModel: ObservableObject {
  private let dataManager: DataManager
  private let router: Router
  
  @Published var isRemoveObvanDialog: Bool = false
  @Published var images: [String: UIImage] = [:] 


  init(dataManager: DataManager, router: Router) {
    self.dataManager = dataManager
    self.router = router
  }
  
  func loadImages(obvans: [Obvan]) async {
      for obvan in obvans {
          guard !obvan.viewImageId.isEmpty else { continue }
          let image = await dataManager.getImageWithId(
              obvan.viewImageId,
              type: .obvan,
              size: .smallImages
          )
          if let image {
              images[obvan.viewId] = image
          }
      }
  }
  
  
  func goBack() {
    router.stepBack()
  }
  
  func editSelectedObvan(obvan: Obvan){
      router.routeToEditObvan(obvan: obvan)
  }
  
  func addNewObvan(){
    router.routeToEditObvan(obvan: nil)
  }
}

struct ObvanCollectionView: View {
  @EnvironmentObject var appState: ApplicationState
  @StateObject private var vm: ObvanCollectionViewModel
  
  @FetchRequest<Obvan>(sortDescriptors: []) var obvans
  
  init(dataManager: DataManager, router: Router){
    self._vm = StateObject(wrappedValue: ObvanCollectionViewModel(dataManager: dataManager, router: router))
  }
    
    var body: some View {
        ZStack {
            MainBackground()
          VStack(spacing: 6){
            ScrollView{
              VStack{
                ForEach(obvans) { obvan in
                  ObvanPickerCell(obvan: obvan,
                                  image: vm.images[obvan.viewId])
                  .onTapGesture {
                    withAnimation {
                      vm.editSelectedObvan(obvan: obvan)
                    }
                  }
                }
              }
              .padding(10)
            }
            .scrollContentBackground(.hidden)
            .scrollIndicators(.never)
            .frame(maxWidth: .infinity,maxHeight: .infinity,alignment: .top)
            .padding(.horizontal, 5)
            .padding(.vertical, 5)
            
            Button {
              vm.addNewObvan()
                   } label: {
                       HStack {
                           Image(systemName: "plus.circle")
                               .font(.system(size: 18, weight: .medium))
                           Text("New Obvan")
                               .font(.headline)
                       }
                       .foregroundStyle(.primary)
                       .frame(maxWidth: .infinity)
                       .frame(height: 50)
                   }
                   .background(.ultraThinMaterial)
                   .clipShape(RoundedRectangle(cornerRadius: 14))
                   .overlay {
                       RoundedRectangle(cornerRadius: 14)
                           .stroke(Color.white.opacity(0.5), lineWidth: 1)
                   }
                   .padding(.horizontal, 16)
          }
            .transitionWithOpacity()
        }
        .onAppear{
          appState.backAction = vm.goBack
        }
        .task(id: obvans.map(\.viewId)) {
           await vm.loadImages(obvans: Array(obvans))
        }
        .navigationBarBackButtonHidden()
    }
}

//#Preview {
//    ObvanCollectionView()
//}
