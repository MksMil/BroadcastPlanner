import SwiftUI
import UIKit

struct BPEventHeaderView: View {
    @EnvironmentObject var settings: GlobalSettings
    @EnvironmentObject var timer: GlobalTimer
    
    let logoSize: Double = 100
    let event: LocalEvent
    
    @State var homeClub: LocalClub?
    @State var guestClub: LocalClub?
    
    @State private var timerCounter: Int = 0
    @State private var imageIndex: Int = 0
    @State private var backImage: Image?
    
    @State var newDate: Date = Date()
    @State var eventDate: Date = Date()

    @State var stadium: String = "stadium"
    @State private var address: String = "address"
    
    @State private var isPresentedLogosSheet: Bool = false
    @State private var isPresentedLocationSheet: Bool = false
    @State private var isPresentedDatePicker: Bool = false
    @State private var isPresentedTimePicker: Bool = false
    
    @State private var iSelectedHomeTeamLogo: Bool = false
    
    let dateRange: PartialRangeFrom<Date> = {
        let calendar = Calendar.current
        let startComponents = calendar.dateComponents([.year,.month,.day], from: .now)
        return calendar.date(from:startComponents)!...
    }()
    
    init(event: LocalEvent) {
        self.event = event
        self._homeClub = State(initialValue: event.homeClub)
        self._guestClub = State(initialValue: event.guestClub)
        self._eventDate = State(initialValue: event.viewRemainingDate)
//        self._stadium = State(initialValue: event.eventLocation.title.wrappedValue)
//        self._address = State(initialValue: event.eventLocation.address.wrappedValue)
        
        
    }
 
    var body: some View {
            VStack{
                Text(eventDate.formatted(date: .abbreviated, time: .omitted))
                    .fixedSize()
                    .font(.subheadline)
                    .padding(5)
                    .background {
                        RoundedRectangle(cornerRadius: 5).fill(.ultraThinMaterial).overlay{RoundedRectangle(cornerRadius: 5).stroke(.white, lineWidth: 1)}
                    }
                    .offset(y: 20)
                    .onTapGesture {
                        isPresentedDatePicker = true
                    }
                
                //team logos section
                
                    HStack{
                        
                        LogoImageView(image: Image("Dynamo"), logoSize: logoSize)
                            .onTapGesture {
                                iSelectedHomeTeamLogo = true
                                isPresentedLogosSheet = true
                            }
                            .transition(.scale)
                        
                        Text(eventDate.formatted(date: .omitted, time: .shortened))
                            .frame(width: logoSize)
                            .font(.title)
                            .padding(.vertical,5)
                            .background {
                                RoundedRectangle(cornerRadius: 5).fill(.ultraThinMaterial).overlay{RoundedRectangle(cornerRadius: 5).stroke(.white, lineWidth: 1)}
                            }
                            .onTapGesture {
                                isPresentedTimePicker = true
                            }
                        
                        LogoImageView(image: Image("Dynamo"), logoSize: logoSize)
                            .onTapGesture {
                                iSelectedHomeTeamLogo = false
                                isPresentedLogosSheet = true
                            }
                    }
                VStack {
                    // stadium name
                    Text(stadium)
                        .font(.title2)
//                        .fixedSize()

                        .lineLimit(2)
                        .padding(5)
                        .background(RoundedRectangle(cornerRadius: 5).fill(.ultraThinMaterial).overlay{RoundedRectangle(cornerRadius: 5).stroke(.white, lineWidth: 1)})
                        .onTapGesture {
                            isPresentedLocationSheet = true
                        }
                    
                    //address
                    Text(address)
                        .font(.footnote)
                        .lineLimit(2)
//                                            .fixedSize()
                        .padding(5)
                        .background(RoundedRectangle(cornerRadius: 5).fill(.ultraThinMaterial).overlay{RoundedRectangle(cornerRadius: 5).stroke(.white, lineWidth: 1)})
                        
                        .onTapGesture {
                            isPresentedLocationSheet = true
                        }
                }
                .padding(.horizontal,20)
                Spacer()
            }

            .background {
                // TODO: change image animation problem
                Image("neitral")
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
//                                if iSelectedHomeTeamLogo {
//                                    event.homeImageString = logo.rawValue
//                                    withAnimation{
//                                        homeImageString = logo.rawValue
//                                    }
//                                } else {
//                                    event.guestImageString = logo.rawValue
//                                    withAnimation{
//                                        guestImageString = logo.rawValue
//                                    }
//                                }
                                
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
                    
//                    ForEach(settings.eventLocations, id: \.title){ location in
//                        Text(location.title)
//                            .font(.title)
//                            .padding(5)
//                            .frame(maxWidth: .infinity, alignment: .leading)
//                            .onTapGesture {
//                                withAnimation{
//                                    event.eventLocation = location
//                                    stadium = location.title
//                                    address = location.address
//                                    imageIndex = 0
//                                    timerCounter = 0
//                                    updateBackground()
//                                    isPresentedLocationSheet = false
//                                }
//                            }
//                    }
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
                    DatePicker("Match Day", selection: $newDate,
                               in: dateRange,
                               displayedComponents: [.date])
                        .datePickerStyle(.graphical)
                        
                    Spacer()
                    
                }
                .padding(.horizontal)
                .presentationDetents([.fraction(0.65)])
            })
        //time picker
            .sheet(isPresented: $isPresentedTimePicker, content: {
                VStack{
                    HStack{
                        Button("Cancel") {
                            isPresentedTimePicker = false
                        }
                        .buttonStyle(.bordered)
                        .padding(.top, 20)
                        .foregroundStyle(.blue)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        
                        Button("Save") {
                            event.date = newDate
                            eventDate = newDate
                            isPresentedTimePicker = false
                            
                        }
                        .buttonStyle(.bordered)
                        .padding(.top, 20)
                        .foregroundStyle(.blue)
                        .frame(maxWidth: .infinity, alignment: .trailing)
                    }
                    .font(.title3)
                  
                    DatePicker("Start", selection: $newDate,
                               in: dateRange,
                               displayedComponents: [.hourAndMinute])
                    .datePickerStyle(.automatic)
                    .font(.title)
                    ScrollView(.horizontal){
                        HStack{
                            ForEach(0..<24) { num in
                                VStack{
                                    Text(num < 10 ? "0\(num)" :"\(num)")
                                    Text("00")
                                }
                                .padding()
                                .background {
                                    RoundedRectangle(cornerRadius: 5).fill(.gray)
                                }
                                .onTapGesture {
                                    setDateTime(newHour: num, newMin: 0)
                                }
                            }
                        }
                    }
                    .scrollIndicators(.hidden)

                    
//                    HStack{
//                        for num in stride(from: 0, to: 45, by: 15) {
//                            VStack{
//                                Text(num < 10 ? "0\(num)" :"\(num)")
//                                Text("00")
//                            }
//                            .padding()
//                            .background {
//                                RoundedRectangle(cornerRadius: 5).fill(.gray)
//                            }
//                            .onTapGesture {
//                                setDateTime(newHour: 0, newMin: num)
//                            }
//                        }
//                    }
                    Spacer()
                    
                }
                .padding(.horizontal)
                .presentationDetents([.fraction(0.35)])
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
//        withAnimation(.linear(duration: 2)){
//            if event.eventLocation.imageStrings.isEmpty{
//                backImage = "neitral"
//            } else {
//                imageIndex += 1
//                if imageIndex < event.eventLocation.imageStrings.count{
//                    backImage = event.eventLocation.imageStrings[imageIndex]
//                } else {
//                    imageIndex = 0
//                    backImage = event.eventLocation.imageStrings[imageIndex]
//                }
//            }
//        }
    }
    
    func setDateTime(newHour: Int, newMin: Int){

        if let newDate = Calendar.current.date(bySettingHour: newHour,minute: newMin, second: 0,of:eventDate){
            self.newDate = newDate
        }
    }
}

//#Preview {
//    BPEventHeaderView(event: LocalEvent(context: DataManager.preview.moc)
//    )
//    .environmentObject(GlobalSettings())
//    .environmentObject(GlobalStorage(localUser: LocalUser(context: DataManager.preview.moc), networkManager: NetworkManager()))
//    .environmentObject(EventTabRouter())
//    .environmentObject(GlobalTimer())
//}

#Preview {
    NavigationStack{
        BPCreateEditEventView(event: LocalEvent(context: DataManager.preview.moc))
    }
        .environmentObject(GlobalSettings())
        .environmentObject(GlobalStorage(localUser: LocalUser(context: DataManager.preview.moc), networkManager: NetworkManager()))
        .environmentObject(EventTabRouter())
        .environmentObject(GlobalTimer())
}

