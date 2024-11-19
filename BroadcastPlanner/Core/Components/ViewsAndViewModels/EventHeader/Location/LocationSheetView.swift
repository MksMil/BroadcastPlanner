import SwiftUI

struct LocationSheetView: View {
    @Environment(\.managedObjectContext) var moc
    
    @FetchRequest<LocalLocation>(sortDescriptors: []) var locations
    
    @State private var selectedLocation: LocalLocation?
    @State private var isAddEdit: Bool = false
    
    let cancelAction: ()-> Void
    let saveAction: (LocalLocation?)-> Void
    
    var body: some View {
        VStack{
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
                Button{
                    //accept location to selected point
                    saveAction(selectedLocation)
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
            Button("Add Location") {
                isAddEdit.toggle()
            }
            ScrollView{
                List{
                    ForEach(locations, id:\.id) { location in
                        Text("\(location.viewTitle)")
                        
                    }
                }
            }
            Spacer()
        }
        .fullScreenCover(isPresented: $isAddEdit ) {
            AddEditLocation(location: selectedLocation ?? DataManager.shared.fetchOrCreateLocationWithId(UUID().uuidString, inContext: .main)) {
                
            } acceptAction: { location in
                
            }
        }
    }
}

#Preview {
    LocationSheetView(cancelAction: {}, saveAction: {_ in })
        .environment(\.managedObjectContext, DataManager.shared.moc)
}
