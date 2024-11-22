//
//  EventHeaderSheet.swift
//  BroadcastPlanner
//
//  Created by Миляев Максим on 22.11.2024.
//

import SwiftUI

struct EventHeaderSheet: View {
    
    @Binding var state: SheetState
    @State var isEditMode: Bool = false

    let event: LocalEvent
    
    @State var selectedClub: LocalClub?

    @State var previousFlow: SheetState = .none
 
    var body: some View {
        switch state {
        case .selectHomeClubFlow, .selectGuestClubFlow :
            ClubSheetView {
                state = .none
            } acceptAction: { club in
                switch state {
                case .selectHomeClubFlow:
                    event.homeClub = club
                    state = .none
                case .selectGuestClubFlow:
                    event.guestClub = club
                    state = .none
                default: return
                }
            } defineLocation: { club in
                selectedClub = club
                previousFlow = state
            }

        case .selectLocationForEvent, .selectLocationForClub :
            LocationFlow(isEditMode: $isEditMode) {
                switch state {
                case .selectLocationForEvent:
                    state = .none
                case .selectLocationForClub:
                    state = .selectLocationForEvent
                default: return
                }
            } acceptAction: { localLocation in
                switch state {
                case .selectLocationForEvent:
                    event.location = localLocation
                    state = .none
                case .selectLocationForClub:
                    if let selectedClub {
                        selectedClub.homeLocation = localLocation
                        localLocation.addToHomeClub(selectedClub)
                    }
                    state = previousFlow
                default: return
                }
            }
        case .none:
            EmptyView()
        }
    }
    
}
//#Preview {
//    EventHeaderSheet()
//}

#Preview {
    NavigationStack{
        BPCreateEditEventView(event: LocalEvent(context: DataManager.shared.moc))
    }
            .environmentObject(GlobalSettings())
            .environmentObject(GlobalSessionStorage())
            .environmentObject(EventTabRouter())
            .environment(\.managedObjectContext, DataManager.shared.moc)
}
