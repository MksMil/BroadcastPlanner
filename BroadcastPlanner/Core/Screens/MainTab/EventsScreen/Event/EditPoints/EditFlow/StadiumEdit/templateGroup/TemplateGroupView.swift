import SwiftUI

struct TemplateGroup: View {
    let defaultTitle: String = "Choose template"
    @State var title: String = "Choose template"
    @State private var newTemplateName: String = ""
    var removeState: Bool {
        title == defaultTitle
    }
    let templates: FetchedResults<Template>
    let chooseAction: (Template) ->()
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
                    .frame(width: 45,height: 45)
                    .background {
                        RoundedRectangle(cornerRadius: 10).fill(
                            .ultraThinMaterial
                        )
                    }
            }
            .disabled(removeState)
            
            Divider()
                .frame(height: 45)
            
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
                    .frame(height: 45)
                    .background {
                        RoundedRectangle(cornerRadius: 10).fill(
                            .white.opacity(0.4)
                        )
                    }
            }
            Spacer()

            Button {
                isAddSheetshowed = true
            } label: {
                Image(systemName: "folder.badge.plus")
                    .resizable()
                    .scaledToFit()
                    .padding(.top,4)
                    .padding(.bottom,8)
                    .padding(.leading,8)
                    .padding(.trailing,4)
                    .frame(width: 45,height: 45)
                    .background {
                        RoundedRectangle(cornerRadius: 10).fill(
                            .ultraThinMaterial
                        )
                    }
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

//#Preview {
//    let mdm = DataManager(networkManager: NetworkManager())
//    mdm.setMember(id: "123")
//    let localEvent: Broadcast = mdm.mainContext.fetchOrCreateObject(withID: "id")
//    return BPEditStadiumView(event:localEvent)
//        .environmentObject(mdm)
//        .environment(\.managedObjectContext, mdm.mainContext)
//}
