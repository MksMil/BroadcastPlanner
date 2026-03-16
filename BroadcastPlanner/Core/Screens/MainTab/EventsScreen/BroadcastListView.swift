import Combine
import CoreData
import SwiftUI

struct BroadcastListView: View {
    @EnvironmentObject var dataManager: DataManager
    @EnvironmentObject var router: Router
    @EnvironmentObject var appState: ApplicationState

    @FetchRequest<Broadcast>(sortDescriptors: [
        SortDescriptor(\.date, order: .forward)
    ]) var broadcasts
    @State private var selectedBroadcast: Broadcast?

    @State private var filter: FilterEventOwnerCases = FilterEventOwnerCases
        .notFiltered
    @State private var expired: Bool = true
    @State private var opacity: Double = 1

    var body: some View {
        ZStack {
            MainBackground()
            
            VStack {
                Rectangle().fill(.white.opacity(0.4))
                    .frame(maxWidth: .infinity)
                    .frame(height: 55)
                
                    .overlay {
                        HStack {
                            Spacer()
                            BPEventFilterCaseTabView<FilterEventOwnerCases>(
                                selectedTab: $filter
                            ) {
                                updateEvents()
                            }
                            Spacer()
                            Divider()
                            Button {
                                withAnimation(.easeIn(duration: 0.3)) {
                                    expired.toggle()
                                }
                                updateEvents()
                            } label: {
                                Image(systemName: "hourglass")
                                    .resizable()
                                    .scaledToFit()
                                    .padding(12)
                                    .opacity(expired ? 1 : 0.2)
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.vertical, 5)
                    }
                
                ScrollView {
                    VStack {
                        ForEach(broadcasts) { broadcast in
                            MainEventListCell(event: broadcast)
                                .id(broadcast.viewId)
                                .onTapGesture {
                                    selectedBroadcast = broadcast
//                                    router.routeTo(path: .createEdit(broadcast))
                                }
                                .transition(
                                    .move(edge: .top)
                                    .combined(with: .opacity)
                                    
                                )
                                .animation(.easeIn(duration: 0.3), value: filter)
                        }
                    }
                    .frame(maxWidth: .infinity) // need to correct animation of changes of list!  (if (list empty & !maxWidth) - added 'scale' to transition animation of cell)
                }
                .padding(.horizontal, 8)
                .opacity(opacity)
                //TODO: fix access
                if dataManager.accessLevel < 2 {
                    Button {
                            opacity = 0
//                        Task{
//                            selectedBroadcast = try? await  dataManager.createEventWithCurrentUserOwnerInContextType()
//                            if let selectedBroadcast {
//                                router.routeTo(path: .createEdit(selectedBroadcast))
//                            } else {
//                                withAnimation(.easeOut(duration: 0.1)){
//                                    opacity = 1
//                                }
//                            }
//                        }
                    } label: {
                        Text("New Broadcast")
                            .font(.title2)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background {
                                RoundedRectangle(cornerRadius: 15).fill(
                                    Color.white
                                )
                            }
                    }
                    .padding(.bottom)
                    .padding(.horizontal)
                }
            }
            .navigationBarBackButtonHidden()
            .transitionWithOpacity()
        }
        .onAppear{
            selectedBroadcast = nil
        }
    }
    func updateEvents() {
        var newTitle = ""
        var corePredicate: NSPredicate
        
        switch filter {
            case .notFiltered:
                corePredicate = NSPredicate(format: "id != %@", "")
                newTitle = "All Events"
            case .userOwned:
                corePredicate = NSPredicate(format: "ANY owners.id == %@",dataManager.currentId)
                newTitle = "My owned broadcasts"
            case .userPartisipation:
                corePredicate = NSPredicate(format: "SUBQUERY(venuePoints, $point, ANY $point.members.id == %@).@count > 0 OR SUBQUERY(crews, $crew, $crew.member.id == %@).@count > 0" ,dataManager.currentId,dataManager.currentId)
                newTitle = "My participation"
        }
        var predicateArray = [corePredicate]
        if !expired {
            let expiredPredicate = NSPredicate(
                format: "date > %@",
                argumentArray: [Date.now]
            )
            predicateArray.append(expiredPredicate)
        }
        withAnimation(.easeIn(duration: 0.3)) {
            appState.setTitle(newTitle)
            broadcasts.nsPredicate = NSCompoundPredicate(
                andPredicateWithSubpredicates: predicateArray
            )
        }
    }
}

