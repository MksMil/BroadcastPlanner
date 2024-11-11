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
            HStack{
                Button {
                    cancelAction()
                } label: {
                    Image(systemName: "xmark")
                        .resizable()
                        .scaledToFit()
                        .bold()
                        .padding()
                        .background {
                            Circle().fill(.red.opacity(0.3))
                                .overlay {
                                    Circle().stroke(Color.red.opacity(0.5),
                                                                             lineWidth: 2)
                                }
                        }
                        .frame(width: 50)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                
                Text(newDate.formatted(date: .abbreviated, time: .omitted))
                    .fixedSize()
                    .font(.title)
                    .bold()
                    .padding(.vertical,5)
                    .padding(.horizontal,15)
                    .background {
                        RoundedRectangle(cornerRadius: 5).fill(.ultraThinMaterial)
                            .overlay {
                                RoundedRectangle(cornerRadius: 5).stroke(Color.black,
                                                                         lineWidth: 1)
                            }
                    }
                    .font(.title)
                
                Button{
                    acceptAction(newDate)
                    
                } label: {
                    Image(systemName: "checkmark")
                        .resizable()
                        .scaledToFit()
                        .bold()
                        .padding()
                        .background {
                            Circle().fill(.green.opacity(0.3))
                                .overlay {
                                    Circle().stroke(Color.green.opacity(0.5),
                                                                             lineWidth: 2)
                                }
                        }
                        .frame(width: 50)
                }
                
                .frame(maxWidth: .infinity, alignment: .trailing)
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
