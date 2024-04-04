//
//  BPSpecializationCellView.swift
//  BroadcastPlanner
//
//  Created by Миляев Максим on 04.04.2024.
//

import SwiftUI

struct BPSpecializationCellView: View {
    
    var specialization: UserSpecialization = .director
    var backColor: Color = .gray
    var textColor: Color = .white
    @State var added: Bool = true
    
    var body: some View {
        ZStack{
            Text("\(specialization.rawValue)")
                .font(.callout).bold()
                .foregroundStyle(textColor)
                .fixedSize()
                .padding(5)
                .background {
                    RoundedRectangle(cornerRadius: 5).fill(backColor)
                }
        }
    }
}

#Preview {
    BPSpecializationCellView()
        .frame(width: 200, height: 50)

}
