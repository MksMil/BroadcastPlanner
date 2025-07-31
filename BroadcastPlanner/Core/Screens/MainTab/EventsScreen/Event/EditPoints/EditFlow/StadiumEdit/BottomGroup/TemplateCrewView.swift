import SwiftUI

struct TemplateCrewView: View {
    @EnvironmentObject var settings: GlobalSettings
    @EnvironmentObject var vm: AddEditPointOrObvanViewModel
    let crewPreview: CrewPreview
    let action: (CrewPreview) -> Void
    @State var selectedMember: Member?
    @State var selectedHardware: String?
    @State private var predicate: NSPredicate // Состояние для предиката
    private var members: FetchRequest<Member>

    init(crewPreview: CrewPreview, action: @escaping (CrewPreview) -> Void) {
        self.crewPreview = crewPreview
        self.selectedMember = crewPreview.member
        self.selectedHardware = crewPreview.hardware
        self.action = action
        // Инициализация предиката
        self._predicate = State(initialValue: NSPredicate(format: "specializations CONTAINS %@", crewPreview.position))
        // Инициализация FetchRequest с использованием предиката
        self.members = FetchRequest(
                    entity: Member.entity(),
                    sortDescriptors: [],
                    predicate: _predicate.wrappedValue
                )
    }

    var body: some View {
#if DEBUG
        let _ = Self._printChanges()
#endif
        GeometryReader { geo in
            HStack {
                Text(crewPreview.position)
                    .lineLimit(1)
                    .font(.system(size: 12))
                    .minimumScaleFactor(0.3)
                    .frame(width: geo.size.width / 4, alignment: .leading)
                Divider()
                Menu(selectedMember?.viewCompactName ?? (members.wrappedValue.isEmpty ? "no crews": "Choose crew")) {
                    ForEach(members.wrappedValue) { member in
                        Button {
                            selectedMember = selectedMember == member ? nil : member
                            crewPreview.member = selectedMember
                            action(crewPreview)
                        } label: {
                            HStack {
                                Text(member.viewCompactName)
                            }
                        }
                    }
                }
                .disabled(members.wrappedValue.isEmpty)
                Spacer()
                Divider()
                Menu(selectedHardware ?? "Unknown", systemImage: "keyboard") {
                    ForEach(settings.hardwareType, id: \.self) { type in
                        Button("\(type)", action: {
                            selectedHardware = selectedHardware == type ? nil : type
                            crewPreview.hardware = selectedHardware
                            action(crewPreview)
                        })
                    }
                }
                .font(.system(size: 12))
                .minimumScaleFactor(0.4)
                .frame(width: geo.size.width / 4, alignment: .leading)
            }
        }
        .padding(4)
        .background {
            RoundedRectangle(cornerRadius: 5)
                .fill(.ultraThinMaterial)
                .overlay {
                    RoundedRectangle(cornerRadius: 5)
                        .stroke(.ultraThinMaterial, lineWidth: 2)
                }
        }
        .onReceive(vm.$previewsCrew) { _ in
            // Обновление предиката при изменении previewsCrew
            predicate = NSPredicate(format: "specializations CONTAINS %@", crewPreview.position)
            print("\(crewPreview.position): OnAppear, members: \(members.wrappedValue.count)")
        }
    }
}
