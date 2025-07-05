import SwiftUI
import Combine

struct NotificationView: View {
    @EnvironmentObject var appState: ApplicationState
    @EnvironmentObject var router: Router

    @State var lastDate: Date = .now
    
    @State private var counter: Int = 0
    
    @State var source: [StatusViewNotification] = [
        StatusViewNotification(id: UUID(), text: "Hello user",textColor:Color.primary, cycle: .loop),
        StatusViewNotification(id: UUID(), text: "Data loaded",textColor:Color.secondary, cycle: .once),
        StatusViewNotification(id: UUID(), text: "Data Synced",textColor:Color.secondary, cycle: .once),
        StatusViewNotification(id: UUID(), text: "Message received",textColor:Color.primary, cycle: .once),
        StatusViewNotification(id: UUID(), text: "New event created",textColor:Color.green, cycle: .once),
        StatusViewNotification(id: UUID(), text: "Next event: 21.12.2025  15:00",textColor:Color.brown, cycle: .loop)
    ]
    let delay: Double = 8
    let animationDuration: Double = 0.5
    let fontSize: Double = 18.0
    
    
    @State private var offset: Double = 0
    @State private var opac: Double = 1
    @State private var xAngle: Double = 0
    
    var body: some View {
 
        Text(source[counter].text)
            .font(.system(size: fontSize))
            .foregroundStyle(source[counter].textColor)
            .lineLimit(1)
            .minimumScaleFactor(0.3)
            .offset(y: offset)
            .opacity(opac)
            .rotation3DEffect(.degrees(xAngle), axis: (x: 1, y: 0, z: 0))

            .onTapGesture {
                router.routeFromNotification(path: source[counter].route)
            }
            .frame(height: fontSize)
            .onReceive(appState.currentTime) { date in
                let elapsed = date.timeIntervalSince(lastDate).rounded()
                if elapsed >= delay {
                    lastDate = date
                    withAnimation(.easeIn(duration: animationDuration)) {
                        offset = -fontSize * 2 / 3
                        opac = 0
                        xAngle = 60
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + animationDuration){
                        offset = fontSize * 2 / 3
                        xAngle = -60
                        if counter >= source.count - 1{
                            counter = 0
                        } else {
                            counter += 1
                        }
                        withAnimation(.easeOut(duration: animationDuration)){
                            offset = 0
                            opac = 1
                            xAngle = 0
                        }
                    }

                    
                }
            }
        //source changes here
            .onReceive(appState.notificationPublisher) { note in
                if source.count > 0{
                    source.insert(note, at: 1)
                } else {
                    source.append(note)
                }
            }
        
    }
}

#if DEBUG
#Preview {
    RootView()
        .environmentObject(GlobalSettings())
        .environmentObject(SessionManager())
        .environmentObject(ApplicationState())
        .environmentObject(Router())
}
//#Preview {
//    NotificationView()
//        .environmentObject(ApplicationState())
//        .environmentObject(Router())
//}
#endif


