//import SwiftUI
//
//struct TemplateCrewView: View {
//    @EnvironmentObject var settings: GlobalSettings
//    @EnvironmentObject var vm: AddEditPointOrObvanViewModel
//    @EnvironmentObject var dataManager: DataManager
//    
//    let template: ObvanTemplateCrew
//    let broadcast: Broadcast
//        
//    @State var selectedMember: Member?
//    @State var selectedHardware: String?
//    
//    @State var crew: Crew?
//    
//    @State private var predicate: NSPredicate // Состояние для предиката
//    private var members: FetchRequest<Member>
//
//    init(broadcast: Broadcast,template: ObvanTemplateCrew) {
//        self.template = template
//        self.broadcast = broadcast
//
//        self._predicate = State(initialValue: NSPredicate(format: "specializations CONTAINS %@", template.viewPosition))
//        self.members = FetchRequest(
//                    entity: Member.entity(),
//                    sortDescriptors: [],
//                    predicate: _predicate.wrappedValue
//                    
//                )
//    }
//
//    var body: some View {
////#if DEBUG
////        let _ = Self._printChanges()
////#endif
//        GeometryReader { geo in
//            HStack {
//                Text(template.viewPosition)
//                    .lineLimit(1)
//                    .font(.system(size: 12))
//                    .minimumScaleFactor(0.3)
//                    .frame(width: geo.size.width / 4, alignment: .leading)
//                Divider()
//                Menu(selectedMember?.viewCompactName ?? (members.wrappedValue.isEmpty ? "no crews": "Choose crew")) {
//                    ForEach(members.wrappedValue) { member in
//                        Button {
//                            crew?.member = crew?.member == member ? nil:member
//                            selectedMember = selectedMember == member ? nil : member
//                        } label: {
//                            HStack {
//                                Text(member.viewCompactName)
//                                Spacer()
//                                if crew?.member == member{
//                                    Image(systemName: "checkmark")
//                                }
//                            }
//                        }
//                        .disabled(broadcast.viewCrews.contains(where: { crew in
//                            crew.member == member
//                        }) && selectedMember != member)
//                        .opacity(broadcast.viewCrews.contains(where: { crew in
//                            crew.member == member
//                        }) && selectedMember != member ? 0.5: 1)
//                    }
//                }
//                .disabled(members.wrappedValue.isEmpty)
//                Spacer()
//                Divider()
//                Menu(selectedHardware ?? "Empty", systemImage: "keyboard") {
//                    ForEach(settings.hardwareType, id: \.self) { type in
//                        Button{
//                            crew?.hardware?.type = crew?.hardware?.type == type ? settings.hardwareType[0]: type
//                            selectedHardware = selectedHardware == type ? settings.hardwareType[0] : type
//                        } label: {
//                            HStack{
//                                Text("\(type)")
//                                Spacer()
//                                if crew?.hardware?.type == type {
//                                    Image(systemName: "checkmark")
//
//                                }
//                            }
//                        }
//                    }
//                }
//                .font(.system(size: 12))
//                .minimumScaleFactor(0.4)
//                .frame(width: geo.size.width / 4, alignment: .leading)
//            }
//        }
//        .padding(4)
//        .background {
//            RoundedRectangle(cornerRadius: 5)
//                .fill(.ultraThinMaterial)
//                .overlay {
//                    RoundedRectangle(cornerRadius: 5)
//                        .stroke(.ultraThinMaterial, lineWidth: 2)
//                }
//        }
//        .onAppear{
//            if let oldCrew = broadcast.viewCrews.compactMap({ crew in
//               return crew.viewTemplateId == template.viewId ? crew:nil
//            }).first {
//                self.crew = oldCrew
//            } else {
//                let newCrew: Crew = dataManager.mainContext.fetchOrCreateObject(withID: UUID().uuidString)
//                let hardware: Hardware = dataManager.mainContext.fetchOrCreateObject(withID: UUID().uuidString)
//                newCrew.updateValues(position: template.viewPosition,
//                                     x: template.viewX,
//                                     y: template.viewY,
//                                     scaleFactor: template.viewScaleFactor,
//                                     rotation: template.viewRotation,
//                                     task: nil,
//                                     member: nil,
//                                     hardware: hardware,
//                                     broadcast: broadcast,
//                                     obvanId: template.parentObvan?.viewId,
//                                     templateId: template.viewId,
//                                     in: dataManager.mainContext)
//                hardware.crew = newCrew
//                broadcast.addToCrews(newCrew)
//                self.crew = newCrew
//            }
//            selectedMember = crew?.member
//            selectedHardware = crew?.hardware?.type
//        }
//    }
//}
