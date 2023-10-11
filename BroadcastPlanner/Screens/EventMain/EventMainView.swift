//
//  ContentView.swift
//  BroadcastPlanner
//
//  Created by Миляев Максим on 28.09.2023.
//

import SwiftUI

struct EventMainView: View {
    var body: some View {
        VStack {
            EventInfoView(event: MockData.sampleEvent)
            StadiumView(cameras: Camera.smapleCameras)
                .frame(height: 250)
            Spacer()
            
        }
        .padding()
    }
}

#Preview {
    EventMainView()
}
