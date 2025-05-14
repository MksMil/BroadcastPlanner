import SwiftUI

struct ExploreEventView: View {
    
    let logoSize: Double = 90
    
    @StateObject private var vm: BPCreateEditEventViewModel
    
    @EnvironmentObject var eventRouter: EventTabRouter
    @EnvironmentObject var mdm: MainDataManager
    
    let event: Event
    
    init(event: Event) {
        self._vm = StateObject(wrappedValue: BPCreateEditEventViewModel(event: event))
        self.event = event
    }
    var body: some View {
        ZStack{
            MainBackground()
            VStack(alignment: .center, spacing: 5) {
                //header: time, date, teams, location
                VStack{
                    ZStack{
                        LocationSelectionView(location: vm.location, offset: logoSize,editable: false) {
                            
                        } acceptAction: { newLocation in
                            vm.location = newLocation
                        }
                        
                        
                        VStack(spacing: 5){
                            //team logos section
                            HStack(alignment: .top) {
                                //home team logo/selection action
                                LogoImageView(club: event.homeClub,
                                              logoSize: logoSize,
                                              editable: false,
                                              cancelAction: {},
                                              accessAction: { club in
                                    vm.homeClub = club
                                })
                                
                                //event date section
                                VStack(spacing: 20) {
                                    Text(
                                        (event.date ?? Date.now).formatted(
                                            date: .abbreviated, time: .omitted)
                                    )
                                    .fixedSize()
                                    .font(.subheadline)
                                    .padding(5)
                                    
                                    .background {
                                        RoundedRectangle(cornerRadius: 5).fill(
                                            .ultraThinMaterial
                                        ).overlay {
                                            RoundedRectangle(cornerRadius: 5).stroke(
                                                .white, lineWidth: 1)
                                        }
                                    }
                                    .padding(.top, 20)
                                   

                                    Text(
                                        (event.date ?? Date.now).formatted(
                                            date: .omitted,
                                            time: .shortened)
                                    )
                                    .frame(width: logoSize)
                                    .font(.title)
                                    .padding(.vertical, 5)
                                    .background {
                                        RoundedRectangle(cornerRadius: 5)
                                            .fill(.ultraThinMaterial)
                                            .overlay {
                                                RoundedRectangle(cornerRadius: 5)
                                                    .stroke(.white, lineWidth: 1)
                                            }
                                    }
                                  
                                }
                                //guest team logo/selection action
                                LogoImageView(club: event.guestClub,
                                              logoSize: logoSize,
                                              editable: false,
                                              cancelAction: {},
                                              accessAction: { club in
                                    vm.guestClub = club
                                })
                            }
                            .padding(.top)
                            Spacer()
                        }
                        .padding()
                    }
                }
                .frame(height: 300)
                
                //preview + fsc editStad / editCar  views
                HStack(spacing: 15) {
                    event.viewLocationPreview
                        .resizable()
                        .scaledToFit()
                        .onTapGesture {
                            
                        }
                    event.viewObvanPreview
                        .resizable()
                        .scaledToFit()
                        .scaleEffect(0.5)
//                        .rotationEffect(Angle(degrees: -90))
                        .onTapGesture {
                        }
                }
                .padding(.horizontal)
//                .border(.red, width: 2)
                
                Spacer()
            }
        }
        .navigationTitle("Event")
        .navigationBarTitleDisplayMode(.inline)
            
            
        }
    
}

#Preview {
    Home(
        localDataManager: DataManager(forPreview: false),
        globalDataManager: NetworkManager(),
        userId: "123"
    )
    .environmentObject(GlobalSettings())
    .environmentObject(SessionManager())
    .environmentObject(ApplicationState())
}

//#Preview {
//    ExploreEventView()
//}
