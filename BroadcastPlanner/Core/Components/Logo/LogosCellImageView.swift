//
//  LogosCellImageView.swift
//  BroadcastPlanner
//
//  Created by Миляев Максим on 13.12.2024.
//

import SwiftUI

struct LogosCellImageView: View {
    
    let homeImage: Image
    let guestImage: Image
    let size : Double
    
    var body: some View {
        HStack{
            //home team logo
            homeImage
                .resizable()
                .scaledToFit()
                .frame(width: size, height: size)
                .padding(size / 10)
                .clipShape(Circle())
                .background{
                    Circle().fill( .ultraThinMaterial.opacity(0.9))
                }
                .overlay {
                    Circle().stroke(Color.white, lineWidth: 3)
                }
                
            
            guestImage
                .resizable()
                .scaledToFit()
                .frame(width: size, height: size)
                .padding(size / 10)
                .clipShape(Circle())
                .background{
                    Circle().fill( .ultraThinMaterial.opacity(0.9))
                }
                .overlay {
                    Circle().stroke(Color.white, lineWidth: 3)
                }

        }
    }
}

#Preview {
    LogosCellImageView(homeImage: Image(systemName: "plus"), guestImage: Image(systemName: "plus"),size: 100)
}
