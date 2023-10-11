import SwiftUI

struct AddUserView: View {
    @State var name: String = ""
    @State private var phoneNumber: String = ""
    @State private var email: String = ""
    @State private var address: String = ""
    
    var body: some View {
        Section {
            TextField("Name", text: $name)
                .frame(height: 40)
                .padding(.horizontal)
                .background(Color.gray.opacity(0.3))
                .clipShape(RoundedRectangle(cornerRadius: 8))
                .overlay {
                    RoundedRectangle(cornerRadius: 8).strokeBorder()
                }
                .padding(.horizontal)
                .keyboardType(.alphabet)
            
            TextField("Phone", text: $phoneNumber)
                .frame(height: 40)
                .padding(.horizontal)
                .background(Color.gray.opacity(0.3))
                .clipShape(RoundedRectangle(cornerRadius: 8))
                .overlay {
                    RoundedRectangle(cornerRadius: 8).strokeBorder()
                }
                .padding(.horizontal)
                .keyboardType(.numberPad)
            
            TextField("Email", text: $email)
                .frame(height: 40)
                .padding(.horizontal)
                .background(Color.gray.opacity(0.3))
                .clipShape(RoundedRectangle(cornerRadius: 8))
                .overlay {
                    RoundedRectangle(cornerRadius: 8).strokeBorder()
                }
                .padding(.horizontal)
                .keyboardType(.emailAddress)
            
            TextField("Address", text: $address)
                .frame(height: 40)
                .padding(.horizontal)
                .background(Color.gray.opacity(0.3))
                .clipShape(RoundedRectangle(cornerRadius: 8))
                .overlay {
                    RoundedRectangle(cornerRadius: 8).strokeBorder()
                }
                .padding(.horizontal)
                .keyboardType(.default)
        } header: {
            Text("User Data")
        }

        
            
            
        Button(action: {
            //add user here
        }, label: {
            Text("Add User")
        })
    }
}

#Preview {
    AddUserView()
}
