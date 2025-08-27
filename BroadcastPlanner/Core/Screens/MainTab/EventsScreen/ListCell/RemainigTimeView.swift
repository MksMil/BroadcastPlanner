import SwiftUI

struct RemainigTimeView: View {
    @EnvironmentObject var appState: ApplicationState
    let time: Date
    @State private var text: String
    
    init(time: Date) {
        self.time = time
        self.text = BPDateFormater.timeInterval(to: time,
                                                currentTime: .now,
                                                expiredString: "finished")
    }
    
    var body: some View {
        Text(text)
            .font(.footnote)
            .onReceive(appState.currentTime) { currentTime in
                text = BPDateFormater.timeInterval(to: time,
                                                   currentTime: currentTime,
                expiredString: "finished")
            }
    }
}
