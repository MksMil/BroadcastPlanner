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
    let addAction: ()->()
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
                addAction()
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
        .confirmationDialog("?", isPresented: $isRemoveComfirmation) {
            Button("Remove \(title) template!", role: .destructive) {
                title = defaultTitle
                removeAction()
            }
        }
    }
}

#if DEBUG
#Preview {
    let dm = DataManager(globalDataManager: NetworkManager())
    let appState = ApplicationState()
    dm.networkManager.eventProgressHandler = appState
    return RootView()
        .environmentObject(GlobalSettings())
        .environmentObject(SessionManager())
        .environmentObject(appState)
        .environmentObject(Router())
        .environmentObject(dm)
        .environment(\.managedObjectContext, dm.mainContext)
}
#endif
