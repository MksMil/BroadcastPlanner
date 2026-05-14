import SwiftUI

struct BPErrorView: View {
    
    // first value : error text description
    // second value: sf symbol image name
    @State var errorDescription: (String, String)
    
    //animation parameters
    @State private var animatedOpacity: Double = 1
    
    var body: some View {
                    VStack{
                        // MARK: - Error Image
                        Image(systemName: errorDescription.1)
                            .resizable()
                            .scaledToFit()
                            .frame(maxWidth: .infinity)
                            .frame(height: 100)
                            .padding()
                            .border(.white, width: 3)
                            .opacity(animatedOpacity)
                            .onAppear(perform: {
                                Task{
                                    withAnimation(.linear(duration: 1).repeatForever(autoreverses: true)) {
                                        animatedOpacity = 0.25
                                    }
                                }
                            })
                        // TODO: vertical error text
                        // MARK: - Error Description
                        if !errorDescription.0.isEmpty{
                            Text(errorDescription.0)
                                .fixedSize()
                                .font(.title3)
                                .fontWeight(.medium)
                                .multilineTextAlignment(.center)
                        }
                        
                    }
                    .foregroundColor(.white).opacity(0.8)
                    .padding(30)
                    .background{
                        RoundedRectangle(cornerRadius: 25.0)
                            .foregroundColor(.black)
                            .opacity(0.75)
                    }
                    .padding(.horizontal,80)
    }
}

#Preview {
    BPErrorView(errorDescription: ("Error with very big descriptionError with very big descriptionError with very big descriptionError with very big descriptionError with very big descriptionError with very big description", "wifi.exclamationmark"))
}
