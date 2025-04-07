//
//  CarUnitCellView.swift
//  BroadcastPlanner
//
//  Created by Миляев Максим on 18.09.2024.
//

import SwiftUI

struct CarUnitCellView: View {
    
    
    let position: String
    @State var image: UIImage?
    @State var firstName: String
    @State var lastName: String
    let action: ()->Void
    let infoAction: ()-> Void
    
    
    var body: some View {
        HStack{
            HStack{
                makeImage()
                    .resizable()
                    .scaledToFit()
                    .frame(width: 40, height: 40)
                    .padding(8)
                    .clipShape(Circle())
                VStack(alignment: .leading){
                    Text("\(firstName) \(lastName)")
                        .font(.title3)
                    Text(position)
                        .font(.footnote)
                        .foregroundStyle(.gray)
                    
                }
                .onTapGesture {
                    action()
                }
            }
            Spacer()
            Divider()
                .padding(.vertical,4)
            Button {
                infoAction()
            } label: {
                Image(systemName: "info")
                    .resizable()
                    .scaledToFit()
                    .padding(10)
                    .frame(width: 40,height: 40)
                    .overlay {
                    Circle().stroke(.white, lineWidth: 2)
                }
            }
            .padding(4)

        }
        .padding(4)
        .background {
            RoundedRectangle(cornerRadius: 15).fill(.white.opacity(0.4))
        }
    }
    
    func makeImage()-> Image{
        if let image {
            return Image(uiImage: image)
        } else {
            return Image(systemName: "person.circle")
        }
    }
}

//#Preview {
//    CarUnitCellView(position: "director",firstName: "name", lastName: "surname"){}
//        
//}
//#Preview {
//    let manager = EditPlanPointsManager()
//    return BPEditCarView(event: .constant(MockData.sampleEvent),
//                  editable: true)
//    .environmentObject(manager)
//    .environmentObject(GlobalSettings())
//    .environmentObject(GlobalStorage())
//}
