//
//  View+Ext.swift
//  BroadcastPlanner
//
//  Created by Миляев Максим on 23.09.2024.
//

import SwiftUI

extension View{
    
    @ViewBuilder func fullWidth(_ alignment: Alignment = .center) -> some View{
        self.frame(maxWidth: .infinity, alignment: alignment)
    }
    
    @ViewBuilder func fullHeight(_ alignment: Alignment = .center) -> some View{
        self.frame(maxHeight: .infinity, alignment: alignment)
    }
    
}
