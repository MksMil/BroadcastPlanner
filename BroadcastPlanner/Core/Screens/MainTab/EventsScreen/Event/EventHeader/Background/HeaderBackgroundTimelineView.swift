import Combine
import SwiftUI

struct HeaderBackgroundTimelineView: View {
    @StateObject var vm: HeaderBackgroundTimelineViewModel
    init(images: [Image] = []) {
        self._vm = StateObject(
            wrappedValue: HeaderBackgroundTimelineViewModel(
                images: images))
    }

    var body: some View {
        vm.image
            .resizable()
            .aspectRatio(1.5, contentMode: .fill)
            .mask {
                Rectangle().fill(
                    LinearGradient(
                        colors: [
                            .clear,
                            .black,
                            .black,
                            .black.opacity(0.65),
                            .black.opacity(0.85),
                            .clear,
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
            }
            .animation(.smooth(duration: 2),
                       value: vm.counter)
            .frame(maxWidth: .infinity)
            .onDisappear{ vm.stop() }
            .onReceive(DataManager.shared.updatePublisher) {
                if $0.0 == .images {
                    vm.updateImages()
                }
            }
    }
}

#Preview {
    HeaderBackgroundTimelineView(images: [])
}
