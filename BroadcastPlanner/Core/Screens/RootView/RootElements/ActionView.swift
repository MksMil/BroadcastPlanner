import SwiftUI

struct ActionView: View {
    
    var body: some View {
        ZStack{
            HStack{
                SecondaryActionButton()
                Spacer()
                PimaryActionButton()
            }
            ActionTabView()
        }
    }
    
}
