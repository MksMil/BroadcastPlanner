import SwiftUI
import Combine

struct BPCreateEditEventView: View {
    
    @EnvironmentObject var globalStorage: GlobalStorage
    @EnvironmentObject var eventRouter: EventTabRouter
    
    @State var event: Event
        
    @State private var type: PlanSectionType?
    
    var body: some View {
        
            ZStack(alignment: .bottomTrailing){
                MainBackground()
                
                VStack(alignment: .leading){
                    //date
                    BPEventHeaderView(event: $event)
                        .frame(maxWidth: .infinity)
                        .frame(height: 300)
                        .padding(.top,30)
                    GeometryReader{ geo in
                        BPEditEventPointLinks(event: event){
                            type = .stadium
                        } actionRight: {
                            type = .car
                        }
                        .frame(height: geo.size.width / 2)
                    }
                    .padding()
                    //staff list
                    ScrollView{
                        LazyVGrid(columns: [GridItem(.flexible()),GridItem(.flexible())], content: {
                            ForEach(globalStorage.users, id: \.id){ user in
                                BPUserDataListCellView(user: user)
                            }
                        })
                    }
                    .padding(.horizontal,10)
                    Spacer()
                }
                .frame(maxWidth: .infinity)
                .ignoresSafeArea()
                
                // MARK: - save / delete hstack
                
                HStack{
                    Button {
                        Task{
                            globalStorage.removeEvent(event)
                            eventRouter.routeStepBack()
                        }
                    } label: {
                        Capsule()
                            .fill(.ultraThickMaterial)
                            .frame( height: 30)
                            .overlay {
                                HStack{
                                    Text("Delete")
                                }
                            }
                            .shadow(color: .red.opacity(0.4),
                                    radius: 4)
                    }
                    Button {
                        Task{
                            await  globalStorage.updateEvent(event)
                        }
                    } label: {
                        Capsule()
                            .fill(.ultraThickMaterial)
                            .frame( height: 30)
                            .overlay {
                                HStack{
                                    Text("Save")
                                }
                            }
                            .shadow(color: .green.opacity(0.4),
                                    radius: 4)
                    }
                }
                .font(.title2)
                .padding()
            }
            .fullScreenCover(item: $type) { type in
                BPEditConteinerView(event: event, type: type)
            }
        }
}

#Preview {
    BPCreateEditEventView( event: MockData.sampleEvent)
        .environmentObject(GlobalSettings())
        .environmentObject(GlobalStorage())
        .environmentObject(EventTabRouter())
        .environmentObject(GlobalTimer())
}
