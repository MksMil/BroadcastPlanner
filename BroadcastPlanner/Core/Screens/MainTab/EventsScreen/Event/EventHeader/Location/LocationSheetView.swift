import SwiftUI

final class LocationSheetViewModel: ObservableObject{
    
}

struct LocationSheetView: View {
    @Environment(\.managedObjectContext) var moc
    
    @FetchRequest<LocalLocation>(sortDescriptors: []) var locations
    
    @State private var selectedLocation: LocalLocation?
    @State private var isAddEdit: Bool = false
    
    let cancelAction: ()-> Void
    let saveAction: (LocalLocation?)-> Void
    
    var body: some View {
        VStack{
            ConfirmationButtonGroupView(isAcceptDisabled: .constant(false), cancelAction: {
                cancelAction()
            }, acceptAction: {
                saveAction(selectedLocation)
            },content: {
                Button {
                    isAddEdit.toggle()
                } label: {
                    Image(systemName: "plus.square")
                        .resizable()
                        .scaledToFit()
                }

                
                                
            })
            .padding(.horizontal,10)
            .padding(.top, 10)
            .font(.title3)
            
            
            ScrollView{
                List{
                    ForEach(locations, id:\.id) { location in
                        Text("\(location.viewTitle)")
                        
                    }
                }
            }
            Spacer()
        }
//        .fullScreenCover(isPresented: $isAddEdit ) {
//            AddEditLocation(location: selectedLocation ?? DataManager.shared.fetchOrCreateLocationWithId(UUID().uuidString, inContext: .main)) {
//                
//            } acceptAction: { location in
//                
//            }
//        }
    }
}

#Preview {
    LocationSheetView(cancelAction: {}, saveAction: {_ in })
        .environment(\.managedObjectContext, DataManager.shared.moc)
        .environmentObject(MainRouter())
}
