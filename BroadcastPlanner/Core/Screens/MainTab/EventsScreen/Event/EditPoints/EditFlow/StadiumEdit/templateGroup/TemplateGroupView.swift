import SwiftUI

struct TemplateGroup: View {
    let defaultTitle: String = "Choose template"
    @State var title: String = "Choose template"
    @State private var newTemplateName: String = ""
    var removeState: Bool {
        title == defaultTitle
    }
    let templates: FetchedResults<LocalTemplate>
    let chooseAction: (LocalTemplate)->()
    let addAction: (String)->()
    let removeAction: ()->()
    let setEmptyTemplateAction: ()->()
    
    @State private var isAddSheetshowed: Bool = false
    @State private var isRemoveComfirmation: Bool = false
    
    var body: some View {
        HStack {
            Button {
                
                isRemoveComfirmation = true
            } label: {
                Image(systemName: "trash")
                    .resizable()
                    .scaledToFit()
                    .padding(8)
                    .background {
                        RoundedRectangle(cornerRadius: 10).fill(
                            .white.opacity(0.4)
                        )
                    }
                .frame(width: 45,height: 45)
            }
            .disabled(removeState)
            
            Divider()
            
            Menu {
                Button("empty"){
                    title = defaultTitle
                    setEmptyTemplateAction()
                }
                ScrollView {
                    ForEach(templates, id: \.self) { template in
                        Button("\(template.viewName)") {
                            title = template.viewName
                            chooseAction(template)
                        }
                    }
                }
            } label: {
                Text("\(title)")
                    .minimumScaleFactor(0.2)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 15)
                    .background {
                        RoundedRectangle(cornerRadius: 10).fill(
                            .white.opacity(0.4)
                        )
                        .frame(height: 45)
                    }
            }
            Spacer()

            Button {
                isAddSheetshowed = true
            } label: {
                Image(systemName: "plus")
                    .resizable()
                    .scaledToFit()
                    .padding(8)
                    .background {
                        RoundedRectangle(cornerRadius: 10).fill(
                            .white.opacity(0.4)
                        )
                    }
                    .frame(width: 45,height: 45)
            }
        }
        .fullScreenCover(isPresented: $isAddSheetshowed) {
            VStack{
                VStack{
                    Text("Add new template")
                        .font(.largeTitle)
                        .foregroundStyle(.white)
                    CustomTemplateNameEditor(text: $newTemplateName){
                        isAddSheetshowed = false
                        addAction(newTemplateName)
                    }
                }
                .padding(.top, 200)
                Spacer()
            }
            .padding(.horizontal)
            .presentationBackground(.black.opacity(0.8))
        }
        .confirmationDialog("?", isPresented: $isRemoveComfirmation) {
            Button("Remove \(title) template!", role: .destructive) {
                title = defaultTitle
                removeAction()
            }
        }
    }
}

//#Preview {
//    TemplateGroup(templates: [] ){ _ in
//        
//    } addAction: { name in
//    } removeAction: { _ in
//        
//    }
//}

#Preview {
    let mdm = MainDataManager(localDataManager: DataManager(), globalDataManager: NetworkManager(),userId: "123")

   return BPEditStadiumView(event: mdm.localDataManager.fetchOrCreateEventWithId("123", inContext: .main) , editable: true)
        .environmentObject(mdm)
        .environment(\.managedObjectContext, mdm.localDataManager.moc)
}
