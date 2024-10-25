import SwiftUI

struct ClubSheetView: View {
    @EnvironmentObject var globalStorage: GlobalStorage
    @Environment(\.managedObjectContext) var moc
    @State private var selectedClub: LocalClub?
    @State private var isPresentedAddEditView: Bool = false
    
    @FetchRequest<LocalClub>(sortDescriptors: []) var clubs
    
    @Namespace var clubNS
    
    let cancelAction: ()->Void
    let saveAction: ()->Void
    let selectAction: ()->Void
    let createAction: (LocalClub)->Void
    
    var buttonTitle: String {
            guard let selectedClub else {return "Choose Club" }
            return "Edit \(selectedClub.viewTitle)"
    }
    
    var body: some View {
        VStack(spacing: 20){
            HStack{
                Button {
                    cancelAction()
                } label: {
                    Image(systemName: "xmark")
                        .resizable()
                        .scaledToFit()
                        .bold()
                        .padding()
                        .background {
                            Rectangle()
                                .fill(.red
                                    .opacity(0.3))
                                .overlay {
                                    Rectangle()
                                        .stroke(Color
                                            .red
                                            .opacity(0.5),
                                                lineWidth: 2)
                                }
                        }
                        .frame(width: 50)
                }
                    Button{
                        //add new club
                        if selectedClub != nil{
                            isPresentedAddEditView.toggle()
                        } else {
                            
                        }
                    } label: {
                        Text(buttonTitle)
                            .lineLimit(2)
                            .frame(width: 250)
                            .frame(height: 50)
                            .font(.title3)
                            .background {
                                Rectangle()
                                    .fill(.ultraThickMaterial)
                                    .overlay {
                                        Rectangle()
                                            .stroke(Color.black,
                                                    lineWidth: 1)
                                    }
                            }
                    }
               
                Button{
                    //accept club to selected point
                    saveAction()
                } label: {
                    Image(systemName: "checkmark")
                        .resizable()
                        .scaledToFit()
                        .bold()
                        .padding()
                        .background {
                            Rectangle().fill(.green.opacity(0.3))
                                .overlay {
                                    Rectangle().stroke(Color.green.opacity(0.5),
                                                    lineWidth: 2)
                                }
                        }
                        .frame(width: 50)
                }
            }
            .padding(.horizontal,10)
            .padding(.top, 10)
            .font(.title3)
            
            ScrollView{
                    SmartLayout(hSpacing: 10, vSpacing: 10) {
                        //add club button
                        
                            Image(systemName: "plus.circle")
                                .resizable()
                                .scaledToFit()
                                .padding()
                                .frame(width: 80, height: 80)
                                .onTapGesture {
                                    selectedClub = globalStorage.container.fetchOrCreateClubWithId(UUID().uuidString)
                                    isPresentedAddEditView.toggle()
                                }
                        
                        ForEach(clubs){ club in
                            VStack{
                                club.viewImageLogo
                                    .resizable()
                                    .scaledToFit()
                                Text(club.viewTitle.prefix(3).uppercased())
                            }
                            .id(club.viewId)
                                .frame(width: 80, height: 80)
                                .onTapGesture {
                                    withAnimation{
                                        selectedClub = club
                                    }
                                }
                                .matchedGeometryEffect(id: club.viewId, in: clubNS)
                        }
                        .overlay {
                            if let selectedClub {
                                Rectangle()
                                    .stroke(.blue, lineWidth: 2)
                                    .matchedGeometryEffect(id: selectedClub.viewId, in: clubNS,isSource: false)
                            }
                        }
                    }
               
                .buttonStyle(.borderedProminent)
            }
            .padding(.horizontal, 15)
            .scrollIndicators(.hidden)
        }
        .fullScreenCover(isPresented: $isPresentedAddEditView) {
            AddEditClubView(club: selectedClub ?? LocalClub(context: moc))
        }
    }
}

#Preview {
    ClubSheetView(
                  cancelAction: {},
                  saveAction: {},
                  selectAction: {},
                  createAction: {_ in })
    .environmentObject(GlobalStorage(localUser: LocalUser(context: DataManager.shared.moc), networkManager: NetworkManager()))
    .environment(\.managedObjectContext, DataManager.shared.moc)
}
