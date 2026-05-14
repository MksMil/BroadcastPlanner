import SwiftUI

struct PointDescriptionCell: View {
  
  let emptyPlaceholder: String = "-"
  
  let image: UIImage?
  let firstName: String
  let lastName: String
  
  let number: Int?
  let camera: String?
  let sound: String?
  let light: String?
  
  let unitDescription: String
  
  
    var body: some View {
      ZStack{
        
        
        VStack(alignment: .leading,spacing: 0){
          //num + description
          HStack(spacing: 0){
            Image(systemName: numberText)
              .font(.title2)
            VStack(alignment: .leading, spacing: 1) {
              Text(firstName)
              Text(lastName)
            }
            .padding(.leading,3)
            .lineLimit(1)
            .minimumScaleFactor(0.3)
            .font(.caption2)
            Spacer()
          }
          .padding(3)
          .background{Color.white.opacity(0.3)}
          
//            .border(.red, width: 1)
          //        .frame(height: 40)
          //image
//          HStack{
//            Spacer()
//
//            Spacer()
          
//          }
          if let image {
            Image(uiImage: image)
              .resizable()
              .scaledToFit()
          } else {
            Image(systemName: "person.circle")
              .resizable()
              .scaledToFit()
          }
//          .border(.blue, width: 1)
          
          //name
          VStack(alignment: .leading,spacing: 2){
            HStack(spacing: 0){
              Image(systemName: "video.circle")
              Text(":\(camText)")
              Spacer()
            }
            HStack(spacing: 0){
              Image(systemName: "mic.fill")
              Text(":\(soundText)")
              Spacer()
            }
            HStack(spacing: 0){
              Image(systemName: "lightbulb.circle.fill")
              Text(":\(lightText)")
              Spacer()
            }
          }
          .font(.caption2)
          .padding(.horizontal,3)
          .background(content: {
            Color.white.opacity(0.3)
          })
//          .border(.green, width: 1)
          //        .frame(height: 40)
        }
      }
      .frame(maxWidth: .infinity)
      .padding(.bottom,9)
      .border(.orange, width: 1)
    }
  var numberText: String {
    guard let number else { return "questionmark.circle"}
    return "\(number).circle"
  }
  
  var camText: String { camera ?? emptyPlaceholder }
  var soundText: String { sound ?? emptyPlaceholder }
  var lightText: String { light ?? emptyPlaceholder }

}

#Preview {
  ZStack{
    MainBackground()
    VStack{
      PointDescriptionCell(image: nil, firstName: "Aleksandr",lastName: "Skripnichenko",number: 1, camera: "x40", sound: "dog", light: nil, unitDescription: "main cam")
        .frame(width: 100,height: 100)
      PointDescriptionCell(image: nil, firstName: "Aleksandr",lastName: "Skripnichenko",number: 1, camera: "x40", sound: "dog", light: nil, unitDescription: "main cam")
        .frame(width: 100,height: 200)
    }
  }
}

//struct PointDescriptionCell: View {
//    
//    let emptyPlaceholder: String = "-"
//    
//    let image: UIImage?
//    let firstName: String
//    let lastName: String
//    
//    let number: Int?
//    let camera: String?
//    let sound: String?
//    let light: String?
//    
//    let unitDescription: String
//    
//    var body: some View {
//        GeometryReader { geo in
//            ZStack(alignment: .bottom) {
//                // Image — занимает всю ячейку
//                Group {
//                    if let image {
//                        Image(uiImage: image)
//                            .resizable()
//                            .scaledToFill()
//                            .frame(width: geo.size.width, height: geo.size.height)
//                            .clipped()
//                    } else {
//                        Image(systemName: "person.circle")
//                            .resizable()
//                            .scaledToFit()
//                            .frame(width: geo.size.width, height: geo.size.height)
//                            .foregroundStyle(.secondary)
//                    }
//                }
//                
//                VStack(alignment: .leading, spacing: 0) {
//                    // Верхний блок — номер + имя
//                    HStack(spacing: 0) {
//                        Image(systemName: numberText)
//                            .font(.title2)
//                        VStack(alignment: .leading, spacing: 1) {
//                            Text(firstName)
//                            Text(lastName)
//                        }
//                        .padding(.leading, 3)
//                        .lineLimit(1)
//                        .minimumScaleFactor(0.3)
//                        .font(.caption2)
//                        Spacer()
//                    }
//                    .padding(3)
//                    .background(.ultraThinMaterial)
//                    
//                    Spacer()
//                    
//                    // Нижний блок — оборудование
//                    VStack(alignment: .leading, spacing: 2) {
//                        HStack(spacing: 0) {
//                            Image(systemName: "video.circle")
//                            Text(":\(camText)")
//                            Spacer()
//                        }
//                        HStack(spacing: 0) {
//                            Image(systemName: "mic.fill")
//                            Text(":\(soundText)")
//                            Spacer()
//                        }
//                        HStack(spacing: 0) {
//                            Image(systemName: "lightbulb.circle.fill")
//                            Text(":\(lightText)")
//                            Spacer()
//                        }
//                      Spacer()
//                        .frame(height: 9)
//                    }
//                    .font(.caption2)
//                    .padding(.horizontal, 3)
//                    .padding(.vertical, 4)
//                    .background(.ultraThinMaterial)
//                }
//            }
//        }
//        .frame(maxWidth: .infinity)
//        .clipShape(RoundedRectangle(cornerRadius: 10))
//    }
//    
//    var numberText: String {
//        guard let number else { return "questionmark.circle" }
//        return "\(number).circle"
//    }
//    var camText: String { camera ?? emptyPlaceholder }
//    var soundText: String { sound ?? emptyPlaceholder }
//    var lightText: String { light ?? emptyPlaceholder }
//}
//
//#Preview {
//    PointDescriptionCell(
//        image: nil,
//        firstName: "Иван",
//        lastName: "Петров",
//        number: 3,
//        camera: "Sony FX6",
//        sound: "Sennheiser",
//        light: nil,
//        unitDescription: ""
//    )
//    .frame(width: 160, height: 220)
//    .padding()
//}
