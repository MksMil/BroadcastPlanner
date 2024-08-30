import SwiftUI

struct BPEventHeaderView: View {
    @EnvironmentObject var settings: GlobalSettings
    
    @EnvironmentObject var timer: GlobalTimer
    @State private var timerCounter: Int = 0
    @State private var imageIndex: Int = 0
    
    @State var newDate: Date = Date()
    
    @State private var backImage: String = "neitral"

    @Binding var event: Event
    
    @State var homeImageString: String = ""
    @State var guestImageString: String = ""
    
    @State var eventDate: Date = Date()

    @State var stadium: String = "stadium"
    @State private var city: String = "city"
    
    @State private var isPresentedLogosSheet: Bool = false
    @State private var isPresentedLocationSheet: Bool = false
    @State private var isPresentedDatePicker: Bool = false
    
    @State private var iSelectedHomeTeamLogo: Bool = false
    
    init(event: Binding<Event>) {
        self._event = Binding(projectedValue: event)
        self.homeImageString = event.homeImageString.wrappedValue
        self.guestImageString = event.guestImageString.wrappedValue
        self.eventDate = event.date.wrappedValue
        self.stadium = event.eventLocation.title.wrappedValue
        self.city = event.eventLocation.city.wrappedValue
        setBackgroundImage()
    }
 
    var body: some View {
            VStack(spacing: 15){
                //team logos section
                HStack{
                    Spacer()
                    LogoImageView(imageString: homeImageString,isBackground: true)
                        .onTapGesture {
                            iSelectedHomeTeamLogo = true
                            isPresentedLogosSheet = true
                        }
                        .transition(.scale)
                    
                    Spacer()
                    
                    LogoImageView(imageString: guestImageString,isBackground: true)
                        .onTapGesture {
                            iSelectedHomeTeamLogo = false
                            isPresentedLogosSheet = true
                        }
                    Spacer()
                }
                .padding(.horizontal)
                .padding(.top,60)
                
               
                
                Text(stadium)
                    .font(.title)
                    .fixedSize()
                    .padding(5)
                    .background(RoundedRectangle(cornerRadius: 5).fill(.ultraThinMaterial).overlay{RoundedRectangle(cornerRadius: 5).stroke(.white, lineWidth: 1)})
                    .onTapGesture {
                        isPresentedLocationSheet = true
                    }
                
                Text(city)
                    .font(.title3)
                    .fixedSize()
                    .padding(5)
                    .background(RoundedRectangle(cornerRadius: 5).fill(.ultraThinMaterial).overlay{RoundedRectangle(cornerRadius: 5).stroke(.white, lineWidth: 1)})
                    .padding(.bottom,12)
                    .onTapGesture {
                        isPresentedLocationSheet = true
                    }
                
                Text(eventDate.formatted(date: .abbreviated, time: .shortened))
                    .fixedSize()
                    .font(.subheadline)
                    .padding(5)
                    .background {
                        RoundedRectangle(cornerRadius: 5).fill(.ultraThinMaterial).overlay{RoundedRectangle(cornerRadius: 5).stroke(.white, lineWidth: 1)}
                    }
                    .onTapGesture {
                        isPresentedDatePicker = true
                    }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical,40)
            .background {
                Image(backImage)
                    .resizable()
                    .scaledToFill()
                    .animation(.easeInOut(duration: 1),
                               value: backImage)
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
                                event.eventLocation = location
                                stadium = location.title
                                setBackgroundImage()
                                isPresentedLocationSheet = false
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
                if timerCounter > 5 {
                    timerCounter = 0
                    updateBackground()
                }
            }
        }
    //circular background
    func updateBackground(){
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
    
    func setBackgroundImage(){
        if event.eventLocation.imageStrings.isEmpty{
            backImage = "neitral"
        } else {
            backImage = event.eventLocation.imageStrings[0]
        }
    }
}

//#Preview {
//    BPEventHeaderView(event: .constant(MockData.sampleEvent)
//    )
//        .environmentObject(GlobalSettings())
//        .environmentObject(GlobalTimer())
//}

#Preview {
    NavigationStack{
        BPCreateEditEventView( event: MockData.sampleEvent)
    }
        .environmentObject(GlobalSettings())
        .environmentObject(GlobalStorage())
        .environmentObject(EventTabRouter())
        .environmentObject(GlobalTimer())
}

