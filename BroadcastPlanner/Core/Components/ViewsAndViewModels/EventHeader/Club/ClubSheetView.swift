import SwiftUI
import UIKit

struct ClubSheetView: View {
    @Environment(\.managedObjectContext) var moc
    
    @State private var selectedIndex: Int?
    @State private var selectedClub: LocalClub?
    
//    @State private var isEditState: Bool = false
    
    @FetchRequest<LocalClub>(sortDescriptors: [])
    var clubs
    
    @Namespace var clubNS
    
    let cancelAction: ()->Void
    let acceptAction: (LocalClub)->Void
    let createNewClubAction: ()->Void
    let editClubAction: (LocalClub)->Void
    
    var buttonTitle: String {
        guard let selectedClub else {return "Choose Club" }
        return "Edit \(selectedClub.viewTitle)"
    }
    
    var body: some View {
#if DEBUG
        let _ = Self._printChanges()
#endif
//        if !isEditState{
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
                    
                    Spacer()
                    //     edit club button
//                    Button{
////                        guard selectedClub != nil else { return }
////                        withAnimation{
////                            isEditState = true
////                        }
//                    } label: {
//                        Text(selectedClub == nil ? "Choose Club":buttonTitle)
//                            .lineLimit(2)
//                            .frame(width: 250)
//                            .frame(height: 50)
//                            .font(.title3)
//                            .background {
//                                Rectangle()
//                                    .fill(selectedClub == nil ? .ultraThinMaterial:.ultraThickMaterial)
//                                    .overlay {
//                                        Rectangle()
//                                            .stroke(Color.black.opacity(selectedClub == nil ? 0.3: 1),
//                                                    lineWidth: 1)
//                                    }
//                            }
//                    }
//                    .disabled(selectedClub == nil)
                    
                    Button{
                        //accept club to selected point
                        guard let selectedClub else { return }
                        acceptAction(selectedClub)
                    } label: {
                        Image(systemName: "checkmark")
                            .resizable()
                            .scaledToFit()
                            .bold()
                            .padding()
                            .background {
                                Rectangle().fill(selectedClub == nil ? .gray.opacity(0.3): .green.opacity(0.3))
                                    .overlay {
                                        Rectangle().stroke(selectedClub == nil ? Color.gray.opacity(0.5):Color.green.opacity(0.5),
                                                           lineWidth: 2)
                                    }
                            }
                            .frame(width: 50)
                    }
                    .disabled(selectedClub == nil)
                }
//                .disabled(isEditState)
                .padding(.horizontal,10)
                .padding(.top, 10)
                .font(.title3)
                
                
                ScrollView{
                    LazyVStack{
                        SmartLayout(hSpacing: 5, vSpacing: 5) {
                            //add club button
//                            Image(systemName: "plus.circle")
//                                .resizable()
//                                .scaledToFit()
//                                .padding()
//                                .frame(width: 75, height: 75)
//                                .onTapGesture {
//                                    Task{
//                                        selectedClub = DataManager.shared.fetchOrCreateClubWithId(UUID().uuidString,inContext: .main)
////                                    withAnimation{
////                                        isEditState = true
////                                    }
//                                    }
//                                }
                            ForEach(clubs) { club in
                                ClubSheetCellView(title: club.viewTitle,
                                                  image: /*club.viewImageLogo*/Image(systemName: "xmark"))
                                .padding(0)
                                .frame(width: 75,
                                       height: 75)
                                .onTapGesture {
                                    withAnimation{
                                        selectedClub = club
                                    }
                                }
                                .matchedGeometryEffect(id: club.id,
                                                       in: clubNS,
                                                       isSource: true)
                            }
                            .overlay {
                                if let selectedClub{
                                    Rectangle()
                                        .stroke(.blue, lineWidth: 2)
                                        .matchedGeometryEffect(id: selectedClub.id,
                                                               in: clubNS,
                                                               isSource: false)
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 15)
                    .scrollIndicators(.hidden)
                    //                .border(.blue, width: 2)
                    .scrollContentBackground(.hidden)
                }
                .onTapGesture {
                    withAnimation{
                        selectedClub = nil
                        selectedIndex = nil
                    }
                }
                //            .border(.red, width: 2)
            }
//        } else {
//            AddEditClubView(club: selectedClub ?? LocalClub(context: moc)) { title, uiimage,contacts ,urlString, location in
//                if let selectedClub{
//                    //                    Task{
//                    //                        selectedClub.title = title
//                    //                        if let uiimage{
//                    //                            if let localImage = selectedClub.imageLogo{
//                    //                                localImage.imageData = uiimage.pngData()
//                    //                            } else{
//                    //                                let localImage = DataManager.shared.createOrUpdateLocalImageWithId(UUID().uuidString, withImage: uiimage, andType: GlobalProperties.ImageType.club.rawValue)
//                    //                                selectedClub.imageLogo = localImage
//                    //                                localImage.parentClubLogo = selectedClub
//                    //                            }
//                    //                        }
//                    //                        selectedClub.contacts = contacts
//                    //                        selectedClub.urlString = urlString
//                    //                        if let location{
//                    //                            selectedClub.homeLocation = location
//                    //                            location.addToHomeClub(selectedClub)
//                    //                        }
//                    //                        DataManager.shared.saveContext()
//                    //                    }
//                    Task{
//                        await DataManager.shared.updateClubWith(id: selectedClub.viewId,
//                                                                title: title,
//                                                                uiimage: uiimage,
//                                                                contacts: contacts,
//                                                                urlString: urlString,
//                                                                location: location,
//                                                                inContext: .main)
//                    }
//                }
//                withAnimation{
//                    self.selectedClub = nil
//                    isEditState = false
//                }
//            } cancelAction: {
//                withAnimation{
//                    self.selectedClub = nil
//                    isEditState = false
//                }
//            } removeAction: {
//                if let selectedClub{
//                    Task{
//                        DataManager.shared.removeLocalClub(localClub: selectedClub, inContext: .main)
//                        DataManager.shared.saveContext(type: .main)
//                    }
//                }
//                withAnimation{
//                    selectedClub = nil
//                    isEditState = false
//                }
//            }
//        }
    }
}

#Preview {
    ClubSheetView(
        cancelAction: {},
        acceptAction: {_ in },
        createNewClubAction: {},
        editClubAction: {_ in })
    .environment(\.managedObjectContext, DataManager.shared.moc)
}
