import SwiftUI

struct DateEditView: View {

    @State var newDate: Date

    let dateRange: PartialRangeFrom<Date> = {
        let calendar = Calendar.current
        let startComponents = calendar.dateComponents(
            [.year, .month, .day], from: .now)
        return calendar.date(from: startComponents)!...
    }()

    let cancelAction: () -> Void
    let acceptAction: (Date) -> Void

    var body: some View {
        VStack {
            ConfirmationButtonGroupView(height: 50, isAcceptDisabled: false) {
                cancelAction()
            } acceptAction: {
                acceptAction(newDate)
            } content: {
                Text(newDate.formatted(date: .abbreviated, time: .omitted))
                    .font(.title)
                    .bold()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background {
                        RoundedRectangle(cornerRadius: 5).fill(
                            .ultraThickMaterial
                        )
                        .overlay {
                            RoundedRectangle(cornerRadius: 5).stroke(
                                Color.black, lineWidth: 1)
                        }
                    }
            }
            .padding(.horizontal, 10)
            .padding(.top, 20)
            .font(.title3)

            DatePicker(
                "Match Day", selection: $newDate,
                in: dateRange,
                displayedComponents: [.date]
            )
            .datePickerStyle(.graphical)
            Spacer()
        }
    }
}

#Preview {
    DateEditView(newDate: Date(), cancelAction: {}, acceptAction: { _ in })
}
