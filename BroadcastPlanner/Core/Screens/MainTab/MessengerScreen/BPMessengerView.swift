import SwiftUI

struct BPMessengerView: View {
    let messages:[GetMessageItemView] = [
        GetMessageItemView(message: "sdsdasdassdadsadsadsadasdasdsadsadsadasdasdasdasdsadasdasdasddasda", 
                           currentUserMessage: true),
        GetMessageItemView(message: "sdsdasdassdadsadsadsadasdasdsadsadsadasdasdasdasdsadasdasdasddasdasdsadsadsadasdasdsadsdasdasdsadasdsadasdasdsadasdsadasdsadasdsadasdasdasdsadsadasdsadasdasdasdasdasdasd", 
                           currentUserMessage: false),
        GetMessageItemView(message: "sdd",
                           currentUserMessage: false),
        GetMessageItemView(message: "sdsdasdassdadsa",
                           currentUserMessage: true),
        GetMessageItemView(message: "sdsdasdassdadsadsadsadasdasdsadsadsadasdasdasdasdsadasdasdasddasdasdsadsadsadasdasdsadsdasdasdsadasdsadasdasdsadasdsadasdsadasdsadasdasdasdsadsadasdsadasdasdasdasdasdasd",
                           currentUserMessage: false),
        GetMessageItemView(message: "sdsdasdassdadsadsadsadasdasdsadsadsadasdasdasdasdsadasdasdasddasdasdsadsadsadasdasdsadsdasdasdsadasdsadasdasdsadasdsadasdsadasdsadasdasdasdsadsadasdsadasdasdasdasdasdasd",
                           currentUserMessage: true)]
    
    
    var body: some View {
        ZStack{
            MainBackground()
            VStack{
                ScrollView {
                    LazyVStack(spacing: 10 ){
                        ForEach(messages.indices, id: \.self) { ind in
                            messages[ind]
                        }
                    }
                }
                TF()
                    .background(.clear)
            }
            .transitionWithOpacity()
        }
        .navigationBarBackButtonHidden()
    }
}

#if DEBUG
//#Preview {
//    BPMessengerView()
//}
//#Preview {
//    let dm = DataManager(globalDataManager: NetworkManager())
//    let appState = ApplicationState()
//    dm.networkManager.eventProgressHandler = appState
//    return RootView()
//        .environmentObject(GlobalSettings())
//        .environmentObject(SessionManager())
//        .environmentObject(appState)
//        .environmentObject(Router())
//        .environmentObject(dm)
//        .environment(\.managedObjectContext, dm.mainContext)
//}
#endif
// MARK: - Get message
struct GetMessageItemView: View {
    
    var message:String
    var currentUserMessage:Bool
    
    var body: some View {
            VStack{
                HStack{
                    if currentUserMessage{Spacer()}
                    VStack(alignment: .trailing){
                        VStack{
                            Text(message)
                                .font(.system(size: 14))
                                .foregroundColor( Color.black)
                                .padding(.top)
                                .frame(minWidth: 50,alignment: .leading)
                        }
                        VStack{
                            Text("10:30 AM")
                                .foregroundColor(.gray)
                                .font(.system(size: 12))
                                .padding(.top,1)
                                .padding(.bottom)
                        }
                        
                    }
                    .padding(.horizontal, 10)
                    .background(.ultraThickMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .overlay{
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.black,lineWidth: currentUserMessage ? 0:2)
                    }
                    if !currentUserMessage{Spacer()}
                }
            }
            .padding(.horizontal)
            .padding(currentUserMessage ? .leading: .trailing, 75)
    }
}


// MARK: - Text Field
struct TF: View{
    
    @State var message: String = ""
    
    var body: some View{
        TextField("sfdsfsdfds", text: $message, axis: .vertical)
            .padding()
            .background {
                RoundedRectangle(cornerRadius: 8).fill(.white.opacity(0.4))
            }
            .padding(.horizontal)
    }
}
