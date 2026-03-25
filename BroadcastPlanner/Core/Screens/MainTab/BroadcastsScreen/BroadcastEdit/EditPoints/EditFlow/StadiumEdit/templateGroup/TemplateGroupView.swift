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
                    .bold()
                    .padding(12)
                    .frame(width: 45,height: 45)
                    .background {
                        RoundedRectangle(cornerRadius: 5)
                            .fill(.ultraThinMaterial)
                            .overlay {
                                RoundedRectangle(cornerRadius: 5)
                                    .stroke(Color.white.opacity(0.5), lineWidth: 2)
                            }
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
                        RoundedRectangle(cornerRadius: 5)
                            .fill(.ultraThinMaterial)
                            .overlay {
                                RoundedRectangle(cornerRadius: 5)
                                    .stroke(Color.white.opacity(0.5), lineWidth: 1)
                            }
                    }
            }
            Spacer()

            Button {
                addAction()
            } label: {
                Image(systemName: "tray.and.arrow.down")
                .resizable()
                .scaledToFit()
                .bold()
                .padding(10)
                .frame(width: 45,height: 45)
                .background {
                    RoundedRectangle(cornerRadius: 5)
                        .fill(.ultraThinMaterial)
                        .overlay {
                            RoundedRectangle(cornerRadius: 5)
                                .stroke(Color.white.opacity(0.5), lineWidth: 2)
                        }
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
