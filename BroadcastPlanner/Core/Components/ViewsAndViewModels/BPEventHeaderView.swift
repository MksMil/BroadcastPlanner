import SwiftUI

struct BPEventHeaderView: View {
    @EnvironmentObject var settings: GlobalSettings
    
    @EnvironmentObject var timer: GlobalTimer
    @State private var timerCounter: Int = 0
    @State private var imageIndex: Int = 0
    
    @State var newDate: Date = Date()
    
    @State private var backImage: String

    @Binding var event: Event
    
    @State var homeImageString: String = ""
    @State var guestImageString: String = ""
    
    @State var eventDate: Date = Date()

    @State var stadium: String = "stadium"
    @State private var address: String = "address"
    
    @State private var isPresentedLogosSheet: Bool = false
    @State private var isPresentedLocationSheet: Bool = false
    @State private var isPresentedDatePicker: Bool = false
    
    @State private var iSelectedHomeTeamLogo: Bool = false
    
    init(event: Binding<Event>) {
        self._event = Binding(projectedValue: event)
        self._homeImageString = State(initialValue: event.homeImageString.wrappedValue)
        self._guestImageString = State(initialValue: event.guestImageString.wrappedValue)
        self._eventDate = State(initialValue: event.date.wrappedValue)
        self._stadium = State(initialValue: event.eventLocation.title.wrappedValue)
        self._address = State(initialValue: event.eventLocation.address.wrappedValue)
        self._backImage = State(initialValue: (event.eventLocation.imageStrings.wrappedValue.isEmpty ?
                                               "neitral" : event.eventLocation.imageStrings[0].wrappedValue)
        )
    }
 
    var body: some View {
            VStack(spacing: 10){
                Text(eventDate.formatted(date: .abbreviated, time: .omitted))
                    .fixedSize()
                    .font(.subheadline)
                    .padding(5)
                    .background {
                        RoundedRectangle(cornerRadius: 5).fill(.ultraThinMaterial).overlay{RoundedRectangle(cornerRadius: 5).stroke(.white, lineWidth: 1)}
                    }
                    .offset(y:10)
                    .onTapGesture {
                        isPresentedDatePicker = true
                    }
                
                //team logos section
                HStack{
                    Spacer()
                    
                    LogoImageView(imageString: homeImageString,
                                  isBackground: true)
                        .onTapGesture {
                            iSelectedHomeTeamLogo = true
                            isPresentedLogosSheet = true
                        }
                        .transition(.scale)
                    
                    Spacer()
                    Text(eventDate.formatted(date: .omitted, time: .shortened))
                        .fixedSize()
                        .font(.title)
                        .padding(5)
                        .background {
                            RoundedRectangle(cornerRadius: 5).fill(.ultraThinMaterial).overlay{RoundedRectangle(cornerRadius: 5).stroke(.white, lineWidth: 1)}
                        }
                        .onTapGesture {
                            isPresentedDatePicker = true
                        }
                    Spacer()
                    
                    LogoImageView(imageString: guestImageString,
                                  isBackground: true)
                        .onTapGesture {
                            iSelectedHomeTeamLogo = false
                            isPresentedLogosSheet = true
                        }
                    Spacer()
                }
                .padding(.horizontal)
                
                // stadium name
                Text(stadium)
                    .font(.title3)
                    .fixedSize()
                    .padding(5)
                    .background(RoundedRectangle(cornerRadius: 5).fill(.ultraThinMaterial).overlay{RoundedRectangle(cornerRadius: 5).stroke(.white, lineWidth: 1)})
                    .onTapGesture {
                        isPresentedLocationSheet = true
                    }
                
                //address
                    Text(address)
                        .font(.footnote)
                        .lineLimit(2)
//                        .fixedSize()
                        .padding(5)
                        .background(RoundedRectangle(cornerRadius: 5).fill(.ultraThinMaterial).overlay{RoundedRectangle(cornerRadius: 5).stroke(.white, lineWidth: 1)})
                        .padding(.horizontal,20)
                        .onTapGesture {
                            isPresentedLocationSheet = true
                        }
                Spacer()
            }
            .padding(.vertical)
//            .frame(maxWidth: .infinity)
            .background {
                // TODO: change image animation problem
                Image(backImage)
                    .resizable()
                    .scaledToFill()
//                    .animation(.easeInOut(duration: 1),
//                               value: backImage)
                    .mask {Rectangle().fill(
                        LinearGradient(
                            colors: [
                                .clear,
                                .black,
                                .black,
                                .black.opacity(0.65),
                                .black.opacity(0.85),
                                .clear
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    }
            }
            // TODO: add new team and logo button and flow
            .sheet(isPresented: $isPresentedLogosSheet, content: {
                SmartLayout(hSpacing: 15, vSpacing: 15) {
                    ForEach(TeamLogos.allCases){ logo in
                        Image(logo.rawValue)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 75, height: 75)
                            .onTapGesture {
                                if iSelectedHomeTeamLogo {
                                    event.homeImageString = logo.rawValue
                                    withAnimation{
                                        homeImageString = logo.rawValue
                                    }
                                } else {
                                    event.guestImageString = logo.rawValue
                                    withAnimation{
                                        guestImageString = logo.rawValue
                                    }
                                }
                                
                                isPresentedLogosSheet = false
                            }
                    }
                }
                .padding(20)
                .presentationDetents([.fraction(0.6)])
            })
            // TODO: add new location button and flow
            .sheet(isPresented: $isPresentedLocationSheet, content: {
                ScrollView{
                    
                    ForEach(settings.eventLocations, id: \.title){ location in
                        Text(location.title)
                            .font(.title)
                            .padding(5)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .onTapGesture {
                                withAnimation{
                                    event.eventLocation = location
                                    stadium = location.title
                                    address = location.address
                                    imageIndex = 0
                                    timerCounter = 0
                                    updateBackground()
                                    isPresentedLocationSheet = false
                                }
                            }
                    }
                }
                .padding()
                .presentationDetents([.fraction(0.6)])
            })
            //date picker sheet
            .sheet(isPresented: $isPresentedDatePicker, content: {
                VStack{
                    HStack{
                        Button("Cancel") {
                            isPresentedDatePicker = false
                        }
                        .buttonStyle(.bordered)
                        .padding(.top, 20)
                        .foregroundStyle(.blue)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        
                        Button("Save") {
                            event.date = newDate
                            eventDate = newDate
                            isPresentedDatePicker = false
                            
                        }
                        .buttonStyle(.bordered)
                        .padding(.top, 20)
                        .foregroundStyle(.blue)
                        .frame(maxWidth: .infinity, alignment: .trailing)
                    }
                    DatePicker("Match Day", selection: $newDate, displayedComponents: [.date, .hourAndMinute])
                        .datePickerStyle(.graphical)
                    
                }
                .padding(.horizontal)
                .presentationDetents([.fraction(0.65)])
            })
            .onReceive(timer.timer) { _ in
                timerCounter += 1
                if timerCounter > 8 {
                    timerCounter = 0
                    updateBackground()
                }
            }
        }
    //circular background
    func updateBackground(){
        withAnimation(.linear(duration: 2)){
            if event.eventLocation.imageStrings.isEmpty{
                backImage = "neitral"
            } else {
                imageIndex += 1
                if imageIndex < event.eventLocation.imageStrings.count{
                    backImage = event.eventLocation.imageStrings[imageIndex]
                } else {
                    imageIndex = 0
                    backImage = event.eventLocation.imageStrings[imageIndex]
                }
            }
        }
    }
}

#Preview {
    BPEventHeaderView(event: .constant(MockData.sampleEvent)
    )
        .environmentObject(GlobalSettings())
        .environmentObject(GlobalTimer())
}

//#Preview {
//    NavigationStack{
//        BPCreateEditEventView( event: MockData.sampleEvent)
//    }
//        .environmentObject(GlobalSettings())
//        .environmentObject(GlobalStorage())
//        .environmentObject(EventTabRouter())
//        .environmentObject(GlobalTimer())
//}

