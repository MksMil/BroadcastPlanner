import SwiftUI

struct LocationSelectionView: View {
    @EnvironmentObject var dataManager: DataManager
    @StateObject private var vm: LocationSelectionViewModel
    
    let venue: Venue?
    let offset: Double
    let editable: Bool
    let cancelAction: ()->Void
    let acceptAction: (Venue)->Void
    
    
    init(location: Venue?,
         offset: Double,
         editable: Bool = true,
         cancelAction: @escaping () -> Void,
         acceptAction: @escaping (Venue) -> Void) {
        self.venue = location
        self.offset = offset
        self.editable = editable
        self._vm = StateObject(wrappedValue: LocationSelectionViewModel(location: location))
        self.cancelAction = cancelAction
        self.acceptAction = acceptAction
    }
    
    var body: some View {
        ZStack{
            HeaderBackgroundTimelineView(image: vm.image)
            
            VStack(spacing: 5) {
                // venue title
                Text(vm.title)
                    .font(.title2)
                    .lineLimit(2)
                
                //venue address
                Text(vm.address)
                    .font(.footnote)
                    .lineLimit(2)
            }
            .frame(minWidth: 150)
            .padding(5)
            .background(
                RoundedRectangle(cornerRadius: 5)
                    .fill(.ultraThinMaterial)
                    .overlay {
                        RoundedRectangle(cornerRadius: 5)
                            .stroke(.white, lineWidth: 1)
                    }
            )
            .onTapGesture {
                vm.isLocationSheetPresented.toggle()
            }
            .padding(.top,offset + 10)
            .disabled(!editable)
        }
        .task {
            guard let venue else {
                vm.updateImages(newImages: [])
                return
            }
            // убираем вложенный Task — используем .task напрямую
            var images: [Image] = []
            for localImage in venue.viewLocalImages {
                // проверяем отмену между итерациями
                try? Task.checkCancellation()
                if let uiimage = await dataManager.getImageWithId(
                    localImage.viewId,
                    type: .venue,
                    size: .mediumImages  // ← originImages для фона избыточно, mediumImages достаточно
                ) {
                    images.append(Image(uiImage: uiimage))
                }
            }
            vm.update(title: venue.viewTitle,
                      address: venue.viewAddress,
                      images: images)
        }
        .onDisappear(perform: {
            vm.stop()
        })
        .sheet(isPresented: $vm.isLocationSheetPresented) {
            VenueSelectionSheetView(selectedVenue: vm.venue){ venue in
              guard let venue else { return }
                  Task {
                      await vm.loadImagesForVenue(venue, using: dataManager)
                      acceptAction(venue)
                  }
            }
            .presentationDragIndicator(.visible)
        }
    }
}

//#Preview {
//    let mdm = DataManager(globalDataManager: NetworkManager())
//    mdm.setMember(id: "123")
//    let localEvent: Broadcast = mdm.mainContext.fetchOrCreateObject(withID: "id")
//
//    return BroadcastEditView(broadcast:localEvent)
//        .environmentObject(SessionManager())
//        .environmentObject(GlobalSettings())
//        .environment(\.managedObjectContext, mdm.mainContext)
//        .environmentObject(mdm)
//}
