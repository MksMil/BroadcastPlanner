import Combine
import SwiftUI

struct HeaderBackgroundTimelineView: View {
    let image: Image
    var body: some View {
        image
            .resizable()
        //            .aspectRatio(1.5, contentMode: .fill)
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
                        .animation(.smooth(duration: 3),
                                   value: image)
            .frame(maxWidth: .infinity)
    }
}
