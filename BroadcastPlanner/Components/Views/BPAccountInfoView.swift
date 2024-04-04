//
//  BPAccountInfoView.swift
//  BroadcastPlanner
//
//  Created by Миляев Максим on 04.04.2024.
//

import SwiftUI

struct BPAccountInfoView: View {
    var cells: [UserSpecialization]
    @State var firstName: String = ""
    @State var middleName: String = ""
    @State var lastName: String = ""
    @State var phoneNumber: String = ""
    @State var email: String = ""
    
    var body: some View {
        ZStack{
            BackgroundTabItem()
            VStack{
                VStack{
                    Section {
                        VStack(alignment: .leading){
                            TextField("FirstName", text: $firstName)
                            Divider()
                            TextField("MiddleName", text: $middleName)
                            Divider()
                            TextField("LastName", text: $lastName)
                        }
                        .bold()
                        .frame(maxWidth: .infinity,alignment: .leading)
                    } header: {
                        Text("Personal Info")
                    }
                    
                    Section {
                        VStack{
                            TextField("PhoneNumber", text: $phoneNumber)
                            Divider()
                            TextField("E-mail", text: $email)
                            Divider()
                        }
                        //        Text("homeAddress") // map?
                        //        Text("Specialization") // separate view in gridView
                    } header: {
                        Text("Contacts")
                    }
                }
                .padding()
                .background {
                    RoundedRectangle(cornerRadius: 15).fill(.ultraThinMaterial)
                }
                .padding()
                
                BPTagView(tags: UserSpecialization.allCases)
                .padding()
                .background {
                    RoundedRectangle(cornerRadius: 15.0).fill(.ultraThinMaterial)
                }
                .padding()
                Spacer()
                
                Button(action: {
                    
                }, label: {
                    Text("Save")
                        .padding()
                        .padding(.horizontal,60)
                        .background {
                            RoundedRectangle(cornerRadius: 10).fill(.regularMaterial)
                        }
                })
            }
            .foregroundColor(.accent)
        }
    }
}

#Preview {
    BPAccountInfoView(cells: UserSpecialization.allCases)
}
