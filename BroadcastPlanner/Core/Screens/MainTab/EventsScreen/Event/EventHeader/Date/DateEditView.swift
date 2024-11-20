import SwiftUI

struct DateEditView: View {
    
    @State var newDate: Date
    
    let dateRange: PartialRangeFrom<Date> = {
        let calendar = Calendar.current
        let startComponents = calendar.dateComponents([.year,.month,.day], from: .now)
        return calendar.date(from:startComponents)!...
    }()
    
    let cancelAction: ()->Void
    let acceptAction: (Date)->Void
    
    var body: some View {
        VStack{
            ConfirmationButtonGroupView(height: 50, isAcceptDisabled: .constant(false)) {
                cancelAction()
            } acceptAction: {
                acceptAction(newDate)
            } content: {
                Text(newDate.formatted(date: .abbreviated, time: .omitted))
                    .fixedSize()
                    .font(.title)
                    .bold()
                    .padding(.vertical,5)
                    .padding(.horizontal,15)
                    .background {
                        RoundedRectangle(cornerRadius: 5).fill(.ultraThinMaterial)
                            .overlay {
                                RoundedRectangle(cornerRadius: 5).stroke(Color.black,lineWidth: 1)
                            }
                    }
                    .font(.title)
            }
            .padding(.horizontal,10)
            .padding(.top, 20)
            .font(.title3)
            
            
            DatePicker("Match Day", selection: $newDate,
                       in: dateRange,
                       displayedComponents: [.date])
                .datePickerStyle(.graphical)
                
            Spacer()
            
        }
    }
}

#Preview {
    DateEditView(newDate: Date(),cancelAction: {}, acceptAction: {_ in})
}
