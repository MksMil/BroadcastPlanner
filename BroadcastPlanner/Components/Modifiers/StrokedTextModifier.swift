//
//  StrokedTextModifier.swift
//  BroadcastPlanner
//
//  Created by Миляев Максим on 19.04.2024.
//

import SwiftUI

struct StrokedTextModifier: ViewModifier{
    private let id = UUID()
    var textColor: Color
    var strokeWidth: Double
    
    
    func body(content: Content) -> some View {
        content
            .background {
                Rectangle()
                    .fill(textColor)
                    .mask {
                        Canvas {context, size in
                            if let text = context.resolveSymbol(id:id){
                                context.addFilter(.alphaThreshold(min: 0.01))
                                context.draw(text,
                                             at: .init(x: size.width / 2,
                                                       y: size.height / 2))
                            }
                        }symbols: {
                            content.tag(id)
                                .blur(radius: strokeWidth)
                        }
                        
                    }
            }
    }
}

extension View{
    func strokedText(color: Color, width: Double) -> some View{
        self.modifier(StrokedTextModifier(textColor: color,strokeWidth: width))
    }
}
