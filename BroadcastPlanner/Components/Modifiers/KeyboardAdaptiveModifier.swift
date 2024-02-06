//
//  KeyboardAdaptiveModifier.swift
//  BroadcastPlanner
//
//  Created by Миляев Максим on 27.01.2024.
//

import SwiftUI
import Combine

struct KeyboardAdaptive: ViewModifier {
    @State private var bottomPadding: CGFloat = 0
    
    func body(content: Content) -> some View {
        // 1.
        GeometryReader { geometry in
            content
                .padding(.bottom, self.bottomPadding)
                // 2.
                .onReceive(Publishers.keyboardHeight) { keyboardHeight in
                    // 3.
                    let keyboardTop = geometry.frame(in: .global).height - keyboardHeight
                    // 4.
                    let focusedTextInputBottom = UIResponder.currentFirstResponder?.globalFrame?.maxY ?? 0
                    // 5.
                    self.bottomPadding = max(0, focusedTextInputBottom - keyboardTop - geometry.safeAreaInsets.bottom)
            }
            // 6.
            .animation(.easeOut(duration: 0.16),value: bottomPadding)
        }
    }
}



extension View {
    func keyboardAdaptive() -> some View{
        self.modifier(KeyboardAdaptive())
    }
}
