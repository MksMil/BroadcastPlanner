//
//  BPTagView.swift
//  BroadcastPlanner
//
//  Created by Миляев Максим on 04.04.2024.
//

import SwiftUI

//struct TagViewItem: Hashable {
//    
//    var title: String
//    var isSelected: Bool
//    
//    static func == (lhs: TagViewItem, rhs: TagViewItem) -> Bool {
//        return lhs.isSelected == rhs.isSelected
//    }
//    
//    func hash(into hasher: inout Hasher) {
//        hasher.combine(title)
//        hasher.combine(isSelected)
//    }
//}

struct BPTagView: View {
    @State var tags: [UserSpecialization]
    @State private var totalHeight = CGFloat.zero       // << variant for ScrollView/List //    = CGFloat.infinity   // << variant for VStack
    var body: some View {
        VStack {
            GeometryReader { geometry in
                self.generateContent(in: geometry)
            }
        }
        .frame(height: totalHeight)// << variant for ScrollView/List
        //.frame(maxHeight: totalHeight) // << variant for VStack
    }

    private func generateContent(in g: GeometryProxy) -> some View {
        var width = CGFloat.zero
        var height = CGFloat.zero
        return ZStack(alignment: .topLeading) {
            ForEach(tags.indices, id: \.self) { index in
                BPSpecializationCellView(
                    specialization: tags[index],
                    backColor: .gray,
                    textColor: .white,
                    added: true
                )
                    .padding([.horizontal, .vertical], 4)
                    .alignmentGuide(.leading, computeValue: { d in
                        if (abs(width - d.width) > g.size.width) {
                            width = 0
                            height -= d.height
                        }
                        let result = width
                        if tags[index].rawValue == self.tags.last!.rawValue {
                            width = 0 //last item
                        } else {
                            width -= d.width
                        }
                        return result
                    })
                    .alignmentGuide(.top, computeValue: {d in
                        let result = height
                        if tags[index].rawValue == self.tags.last!.rawValue {
                            height = 0 // last item
                        }
                        return result
                    }).onTapGesture {
//                        tags[index].added.toggle()
                    }
            }
        }.background(viewHeightReader($totalHeight))
    }

    private func viewHeightReader(_ binding: Binding<CGFloat>) -> some View {
        return GeometryReader { geometry -> Color in
            let rect = geometry.frame(in: .local)
            DispatchQueue.main.async {
                binding.wrappedValue = rect.size.height
            }
            return .clear
        }
    }
}


#Preview {
    BPTagView(tags: UserSpecialization.allCases)
}

