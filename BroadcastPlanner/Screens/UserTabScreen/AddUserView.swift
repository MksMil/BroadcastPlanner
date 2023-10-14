import SwiftUI

struct AddUserView: View {
    @EnvironmentObject var storage: Storage
    @ObservedObject var motionManager: MotionManager
    
    @State var name: String = ""
    @State private var phoneNumber: String = ""
    @State private var email: String = ""
    @State private var address: String = ""
    
    var body: some View {
        
        ZStack{
            
            Color.lightBackgroundColor
                .ignoresSafeArea()
            
            VStack {
                
                Spacer()
                
                TextField( "Name", text: $name, prompt: Text("Name").foregroundColor(.orange.opacity(0.7)) )
                    .frame(height: 40)
                    .padding(.horizontal)
                    .background(Color.white)
                    .foregroundStyle(Color.orange)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                    .overlay {
                        RoundedRectangle(cornerRadius: 8).strokeBorder(Color.orange,lineWidth: 2)
                    }
                    .padding(.horizontal)
                    .keyboardType(.alphabet)
                
                TextField("Phone", text: $phoneNumber, prompt: Text("Phone").foregroundColor(.orange.opacity(0.7)))
                    .frame(height: 40)
                    .padding(.horizontal)
                    .background(Color.white)
                    .foregroundStyle(Color.orange)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                    .overlay {
                        RoundedRectangle(cornerRadius: 8).strokeBorder(Color.orange,lineWidth: 2)
                    }
                    .padding(.horizontal)
                    .keyboardType(.numberPad)
                
                TextField("Email", text: $email, prompt: Text("Email").foregroundColor(.orange.opacity(0.7)))
                    .frame(height: 40)
                    .padding(.horizontal)
                    .background(Color.white)
                    .foregroundStyle(Color.orange)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                    .overlay {
                        RoundedRectangle(cornerRadius: 8).strokeBorder(Color.orange,lineWidth: 2)
                    }
                    .padding(.horizontal)
                    .keyboardType(.emailAddress)
                
                TextField("Address", text: $address, prompt: Text("Address").foregroundColor(.orange.opacity(0.7)))
                    .frame(height: 40)
                    .padding(.horizontal)
                    .background(Color.white)
                    .foregroundStyle(Color.orange)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                    .overlay {
                        RoundedRectangle(cornerRadius: 8).strokeBorder(Color.orange,lineWidth: 2)
                    }
                    .padding(.horizontal)
                    .keyboardType(.default)
                
                Spacer()
                Button(action: {
                    let user = User(name: name)
                    user.phoneNumber = phoneNumber
                    user.email = email
                    user.homeAddress = address
                    storage.addUser(user: user)
                    // clear fields
                    // alert "User Added", may be some animations or something
                }, label: {
                    RoundedRectangle(cornerRadius: 8)
                        .strokeBorder(Color.white, lineWidth: 1)
                        .frame(width: 100,height: 50)
                        .background(content: {
                            RoundedRectangle(cornerRadius: 8).fill(Color.orange)
                        })
                        .shadow(color: .orange, radius: 3)
                        .overlay {
                            Text("Add User")
                                .bold()
                                .foregroundStyle(Color.white)
                        }
                })
                .disabled(name.isEmpty)
                .padding(.bottom,50)
            }
        }
        
//        .tint(Color.white)
//        .foregroundStyle(Color.white, Color.white)
//        .padding()
//        .offset(x: motionManager.roll * 100,
//                y: motionManager.pitch * 100)
//        .onAppear{
//            motionManager.startMonitoringMotionUpdates()
//        }
//        .onDisappear(perform: {
//            motionManager.stopMonitoringMotionUpdates()
//        })
    }
}

#Preview {
    AddUserView(motionManager: MotionManager()).environmentObject(Storage(cameras: [], users: MockData.sampleUsers))
}
