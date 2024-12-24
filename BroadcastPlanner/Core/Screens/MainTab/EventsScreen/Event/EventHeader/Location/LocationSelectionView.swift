//
//  LocationSelectionView.swift
//  BroadcastPlanner
//
//  Created by Миляев Максим on 16.12.2024.
//

import SwiftUI

final class LocationSelectionViewModel: ObservableObject{
    @Published var isLocationSheetPresented: Bool = false
    
    @Published var title: String
    @Published var address: String
    @Published var images: [Image] = []
    
    
    var location: LocalLocation?
    
    init(location: LocalLocation?){
        self.title = location?.viewTitle ?? ""
        self.address = location?.viewAddress ?? ""
        self.images = location?.viewImages ?? []
        self.location = location
    }
    
    func update(newLocation: LocalLocation ){
        self.location = newLocation
        title = newLocation.viewTitle
        address = newLocation.viewAddress
        images = newLocation.viewImages
    }
}


struct LocationSelectionView: View {
    
    @StateObject private var vm: LocationSelectionViewModel
    
    let location: LocalLocation?
    let cancelAction: ()->Void
    let acceptAction: (LocalLocation)->Void
    
    init(location: LocalLocation?, cancelAction: @escaping () -> Void, acceptAction: @escaping (LocalLocation) -> Void) {
        self.location = location
        self._vm = StateObject(wrappedValue: LocationSelectionViewModel(location: location))
        self.cancelAction = cancelAction
        self.acceptAction = acceptAction
    }
    
    var body: some View {
        ZStack{
            HeaderBackgroundTimelineView(images: vm.images)
            VStack(spacing: 20) {
                // location title
                Spacer()
                Text(vm.title)
                    .frame(minWidth: 200)
                    .font(.title2)
                    .lineLimit(2)
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
                
                //loation address
                Text(vm.address)
                    .frame(minWidth: 200)
                    .font(.footnote)
                    .lineLimit(2)
                    .padding(5)
                    .background(
                        RoundedRectangle(cornerRadius: 5).fill(
                            .ultraThinMaterial
                        ).overlay {
                            RoundedRectangle(cornerRadius: 5).stroke(
                                .white, lineWidth: 1)
                        }
                    )
                    .onTapGesture {
                        vm.isLocationSheetPresented.toggle()
                    }
            }
            .padding(.bottom)
        }
        .sheet(isPresented: $vm.isLocationSheetPresented) {
            LocationSheetView(isEditMode: false, club: nil) {
                cancelAction()
                vm.isLocationSheetPresented.toggle()
            } saveAction: { newLocation in
                guard let newLocation else { return }
                vm.update(newLocation: newLocation)
                acceptAction(newLocation)
                vm.isLocationSheetPresented.toggle()
            } addEditAction: { location in
                
            }
        }
    }
}

#Preview {
    LocationSelectionView(location: nil) {
        
    } acceptAction: { _ in
        
    }

}
