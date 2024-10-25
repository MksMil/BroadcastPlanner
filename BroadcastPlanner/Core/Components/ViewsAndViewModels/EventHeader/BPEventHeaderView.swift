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
    @State private var selectedTime: (Int,Int) = (1,1)
    
    @State var stadium: String = "stadium"
    @State private var address: String = "address"
    
    @State private var isPresentedLogosSheet: Bool = false
    @State private var isPresentedLocationSheet: Bool = false
    @State private var isPresentedDatePicker: Bool = false
    @State private var isPresentedTimePicker: Bool = false
    
    @State private var iSelectedHomeTeamLogo: Bool = false
    @Namespace var ns
    @Namespace var min
    
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
        
        setSelectedTimeFromEventDate()
    }
 
    var body: some View {
        VStack(spacing: 20){
             //team logos section
                
                HStack(alignment: .top){
                        
                        LogoImageView(image: Image("Dynamo"), logoSize: logoSize)
                            .onTapGesture {
                                iSelectedHomeTeamLogo = true
                                isPresentedLogosSheet = true
                            }
                            .transition(.scale)
                        
                    VStack(spacing: 40){
                            
                            Text(eventDate.formatted(date: .abbreviated, time: .omitted))
                                .fixedSize()
                                .font(.subheadline)
                                .padding(5)
                                .background {
                                    RoundedRectangle(cornerRadius: 5).fill(.ultraThinMaterial).overlay{RoundedRectangle(cornerRadius: 5).stroke(.white, lineWidth: 1)}
                                }
                                .onTapGesture {
                                    isPresentedDatePicker = true
                                }
                            
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
                        }
                        
                        LogoImageView(image: Image("Dynamo"), logoSize: logoSize)
                            .onTapGesture {
                                iSelectedHomeTeamLogo = false
                                isPresentedLogosSheet = true
                            }
                    }
                    .padding(.top, 25)
            
            //location description action
                VStack(spacing: 20) {
                    // stadium name
                    Text(stadium)
                        .font(.title2)
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
                        .padding(5)
                        .background(RoundedRectangle(cornerRadius: 5).fill(.ultraThinMaterial).overlay{RoundedRectangle(cornerRadius: 5).stroke(.white, lineWidth: 1)})
                        
                        .onTapGesture {
                            isPresentedLocationSheet = true
                        }
                }
//                .padding(.horizontal,20)
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
                ClubSheetView(
                              cancelAction: {},
                              saveAction: {},
                              selectAction: {},
                              createAction: {_ in })
                .presentationBackground(.ultraThinMaterial)
                .presentationContentInteraction(.scrolls)
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
                        Button {
                            isPresentedDatePicker = false
                        } label: {
                            Image(systemName: "xmark")
                                .resizable()
                                .scaledToFit()
                                .bold()
                                .padding()
                                .background {
                                    Circle().fill(.red.opacity(0.3))
                                        .overlay {
                                            Circle().stroke(Color.red.opacity(0.5),
                                                                                     lineWidth: 2)
                                        }
                                }
                                .frame(width: 50)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        
                        Text(newDate.formatted(date: .abbreviated, time: .omitted))
                            .fixedSize()
                            .font(.title)
                            .bold()
                            .padding(.vertical,5)
                            .padding(.horizontal,15)
                            .background {
                                RoundedRectangle(cornerRadius: 5).fill(.ultraThinMaterial)
                                    .overlay {
                                        RoundedRectangle(cornerRadius: 5).stroke(Color.black,
                                                                                 lineWidth: 1)
                                    }
                            }
                            .font(.title)
                        
                        Button{
                            event.date = newDate
                            eventDate = newDate
                            isPresentedDatePicker = false
                            
                        } label: {
                            Image(systemName: "checkmark")
                                .resizable()
                                .scaledToFit()
                                .bold()
                                .padding()
                                .background {
                                    Circle().fill(.green.opacity(0.3))
                                        .overlay {
                                            Circle().stroke(Color.green.opacity(0.5),
                                                                                     lineWidth: 2)
                                        }
                                }
                                .frame(width: 50)
                        }
                        
                        .frame(maxWidth: .infinity, alignment: .trailing)
                    }
                    .padding(.horizontal,10)
                    .padding(.top, 20)
                    .font(.title3)
                    
                    DatePicker("Match Day", selection: $newDate,
                               in: dateRange,
                               displayedComponents: [.date])
                        .datePickerStyle(.graphical)
                        
                    Spacer()
                    
                }
                .padding(.horizontal)
                .presentationDetents([.fraction(0.65)])
                .background {
                    ZStack{
                        Color.blue.opacity(0.1)
                            .ignoresSafeArea()
                        Image(systemName: "flag.pattern.checkered.2.crossed")
                            .resizable()
                            .scaledToFit()
                            .opacity(0.03)
                    }
                }
                .presentationBackground(.ultraThinMaterial)
            })
            //time picker
            .sheet(isPresented: $isPresentedTimePicker, content: {
                VStack{
                    HStack{
                        //cancell button
                        Button{
                            setSelectedTimeFromEventDate()
                            isPresentedTimePicker = false
                        } label: {
                            Image(systemName: "xmark")
                                .resizable()
                                .scaledToFit()
                                .bold()
                                .padding()
                                .background {
                                    RoundedRectangle(cornerRadius: 5).fill(.red.opacity(0.3))
                                        .overlay {
                                            RoundedRectangle(cornerRadius: 5).stroke(Color.red.opacity(0.5),
                                                                                     lineWidth: 2)
                                        }
                                }
                                .frame(width: 50)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        
                        //event date value
                        Text("\(newDate.formatted(date: .omitted, time: .shortened))")
                            .font(.title)
                            .bold()
                            .padding(.vertical,5)
                            .padding(.horizontal,15)
                            .background {
                                RoundedRectangle(cornerRadius: 5).fill(.ultraThinMaterial)
                                    .overlay {
                                        RoundedRectangle(cornerRadius: 5).stroke(Color.black,
                                                                                 lineWidth: 1)
                                    }
                            }
                            .font(.title)
                        
                        //save button
                        Button{
                            event.date = newDate
                            eventDate = newDate
                            isPresentedTimePicker = false
                        } label: {
                            Image(systemName: "checkmark")
                                .resizable()
                                .scaledToFit()
                                .bold()
                                .padding()
                                .background {
                                    RoundedRectangle(cornerRadius: 5).fill(.green.opacity(0.3))
                                        .overlay {
                                            RoundedRectangle(cornerRadius: 5).stroke(Color.green.opacity(0.5),
                                                                                     lineWidth: 2)
                                        }
                                }
                                .frame(width: 50)
                        }
                        
                        .frame(maxWidth: .infinity, alignment: .trailing)
                    }
                    .padding(.horizontal,10)
                    .padding(.top,20)
                    .foregroundStyle(.black)
                    
                   
                    
                    Text("Hours")
                        .foregroundStyle(.gray)
                    ScrollViewReader{ proxy in
                        ScrollView(.horizontal){
                            HStack{
                                ForEach(0..<24) { num in
                                    VStack{
                                        Text(String(format: "%02d", num))
                                            .font(.title2)
                                            .bold()
                                    }
                                    .id(num)
                                    
                                    .padding()
                                    .background {
                                        RoundedRectangle(cornerRadius: 5).fill(.ultraThinMaterial)
                                            .overlay {
                                                RoundedRectangle(cornerRadius: 5)
                                                    .stroke(.black.opacity(0.4), lineWidth: 1)
                                                    .matchedGeometryEffect(id: num, in: ns )
                                            }
                                    }
                                    .onTapGesture {
                                        let minutes = Calendar.current.component(.minute, from: newDate)
                                        withAnimation{
                                        selectedTime.0 = num
                                            setDateTime(newHour: num, newMin: minutes)
                                        }
                                    }
                                }
                            }
                            .overlay{
                                RoundedRectangle(cornerRadius: 5)
                                    .stroke(.blue, lineWidth: 1)
                                    .matchedGeometryEffect(id: selectedTime.0, in: ns, isSource: false)
                            }
                        }
                        .onAppear{
                            setSelectedTimeFromEventDate()
                            proxy.scrollTo(selectedTime.0,anchor: .center)
                        }
                        .scrollIndicators(.hidden)
                    }
                    
                    Text("Minutes")
                        .foregroundStyle(.gray)
                    HStack {
                        ForEach([0,15,30,45],id: \.self) { num in
                            VStack {
                                Text(String(format: "%02d", num))
                            }
                            .padding()
                            .background {
                                RoundedRectangle(cornerRadius: 5).fill(.ultraThickMaterial)
                                    .overlay {
                                        RoundedRectangle(cornerRadius: 5)
                                            .stroke(.black.opacity(0.4), lineWidth: 1)
                                            .matchedGeometryEffect(id: num, in: min)
                                    }
                            }
                            .overlay(content: {
                                RoundedRectangle(cornerRadius: 5)
                                    .stroke(.blue, lineWidth: 1)
                                    .matchedGeometryEffect(id: selectedTime.1, in: min, isSource: false)
                            })
                            .onTapGesture {
                                let hour = Calendar.current.component(.hour, from: newDate)
                                withAnimation{
                                    selectedTime.1 = num
                                    setDateTime(newHour: hour, newMin: num)
                                }
                            }
                        }
                    }
                    
                    Spacer()
                    
                }
                .padding(.horizontal)
                .presentationDetents([.fraction(0.5)])
                .background {
                    ZStack{
                        Color.blue.opacity(0.1)
                            .ignoresSafeArea()
                        Image(systemName: "flag.pattern.checkered.2.crossed")
                            .resizable()
                            .scaledToFit()
                            .opacity(0.03)
                    }
                }
                .presentationBackground(.ultraThinMaterial)
            })
            .onReceive(timer.timer) { _ in
                timerCounter += 1
                if timerCounter > 8 {
                    timerCounter = 0
                    updateBackground()
                }
            }
            
    }
    func setSelectedTimeFromEventDate(){
        var hour = Calendar.current.component(.hour, from: eventDate)
        var min = Calendar.current.component(.minute, from: eventDate)
        switch min {
            case 0...7:
                min = 0
            case 8...22:
                min = 15
            case 23...37:
                min = 30
            case 38...52:
                min = 45
            case 53... :
                min = 0
                
                hour = hour > 22 ? 0 : (hour + 1)
            default:
                min = 0
        }
        setDateTime(newHour: hour, newMin: min)
        selectedTime = (hour,min)
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
            .environmentObject(GlobalSettings())
            .environmentObject(GlobalStorage(localUser: LocalUser(context: DataManager.preview.moc), networkManager: NetworkManager()))
            .environmentObject(EventTabRouter())
            .environmentObject(GlobalTimer())
//            .environment(\.managedObjectContext, DataManager.shared.moc)
    }
}

