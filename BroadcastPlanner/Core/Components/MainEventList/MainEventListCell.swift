//import SwiftUI
//import Combine
//
//struct MainEventListCell: View {
//    @EnvironmentObject var globalTimer: GlobalTimer
//    var event: Event
//    @State private var eventDate: String = ""
//    @State private var counter: String = "counter here"
//    @State private var homeImageString: String
//    @State private var guestImageString: String
//    @State private var title: String
//    @State private var address: String
//    
//    var timeRemaining: TimeInterval {
//        max(event.date.timeIntervalSinceNow, 0)
//        }
//    
//    init(event: Event){
//        self.event = event
//        self._homeImageString = State(initialValue: event.homeImageString)
//        self._guestImageString = State(initialValue: event.guestImageString)
//        self._title = State(initialValue: event.eventLocation.title)
//        self._address = State(initialValue: event.eventLocation.address)
//        self.eventDate = getDate(date: event.date)
//    }
//    
//    private var countdownFormatter: DateComponentsFormatter {
//        let formatter = DateComponentsFormatter()
//        formatter.allowedUnits = [.day, .hour, .minute, .second]
//        formatter.unitsStyle = .positional
//        formatter.zeroFormattingBehavior = .pad
//        return formatter
//    }
//    
//    private func getDate(date: Date) -> String {
//        return BPDateFormater.format(date: date)
//    }
//    
//    private func updateCounter() {
//        if timeRemaining > 0 {
//            counter = "\(countdownFormatter.string(from: timeRemaining) ?? "Time's up!")"
//        } else {
//            counter = "Time Up!"
//        }
//    }
//    
//    private func update(){
//        homeImageString =  event.homeImageString
//        guestImageString = event.guestImageString
//        title = event.eventLocation.title
//        address = event.eventLocation.address
//       eventDate = getDate(date: event.date)
//    }
//    
//    
//    var body: some View {
//        ZStack{
//            GeometryReader { geo in
//                Rectangle().fill(.regularMaterial)
//                    .clipShape(RoundedRectangle(cornerRadius: 8))
//                    .overlay {
//                        HStack{
//                            Spacer()
//                            VStack(spacing: 0){
//                                HStack {
//                                    Text(eventDate)
//                                        .font(.system(size: 10))
//                                        .minimumScaleFactor(0.5)
//                                        .fixedSize()
//                                }
//                                .padding(.vertical,10)
//                                
//                                Text(counter)
//                                    .font(.system(size: 10))
//                                    .minimumScaleFactor(0.5)
//                                    .fixedSize()
//                                
//                                Spacer()
//                            }
//                            .frame(width: geo.frame(in: .local).size.width / 3.5)
//                            
//                            
//                            Divider()
//                                .background(.ultraThinMaterial)
//                            
//                            VStack(spacing: 0){
////                                Spacer()
//                                HStack(spacing: 2){
//                                    //home team logo
//                                    
//                                    LogoImageView(imageString: homeImageString, logoSize: geo.size.height / 2 ,isBackground: false)
//                                    Text(":")
//
//                                    
//                                    //guest team logo
//                                    LogoImageView(imageString: guestImageString, logoSize: geo.size.height / 2,isBackground: false)
//
//                                }
//                                .frame(height: geo.size.height / 2)
//
//                                VStack(spacing: 0){
//                                    Text(title)
//                                        .font(.caption2)
//                                        .lineLimit(1)
//                                        .minimumScaleFactor(0.35)
//                                    Text(address)
//                                        .font(.caption2)
//                                        .lineLimit(1)
//                                        .minimumScaleFactor(0.35)
//                                }
//                                .padding(.top,5)
//                            }
//                            
//                            .frame(width: geo.frame(in: .local).size.width / 3.5)
//                            .padding(.vertical,5)
//                            Divider()
//                                .background(.ultraThinMaterial)
//                            
//                            VStack(spacing: 5){
//                                //timer?
//                                
//                                Text("Status")
//                                
//                            }
//                            .frame(width: geo.frame(in: .local).size.width / 3.5)
//                            Spacer()
//                        }
//                        .overlay {
//                            RoundedRectangle(cornerRadius: 8)
//                                .strokeBorder(.ultraThinMaterial, lineWidth: 2)
//                        }
//                    }
//            }
//            .foregroundStyle(Color.black)
//        }
//        .onAppear{
//            update()
//        }
//        .onReceive(globalTimer.timer, perform: { _ in
//            updateCounter()
//        })
//    }
//    
//    
//}
//
//#Preview{
//    NavigationStack{
//        MainEventsList(userID: "aa")
//    }
//    .environmentObject(GlobalStorage())
//    .environmentObject(GlobalSettings())
//    .environmentObject(GlobalTimer())
//}
//
////#Preview {
////    MainEventListCell(event: MockData.sampleEvent)
////}
