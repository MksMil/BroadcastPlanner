import SwiftUI

struct DeepConcaveView : View  {
    let cornerRadius : Double
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: cornerRadius)
                .fill(Color.mainBackgroundColor)
            
            RoundedRectangle(cornerRadius: cornerRadius)
                .stroke(Color.darkBackgroundColor, lineWidth: 2)
                .blur(radius: 0.5)
                .offset(x: 1, y: 1)
                .mask(RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(LinearGradient(colors:[Color.darkBackgroundColor, Color.clear],
                                         startPoint: .top,
                                         endPoint: .bottom)))
            
            RoundedRectangle(cornerRadius: cornerRadius)
                .stroke(Color.darkBackgroundColor, lineWidth: 6)
                .blur(radius: 3)
                .offset(x: 3, y: 3)
                .mask(RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(LinearGradient(colors: [Color.darkBackgroundColor, Color.clear],
                                         startPoint: .top,
                                         endPoint: .bottom)))
            
            RoundedRectangle(cornerRadius: cornerRadius)
                .stroke(Color.lightBackgroundColor, lineWidth: 2)
                .blur(radius: 0.5)
                .offset(x: -1, y: -1)
                .mask(RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(LinearGradient(colors: [Color.clear, Color.lightBackgroundColor],
                                         startPoint: .top,
                                         endPoint: .bottom)))
            
            RoundedRectangle(cornerRadius: cornerRadius)
                .stroke(Color.lightBackgroundColor, lineWidth: 6)
                .blur(radius: 3)
                .offset(x: -3, y: -3)
                .mask(RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(LinearGradient(colors: [Color.clear, Color.lightBackgroundColor],
                                         startPoint: .top,
                                         endPoint: .bottom)))
        }
    }
}

#Preview {
    
        DeepConcaveView(cornerRadius: 8)
            .padding()
    
}
