import Combine
import CoreData
import SwiftUI

struct MainEventsList: View {
    @EnvironmentObject var mdm: DataManager
    @EnvironmentObject var router: Router

    //    @StateObject private var eventRouter = EventTabRouter()

    @FetchRequest<Broadcast>(sortDescriptors: [
        SortDescriptor(\.date, order: .forward)
    ]) var broadcasts
    @State private var selectedBroadcast: Broadcast?

    @State private var filter: FilterEventOwnerCases = FilterEventOwnerCases
        .notFiltered
    @State private var expired: Bool = true
    @State private var title: String = "All Events"
    
    

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
                                withAnimation(.easeIn(duration: 0.1)) {
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
                                    router.routeTo(path: .createEdit(broadcast),withTransition: .fade(.out))
                                }
                                .transition(
                                    .move(edge: .top).combined(with: .opacity)
                                )
                                .animation(
                                    .easeIn(duration: 0.3),
                                    value: filter
                                )
                                .animation(
                                    .easeIn(duration: 0.3),
                                    value: expired
                                )
                        }
                    }
                }
                .padding(.horizontal, 8)
                if mdm.accessLevel < 2 {
                    Button {
                        Task{
                            selectedBroadcast = try? await  mdm.createEventWithCurrentUserOwnerInContextType()
                            if let selectedBroadcast {
                                router.routeTo(path: .createEdit(selectedBroadcast))
                            }
                        }
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
        }
        .onAppear{
            print("in on appear")
            selectedBroadcast = nil
        }
        .onReceive(mdm.updatePublisher) { value in
            if value.0 == GlobalProperties.PublishChanges.broadcasts {
                print("broadcasts update received in EventList")
//                updateEvents()
            }
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
            corePredicate = NSPredicate(format: "id != %@", "")  //NSPredicate(format: "owners CONTAINS %@",mdm.currentUserInMainContext)
            newTitle = "My owned broadcasts"
        case .userPartisipation:
            corePredicate = NSPredicate(format: "id != %@", "")
            //NSPredicate(
            //                format: "members CONTAINS %@",
            //                argumentArray: [mdm.currentUser]
            //            )
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
            title = newTitle
            broadcasts.nsPredicate = NSCompoundPredicate(
                andPredicateWithSubpredicates: predicateArray
            )
        }
    }
}

#Preview {
    RootView()
        .environmentObject(GlobalSettings())
        .environmentObject(SessionManager())
        .environmentObject(ApplicationState())
        .environmentObject(Router())
}
