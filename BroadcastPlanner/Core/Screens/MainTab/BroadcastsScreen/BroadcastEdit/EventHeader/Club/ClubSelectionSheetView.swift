//
//  ClubSelectionSheetView.swift
//  BroadcastPlanner
//
//  Created by Миляев Максим on 17.07.2025.
//

import SwiftUI

struct ClubSelectionSheetView: View {
    @Binding var selectedClub: Club?
    @Binding var excludedClub: Club?
    @FetchRequest<Club>(sortDescriptors: [])
    var clubs
    
    let acceptAction: (Club?)->()
    
//    init(selectedClub: Club? = nil, excludedClub: Club?,acceptAction: @escaping (Club?) -> Void) {
//        self.selectedClub = selectedClub
//        self.excludedClub = excludedClub
//        self.acceptAction = acceptAction
//    }
    
    var body: some View {
        ZStack {
            MainBackground()
            VStack(spacing:0){
                Text("Choose Club")
                    .font(.largeTitle)
                Divider()
                    .padding(8)
                ScrollView{
                    SmartCollectionLayout(hSpacing: 5, vSpacing: 5) {
                        ForEach(clubs) { club in
                            ClubSheetCellView(id: club.viewId,
                                              title: club.viewTitle,
                                              isSelected: selectedClub == club)
                            .onTapGesture {
                                withAnimation {
                                    if selectedClub == club {
                                        selectedClub = nil
                                    } else {
                                        selectedClub = club
                                    }
                                }
                            }
                        }
                    }
                    .padding(10)
                }
                .scrollContentBackground(.hidden)
                .scrollIndicators(.never)
                .frame(maxWidth: .infinity,maxHeight: .infinity,alignment: .top)
                .padding(.horizontal, 5)
                .padding(.vertical, 5)
                .onTapGesture {
                    withAnimation {
                        selectedClub = nil
                    }
                }
                Divider()
                    .padding(8)
                    .padding(.bottom,8)
                Button{
                    acceptAction(selectedClub)
                } label: {
                    Text("Accept")
                        .padding()
                        .background {
                            RoundedRectangle(cornerRadius: 5)
                                .fill( .ultraThinMaterial.opacity(selectedClub != nil ? 0.8 : 0.3))
                                .overlay {
                                    RoundedRectangle(cornerRadius: 5)
                                        .stroke(.ultraThinMaterial.opacity(selectedClub != nil ? 0.8: 0.3),
                                                lineWidth: 2)
                                }
                        }
                }
                .disabled(selectedClub == nil)
            }
            .padding(.vertical)
        }
        .task{
            guard let excludedClub, let id = excludedClub.id, !id.isEmpty else { return }
            let predicate = NSPredicate(format: "id != %@", id)
            clubs.nsPredicate = predicate
        }
    }
}

