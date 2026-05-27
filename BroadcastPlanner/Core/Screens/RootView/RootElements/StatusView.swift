import Combine
import SwiftUI

struct StatusView: View {
  @EnvironmentObject var router: Router
  @EnvironmentObject var dataManager: DataManager
  @EnvironmentObject var appState: ApplicationState
  @EnvironmentObject var sessionManager: SessionManager

  var body: some View {
    ZStack {
      MainBackground()

      HStack {
        BackwardButton(
          statePublisher: router.$canMoveBack.eraseToAnyPublisher()
        ) {
          appState.backAction()
        }
        .frame(width: 50, height: 50)
        Spacer()
        /// element with app's status / errors / notifications etc.
        VStack(spacing: 0) {
          //status view title here
          TitleView(
            titlePublisher: appState
              .titlePublisher
              .eraseToAnyPublisher()
          )
          NotificationView()
        }
        .frame(height: 50)
        ///
        Spacer()
        Menu {
          //Owner Info
          Button {
            router.showUserInfo()
          } label: {
            Label("Info", systemImage: "person")
          }

          //Settings
          Button {
            router.showSettings()
          } label: {
            Label("Settings", systemImage: "gear")
          }

          //LogOut
          Button {
            Task {
              appState.userOnlineStatus = .offline
              sessionManager.logOut()
            }

          } label: {
            Label("Log out", systemImage: "rectangle.portrait.and.arrow.right")
          }

        } label: {
          ImageWrapper(
            id: dataManager.currentId,
            type: .member,
            imageSize: ImageSizes.smallImages,
            placeHolder: "person.circle"
          )
          .aspectRatio(contentMode: .fill)
          .frame(width: 50, height: 50)
          .clipShape(Circle())
          .overlay {
            Circle().stroke(Color.white, lineWidth: 2)
          }
        }
        .compositingGroup()
      }
      .padding(.horizontal)
    }
    .frame(height: 60)

  }

}
