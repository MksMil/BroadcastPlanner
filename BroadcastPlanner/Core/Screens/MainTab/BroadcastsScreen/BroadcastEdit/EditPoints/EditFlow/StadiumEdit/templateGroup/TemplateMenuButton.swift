import SwiftUI

struct TemplateMenuButton: View {
    let defaultTitle: String = "Choose template"
    @State private var title: String = "Choose template"
    @State private var isRemoveConfirmation = false
    @State private var isAddSheetShowed = false
    @State private var newTemplateName = ""

    var removeState: Bool { title == defaultTitle }

    let templates: FetchedResults<Template>
    let chooseAction: (Template) -> ()
    let addAction: (String) -> ()        // ← принимает имя
    let removeAction: () -> ()
    let setEmptyTemplateAction: () -> ()

    var body: some View {
        Menu {
            Section("шаблоны") {
                Button {
                    title = defaultTitle
                    setEmptyTemplateAction()
                } label: {
                    Label("пустой", systemImage: "square.dashed")
                }
                ForEach(templates, id: \.self) { template in
                    Button {
                        title = template.viewName
                        chooseAction(template)
                    } label: {
                        HStack {
                            Text(template.viewName)
                            if title == template.viewName {
                                Spacer()
                                Image(systemName: "checkmark")
                            }
                        }
                    }
                }
            }

            Divider()

            Button {
                newTemplateName = title == defaultTitle ? "" : title
                isAddSheetShowed = true
            } label: {
                Label("сохранить как шаблон", systemImage: "tray.and.arrow.down")
            }

            if !removeState {
                Button(role: .destructive) {
                    isRemoveConfirmation = true
                } label: {
                    Label("удалить \(title)", systemImage: "trash")
                }
            }
        } label: {
            HStack(spacing: 4) {
                Image(systemName: "list.bullet")
                    .font(.system(size: 24, weight: .medium))
                Text(title)
                    .font(.system(size: 18, weight: .medium))
                    .minimumScaleFactor(0.3)
                    .lineLimit(1)
              Spacer()
            }
            .foregroundStyle(.black)
            .padding(.horizontal, 8)
            .padding(.vertical, 8)
            .background {
                RoundedRectangle(cornerRadius: 7)
                    .fill(.ultraThinMaterial)
                    .overlay {
                        RoundedRectangle(cornerRadius: 7)
                            .stroke(Color.white.opacity(0.4), lineWidth: 1)
                    }
            }
        }
        .confirmationDialog("", isPresented: $isRemoveConfirmation) {
            Button("удалить шаблон \(title)?", role: .destructive) {
                title = defaultTitle
                removeAction()
            }
        }
        .sheet(isPresented: $isAddSheetShowed) {
            templateNameSheet
        }
    }

    private var templateNameSheet: some View {
        VStack(spacing: 16) {
            Text("сохранить шаблон")
                .font(.system(size: 15, weight: .medium))

            TextField("имя шаблона", text: $newTemplateName)
                .textFieldStyle(.roundedBorder)
                .autocorrectionDisabled()

            HStack(spacing: 12) {
                Button("отмена") {
                    isAddSheetShowed = false
                }
                .foregroundStyle(.secondary)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 10)
                .background {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(.ultraThinMaterial)
                }

                Button("сохранить") {
                    guard !newTemplateName.trimmingCharacters(in: .whitespaces).isEmpty
                    else { return }
                    title = newTemplateName
                    addAction(newTemplateName)
                    isAddSheetShowed = false
                }
                .foregroundStyle(.primary)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 10)
                .background {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(.ultraThinMaterial)
                        .overlay {
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.white.opacity(0.5), lineWidth: 1)
                        }
                }
            }
        }
        .padding(24)
        .presentationDetents([.height(200)])
        .presentationDragIndicator(.visible)
        .presentationBackground(.ultraThinMaterial)
    }
}
