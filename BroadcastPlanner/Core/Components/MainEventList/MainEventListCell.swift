import SwiftUI
import Combine

struct MainEventListCell: View {
    @EnvironmentObject var globalTimer: GlobalTimer
    var event: LocalEvent
    @State private var eventDate: String = ""
    @State private var counter: String = "counter here"
    @State private var homeClub: LocalClub?
    @State private var guestClub: LocalClub?
    @State private var title: String
    @State private var address: String
    
    var timeRemaining: TimeInterval {
        max(event.viewRemainingDate.timeIntervalSinceNow, 0)
        }
    
    init(event: LocalEvent){
        self.event = event
        self._homeClub = State(initialValue: event.homeClub)
        self._guestClub = State(initialValue: event.guestClub)
        self._title = State(initialValue: event.viewTitle)
        self._address = State(initialValue: event.viewAddress)
        self.eventDate = getDate(date: event.viewRemainingDate)
    }
    
    private var countdownFormatter: DateComponentsFormatter {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.day, .hour, .minute, .second]
        formatter.unitsStyle = .positional
        formatter.zeroFormattingBehavior = .pad
        return formatter
    }
    
    private func getDate(date: Date) -> String {
        return BPDateFormater.format(date: date)
    }
    
    private func updateCounter() {
        if timeRemaining > 0 {
            counter = "\(countdownFormatter.string(from: timeRemaining) ?? "Time's up!")"
        } else {
            counter = "Time Up!"
        }
    }
    
    private func update(){
        homeClub =  event.homeClub
        guestClub = event.guestClub
        title = event.viewTitle
        address = event.viewAddress
        eventDate = getDate(date: event.viewRemainingDate)
    }
    
    
    var body: some View {
        ZStack{
            GeometryReader { geo in
                Rectangle().fill(.regularMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                    .overlay {
                        HStack{
                            Spacer()
                            VStack(spacing: 0){
                                HStack {
                                    Text(eventDate)
                                        .font(.system(size: 10))
                                        .minimumScaleFactor(0.5)
                                        .fixedSize()
                                }
                                .padding(.vertical,10)
                                
                                Text(counter)
                                    .font(.system(size: 10))
                                    .minimumScaleFactor(0.5)
                                    .fixedSize()
                                
                                Spacer()
                            }
                            .frame(width: geo.frame(in: .local).size.width / 3.5)
                            
                            
                            Divider()
                                .background(.ultraThinMaterial)
                            
                            VStack(spacing: 0){
//                                Spacer()
                                HStack{
                                    //home team logo
                                    
                                    LogoImageView(image:event.homeImage,
                                                  logoSize: geo.size.height / 2)
                                    
                                    Text(":")
                                    
                                    //guest team logo
                                    LogoImageView(image: event.guestImage,
                                                  logoSize: geo.size.height / 2)

                                }
                                .frame(height: geo.size.height / 2)

                                VStack{
                                    Text(title)
                                        .font(.caption2)
                                        .lineLimit(1)
                                        .minimumScaleFactor(0.35)
                                    Text(address)
                                        .font(.caption2)
                                        .lineLimit(1)
                                        .minimumScaleFactor(0.35)
                                }
                                .padding(.top,5)
                            }
                            
                            .frame(width: geo.frame(in: .local).size.width / 3.5)
                            .padding(.vertical,5)
                            
                            Divider()
                                .background(.ultraThinMaterial)
                            
                            VStack(spacing: 5){
                                //timer?
                                
                                Text("Status")
                                
                            }
                            .frame(width: geo.frame(in: .local).size.width / 3.5)
                            Spacer()
                        }
                        .overlay {
                            RoundedRectangle(cornerRadius: 8)
                                .strokeBorder(.ultraThinMaterial, lineWidth: 2)
                        }
                    }
            }
            .foregroundStyle(Color.black)
        }
        .onAppear{
            update()
        }
        .onReceive(globalTimer.timer, perform: { _ in
            updateCounter()
        })
    }
    
    
}

#Preview{
    let moc = DataManager.preview.moc
    let user = LocalUser(context: moc)
    
    return NavigationStack{
        MainEventsList()
    }
    .environmentObject(GlobalStorage(localUser: user,
                                     networkManager: NetworkManager()))
    .environmentObject(GlobalSettings())
    .environmentObject(GlobalTimer())
//    .environment(\.managedObjectContext, moc)
}

//#Preview {
//    MainEventListCell(event: LocalEvent(context: DataManager.preview.moc))
//        .environmentObject(GlobalTimer())
//}
