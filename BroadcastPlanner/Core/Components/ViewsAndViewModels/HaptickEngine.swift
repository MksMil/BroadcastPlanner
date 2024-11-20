
import SwiftUI
import CoreHaptics

struct HaptickEngine: View {
    
    // Create a @State property to track whether the button was pressed
    @State private var isPressed:Bool = false
    
    var body: some View {
        
        Button {
            isPressed = true
            triggerHapticFeedback()
            
        } label: {
            
            Text("Press me")
                .padding()
                .frame(maxWidth: .infinity,alignment: .center)
                .foregroundColor(.white)
                .background(Color.blue.gradient)
                .cornerRadius(15)
                .padding(.horizontal)
                
                
        }
        // handle the buttonPressed state change in the onChange modifier to reset the state after the button is pressed
        .onChange(of: isPressed) { newValue in
            if newValue {
                isPressed = false
            }
        }
   }
    
    // MARK: triggerHapticFeedback
    /// Triggers haptics
    private func triggerHapticFeedback() {
        guard let hapticEngine = try? CHHapticEngine() else { return }
        
        do {
            try hapticEngine.start()
            
            let intensity = CHHapticEventParameter(parameterID: .hapticIntensity, value: 1)
            let sharpness = CHHapticEventParameter(parameterID: .hapticSharpness, value: 1)
            
            let event = CHHapticEvent(eventType: .hapticTransient, parameters: [intensity, sharpness], relativeTime: 0)
            let pattern = try CHHapticPattern(events: [event], parameters: [])
            
            let player = try hapticEngine.makePlayer(with: pattern)
            try player.start(atTime: 0)
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                 hapticEngine.stop()
            }
        } catch {
            print("Failed to play haptic feedback: \(error)")
        }
    }
}

struct HaptickEngine_Preview:PreviewProvider {
    static var previews: some View {
        HaptickEngine()
    }
}
