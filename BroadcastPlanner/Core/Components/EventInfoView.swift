import SwiftUI

struct EventInfoView: View {
    
    var event: Event
    
    var body: some View {
        HStack{
            Text(event.date.formatted(date: .abbreviated,
                                      time: .shortened))
        }
    }
}

#Preview {
    EventInfoView(event: MockData.sampleEvent)
}
