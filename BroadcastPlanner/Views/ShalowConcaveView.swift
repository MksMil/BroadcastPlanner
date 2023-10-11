import SwiftUI

struct ShalowConcaveView: View {
    let cornerRadius: Double
    let linewidth: Double
    var body: some View {

            ZStack {
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(Color.mainBackgroundColor)
                
                RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(Color.darkBackgroundColor, lineWidth: linewidth)
                    .blur(radius: 0.5)
                    .offset(x: 1,y: 0.5)
                    .mask{
                        RoundedRectangle(cornerRadius: cornerRadius)
                            .fill(LinearGradient(colors: [Color.darkBackgroundColor,Color.clear],
                                                 startPoint: .top,
                                                 endPoint: .bottom))
                    }
                RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(Color.lightBackgroundColor, lineWidth: linewidth)
                    .blur(radius: 0.5)
                    .offset(x: -1,y: -1.5)
                    .mask{
                        RoundedRectangle(cornerRadius: cornerRadius)
                            .fill(LinearGradient(colors: [Color.clear,Color.lightBackgroundColor],
                                                 startPoint: .top,
                                                 endPoint: .bottom))
                    }
                
                
            }        
    }
}


#Preview {
    ShalowConcaveView(cornerRadius: 20, linewidth: 5)
}
