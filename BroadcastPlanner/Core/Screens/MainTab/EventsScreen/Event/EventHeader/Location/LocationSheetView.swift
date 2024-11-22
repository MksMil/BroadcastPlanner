import SwiftUI

final class LocationSheetViewModel: ObservableObject{
    
}

struct LocationSheetView: View {
    @Environment(\.managedObjectContext) var moc
    
    @FetchRequest<LocalLocation>(sortDescriptors: []) var locations
    
    @State private var selectedLocation: LocalLocation?
    @Binding var isAddEdit: Bool
    
    let cancelAction: ()-> Void
    let saveAction: (LocalLocation?)-> Void
    
    var body: some View {
        VStack{
            ConfirmationButtonGroupView(isAcceptDisabled: false, cancelAction: {
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
    }
}

#Preview {
    LocationSheetView(isAddEdit: .constant(false), cancelAction: {}, saveAction: {_ in })
        .environment(\.managedObjectContext, DataManager.shared.moc)
        .environmentObject(MainRouter())
}
