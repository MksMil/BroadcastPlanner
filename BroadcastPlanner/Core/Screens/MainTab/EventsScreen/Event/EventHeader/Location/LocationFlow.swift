import SwiftUI

struct LocationFlow: View {
    
    @Binding var isEditMode: Bool
    let cancelAction: ()->Void
    let acceptAction: (LocalLocation)->Void
    
    @State var selectedLocaltion: LocalLocation?
    
    var locationToRoute: LocalLocation {
        if let selectedLocaltion{
            return selectedLocaltion
        } else {
            return DataManager.shared.fetchOrCreateLocationWithId(UUID().uuidString, inContext: .main)
        }
    }
    
    
    var body: some View {
        if !isEditMode {
            LocationSheetView(isAddEdit: $isEditMode) {
                isEditMode.toggle()
            } saveAction: { _ in
                isEditMode.toggle()
            }
        } else {
            AddEditLocation(location: locationToRoute) {
                isEditMode.toggle()
            } acceptAction: {
                isEditMode.toggle()
            }
        }
    }
}

#Preview {
    LocationFlow(isEditMode: .constant(true)) {
        
    } acceptAction: { _ in
        
    }

}
