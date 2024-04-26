//
//  View+Ext.swift
//  ViewsSamples
//
//  Created by Миляев Максим on 19.04.2024.
//

import SwiftUI


@available(iOS 15.0, *)
public extension View{
    func concaveWith(color: Color, cornerRadius: Double) -> some View{
        self.modifier(Concaved(cornerRadius: cornerRadius, mainColor: color))
    }
    
    func convex(color: Color, cornerRad: Double)-> some View{
        self.modifier(Convexed(cornerRadius: cornerRad,mainColor: color))
    }
    
    func concavable(cornerRadius: Double, color: Color, isSelected: Bool) -> some View{
        self.modifier(Concavable(cornerRadius: cornerRadius, mainColor: color, isSelected: isSelected))
    }
}
