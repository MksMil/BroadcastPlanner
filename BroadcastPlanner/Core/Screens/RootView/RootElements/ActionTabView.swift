import SwiftUI
import Combine

struct ActionTabView: View {
    let height: Double = 60
    @EnvironmentObject var router: Router
    @EnvironmentObject var appState: ApplicationState
    @State private var unreadMessages: Int = 0
    @State private var isMessengerActive: Bool = false
    var body: some View {
        HStack(spacing: 1){
            Button{
                appState.makeMessengerActive(false)
            } label:{
                Image(systemName: "calendar")
                    .resizable()
                    .scaledToFit()
                //                        .bold()
                    .padding(height / 6)
                    .padding(.horizontal,height / 6)
                    .frame(height: height)
                    .background {
                        UnevenRoundedRectangle(topLeadingRadius: height / 4,
                                               bottomLeadingRadius: height / 4, bottomTrailingRadius: 0, topTrailingRadius: 0, style: .circular)
                        .fill(Color.white.opacity(0.3))
                    }
                    .opacity(!isMessengerActive ? 0.5:1)
            }
            .disabled(!isMessengerActive)
            
            Button{
                appState.makeMessengerActive(true)
            } label: {
                Image(systemName: "ellipsis.message")
                    .resizable()
                    .scaledToFit()
                    .padding(height / 6)
                    .padding(.horizontal,height / 6)
                    .frame(height: height)
                    .background{
                        UnevenRoundedRectangle(topLeadingRadius: 0,
                                               bottomLeadingRadius: 0,
                                               bottomTrailingRadius: height / 4, topTrailingRadius: height / 4,
                                               style: .circular)
                        .fill(Color.white.opacity(0.5))
                    }
            }
            .opacity(isMessengerActive ? 0.3:1)
            .overlay{
                if unreadMessages > 0 {
                    Circle().fill(Color.white)
                        .frame(width: height / 3, height: height / 3)
                        .overlay{
                            Circle().stroke(Color.black, lineWidth: 2)
                        }
                        .padding(-2)
                        .overlay {
                            Text(unreadMessages >= 1000 ? "1K":"\(unreadMessages)")
                                .font(.system(size: 10))
                                .minimumScaleFactor(0.3)
                                .lineLimit(1)
                                .foregroundStyle(Color.black)
                        }
                        .offset(x: height / 4, y: -height / 4)
                        .opacity(isMessengerActive ? 0.4:1)
                }
            }
            .disabled(isMessengerActive)
        }
        .padding(.horizontal)
        .frame(height: height)
        .frame(maxWidth: .infinity,alignment: .center)
        .onAppear{
            if appState.unreadMessages > 0{
                unreadMessages = appState.unreadMessages
            }
        }
        .onReceive(appState.isMessengerActivePublisher) { active in
            if isMessengerActive != active {
                withAnimation(.linear(duration: 0.1)){
                    isMessengerActive = active
                }
            }
        }
        .onReceive(appState.unreadMessagesPublisher) { count in
            if unreadMessages != count, count >= 0{
                unreadMessages = count
            }
        }
    }
}
