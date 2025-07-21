import SwiftUI

struct BPSoundCompactCell: View {
    
    let sound: Sound
    let action: ()->Void
    
    var body: some View {
        HStack(spacing: 0){
            Image("mic1")
                .resizable()
                .scaledToFit()
                .padding(3)
                .background {
                    Circle().fill(.white.opacity(0.4))
                }
                .padding(3)
            Divider()
                .padding(.vertical,3)
            
            VStack{
                Text(sound.viewPlaceType)
                    .font(.system(size: 14))
                    .lineLimit(1)
                    .minimumScaleFactor(0.2)
                    .padding(.horizontal,5)
                Text(sound.viewWindDefence)
                    .font(.system(size: 11))
                    .lineLimit(1)
                    .minimumScaleFactor(0.2)
                    .padding(.horizontal,5)
            }
            Spacer()
            Image(systemName: "trash")
                .resizable()
                .scaledToFit()
                .frame(width: 15)
                .padding(5)
                .frame(height: 40)
                .background {
                    Rectangle().fill(.ultraThickMaterial)
                }
                .onTapGesture {
                    action()
                }
        }
        .frame(maxWidth: .infinity)
        .frame(height: 40)
        .overlay {
            RoundedRectangle(cornerRadius: 5).stroke(.ultraThickMaterial, lineWidth: 2)
        }
        .padding(2)
    }
}
