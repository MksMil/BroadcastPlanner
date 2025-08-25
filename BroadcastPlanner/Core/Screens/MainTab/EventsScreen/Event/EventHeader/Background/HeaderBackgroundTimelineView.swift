import Combine
import SwiftUI

struct HeaderBackgroundTimelineView: View {
    let id: String
    var body: some View {
        ImageWrapper(id: id, type: .venue,imageSize: .largeImages)
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
                                           value: id)
//            .frame(maxWidth: .infinity)
    }
}
