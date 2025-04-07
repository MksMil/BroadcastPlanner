import SwiftUI

struct TimeEditView: View {
    @State var newDate: Date
    let cancelAction: ()->()
    let acceptAction: (Date)->Void
    @State private var selectedTime: (Int,Int) = (1,1)
    @Namespace var hourNs
    @Namespace var minNs
    var body: some View {
        VStack{
            ConfirmationButtonGroupView(height: 50, isAcceptDisabled: false) {
                cancelAction()
            } acceptAction: {
                acceptAction(newDate)
            } content: {
                Text("\(newDate.formatted(date: .omitted, time: .shortened))")
                    .font(.title)
                    .bold()
                    .frame(maxWidth: .infinity,maxHeight: .infinity)
                    .background {
                        RoundedRectangle(cornerRadius: 5).fill(.ultraThickMaterial)
                            .overlay {
                                RoundedRectangle(cornerRadius: 5).stroke(Color.black,
                                                                         lineWidth: 1)
                            }
                    }
            }
            .padding(.horizontal,10)
            .padding(.top,20)
            .foregroundStyle(.black)
            Text("Hours")
                .foregroundStyle(.gray)
            ScrollViewReader{ proxy in
                ScrollView(.horizontal){
                    HStack{
                        ForEach(0..<24) { num in
                            VStack{
                                Text(String(format: "%02d", num))
                                    .font(.title2)
                                    .bold()
                            }
                            .id(num)
                            .padding()
                            .background {
                                RoundedRectangle(cornerRadius: 5).fill(.white.opacity(0.4))
                                    .overlay {
                                        RoundedRectangle(cornerRadius: 5)
                                            .stroke(.black.opacity(0.4), lineWidth: 1)
                                            .matchedGeometryEffect(id: num, in: hourNs )
                                    }
                            }
                            .onTapGesture {
                                let minutes = Calendar.current.component(.minute, from: newDate)
                                withAnimation{
                                selectedTime.0 = num
                                    setDateTime(newHour: num, newMin: minutes)
                                }
                            }
                        }
                    }
                    .overlay{
                        RoundedRectangle(cornerRadius: 5)
                            .stroke(.blue, lineWidth: 1)
                            .matchedGeometryEffect(id: selectedTime.0, in: hourNs, isSource: false)
                    }
                }
                .onAppear{
                    setSelectedTimeFromEventDate()
                    proxy.scrollTo(selectedTime.0,anchor: .center)
                }
                .scrollIndicators(.hidden)
            }
            
            Text("Minutes")
                .foregroundStyle(.gray)
            HStack {
                ForEach([0,15,30,45],id: \.self) { num in
                    VStack {
                        Text(String(format: "%02d", num))
                    }
                    .padding()
                    .background {
                        RoundedRectangle(cornerRadius: 5).fill(.ultraThickMaterial)
                            .overlay {
                                RoundedRectangle(cornerRadius: 5)
                                    .stroke(.black.opacity(0.4), lineWidth: 1)
                                    .matchedGeometryEffect(id: num, in: minNs)
                            }
                    }
                    .overlay(content: {
                        RoundedRectangle(cornerRadius: 5)
                            .stroke(.blue, lineWidth: 1)
                            .matchedGeometryEffect(id: selectedTime.1, in: minNs, isSource: false)
                    })
                    .onTapGesture {
                        let hour = Calendar.current.component(.hour, from: newDate)
                        withAnimation{
                            selectedTime.1 = num
                            setDateTime(newHour: hour, newMin: num)
                        }
                    }
                }
            }
            
            Spacer()
            
        }
    }
    
    func setDateTime(newHour: Int, newMin: Int){
        if let tempDate = Calendar.current.date(bySettingHour: newHour,minute: newMin, second: 0,of:newDate){
            newDate = tempDate
        }
    }
    
    func setSelectedTimeFromEventDate(){
        var hour = Calendar.current.component(.hour, from: newDate)
        var min = Calendar.current.component(.minute, from: newDate)
        switch min {
            case 0...7:
                min = 0
            case 8...22:
                min = 15
            case 23...37:
                min = 30
            case 38...52:
                min = 45
            case 53... :
                min = 0
                
                hour = hour > 22 ? 0 : (hour + 1)
            default:
                min = 0
        }
        setDateTime(newHour: hour, newMin: min)
        selectedTime = (hour,min)
    }
}

#Preview {
    TimeEditView(newDate: Date(),cancelAction: {}, acceptAction: {_ in })
}
