import SwiftUI

struct BPEventHeaderView: View {
    @StateObject var vm: BPEventHeaderViewModel

    let logoSize: Double = 100

    init(event: LocalEvent, routeAction: @escaping () -> Void) {
        self._vm = StateObject(
            wrappedValue: BPEventHeaderViewModel(event: event))
    }

    var body: some View {
#if DEBUG
        let _ = Self._printChanges()
#endif
        VStack(spacing: 20) {
            //team logos section
            HStack(alignment: .top) {
                //home team logo/selection action
//                LogoImageView(
//                    image: vm.event.homeImage,
//                    logoSize: logoSize
//                )
//                .onTapGesture {
//                    print("tap on home")
////                    vm.state = .selectHomeClubFlow
//                }

                //event date section
                TimeAndDateSelectionView(date: vm.eventDate,
                                         logoSize: logoSize) {newDate in
                    
                }
//                VStack(spacing: 40) {
//                    Text(
//                        vm.eventDate.formatted(
//                            date: .abbreviated, time: .omitted)
//                    )
//                    .fixedSize()
//                    .font(.subheadline)
//                    .padding(5)
//                    .background {
//                        RoundedRectangle(cornerRadius: 5).fill(
//                            .ultraThinMaterial
//                        ).overlay {
//                            RoundedRectangle(cornerRadius: 5).stroke(
//                                .white, lineWidth: 1)
//                        }
//                    }
//                    .onTapGesture {
//                        vm.isPresentedDatePicker = true
//                    }
//
//                    Text(
//                        vm.eventDate.formatted(
//                            date: .omitted,
//                            time: .shortened)
//                    )
//                    .frame(width: logoSize)
//                    .font(.title)
//                    .padding(.vertical, 5)
//                    .background {
//                        RoundedRectangle(cornerRadius: 5)
//                            .fill(.ultraThinMaterial)
//                            .overlay {
//                                RoundedRectangle(cornerRadius: 5)
//                                    .stroke(.white, lineWidth: 1)
//                            }
//                    }
//                    .onTapGesture {
//                        vm.isPresentedTimePicker = true
//                    }
//                }
                //guest team logo/selection action
//                LogoImageView(
//                    image: vm.event.guestImage,
//                    logoSize: logoSize
//                )
//                .onTapGesture {
//                    vm.state = .selectGuestClubFlow
//                }
            }
            .padding(.top, 25)

            //location description action
            VStack(spacing: 20) {
                // location title
                Text(vm.event.viewTitle)
                    .frame(minWidth: 200)
                    .font(.title2)
                    .lineLimit(2)
                    .padding(5)
                    .background(
                        RoundedRectangle(cornerRadius: 5)
                            .fill(.ultraThinMaterial)
                            .overlay {
                                RoundedRectangle(cornerRadius: 5)
                                    .stroke(.white, lineWidth: 1)
                            }
                    )
                    .onTapGesture {
                        vm.state = .selectLocationForEvent
                    }

                //loation address
                Text(vm.event.viewAddress)
                    .frame(minWidth: 200)
                    .font(.footnote)
                    .lineLimit(2)
                    .padding(5)
                    .background(
                        RoundedRectangle(cornerRadius: 5).fill(
                            .ultraThinMaterial
                        ).overlay {
                            RoundedRectangle(cornerRadius: 5).stroke(
                                .white, lineWidth: 1)
                        }
                    )
                    .onTapGesture {
                        vm.state = .selectLocationForEvent
                    }
            }
            Spacer()
        }
        .frame(maxWidth: .infinity)
        //animated headerBackground
        .background {
//            HeaderBackgroundTimelineView(event: vm.event)
            Color.randomColor()
        }
        //club/location select/add/edit/remove sheet
//        .sheet(
//            isPresented: $vm.locationOrClubSheet,
//            content: {
//                EventHeaderSheet(
//                    event: vm.event,
//                    state: $vm.state
//                )
//                .padding()
//                .presentationBackground(.ultraThinMaterial)
//                .presentationContentInteraction(.scrolls)
//                .presentationDetents(
//                    [.fraction(0.6),.fraction(0.65) ,.fraction(0.9), .fraction(1)],
//                    selection: $vm.locationSheetDetents)
//            }
//        )
        //date picker sheet
//        .sheet(
//            isPresented: $vm.isPresentedDatePicker,
//            content: {
//                DateEditView(newDate: vm.eventDate) {
//                    vm.isPresentedDatePicker = false
//                } acceptAction: { newDate in
//                    vm.updateDateWithDate(newDate: newDate)
//                }
//                .padding(.horizontal)
//                .presentationBackground(.ultraThinMaterial)
//                .presentationDetents([.fraction(0.65)])
//            }
//        )
//        //time picker
//        .sheet(
//            isPresented: $vm.isPresentedTimePicker,
//            content: {
//                TimeEditView(newDate: vm.eventDate) {
//                    vm.isPresentedTimePicker = false
//                } acceptAction: { newDate in
//                    vm.updateTimeWithDate(newDate: newDate)
//                }
//                .padding(.horizontal)
//                .presentationBackground(.ultraThinMaterial)
//                .presentationDetents([.fraction(0.5)])
//            })
    }
}

#Preview {
    NavigationStack {
        BPCreateEditEventView(
            event: DataManager.shared.fetchOrCreateEventWithId(
                "123", inContext: .main), userId: "123")
    }
    .environmentObject(GlobalSettings())
    .environmentObject(GlobalSessionStorage())
    .environmentObject(EventTabRouter())
    .environment(\.managedObjectContext, DataManager.shared.moc)
}


//#Preview {
//        MainEventsList()
//        .environmentObject(GlobalSessionStorage())
//        .environmentObject(GlobalSettings())
//        .environment(\.managedObjectContext, DataManager.shared.moc)
//}

//#Preview {
//    BPEventHeaderView(event: LocalEvent(context: DataManager.preview.moc)
//    )
//    .environmentObject(GlobalSettings())
//    .environmentObject(GlobalSessionStorage())
//    .environmentObject(EventTabRouter())
//}
