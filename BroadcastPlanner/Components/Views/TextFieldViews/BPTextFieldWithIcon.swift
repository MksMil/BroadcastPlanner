//
//  BPTextFieldWithIcon.swift
//  BroadcastPlanner
//
//  Created by Миляев Максим on 10.01.2024.
//

import SwiftUI

struct BPTextFieldWithIcon: View {
    
    @Binding var text: String
    var placeholder: String = "some text here"
    var imageName: String?
    var isSecureField: Bool = false
    
    
    var body: some View {
        HStack{
            Image(systemName: imageName ?? "textformat.abc")
                .imageScale(.large)
                
            
            if isSecureField{
             SecureField(placeholder, text: $text)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .frame(height: 40)
                    .padding(.horizontal)
                    
            } else {
                TextField(placeholder,text: $text)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .frame(height: 40)
                    .padding(.horizontal)
                    
                //                .background(Color(.systemGray3))
                //                .clipShape(RoundedRectangle(cornerRadius: 6))
            }
        }
        .frame(height: 30)
        .padding()
        .background {
            Color(.systemGray4)
        }
        .foregroundColor(.accentColor)//Color(.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .padding(.horizontal)
    }
}

#Preview {
    BPTextFieldWithIcon(text: .constant(""),imageName: "person")
}
