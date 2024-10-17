import SwiftUI

struct DateSlider: View {
    //Binding? or action closure when date selected...
    @State private var selectedDate: Date = Date()
    @State private var selectedIndex: Int = 1
    @State private var weeks: [[WeekDay]] = []
    
    var body: some View {
        VStack(spacing: 0){
            Text(selectedDate.format("dd MMMM YYYY"))
            TabView(selection: $selectedIndex){
                ForEach(weeks.indices, id:\.self){ index in
                    HStack(spacing: 3){
                        ForEach(weeks[index]){ day in
                            Circle()
                                .fill(day.date.isSameToDate(selectedDate) ? .blue: .gray)
                                .frame(width: 50, height: 50)
                                .overlay{
                                    VStack(spacing:0){
                                        Text(day.date.format("E"))
                                        Text(day.date.format("dd"))
                                    }
                                    .foregroundStyle(.white)
                                    .background {
                                        
                                    }
                                }
                                .onTapGesture {
                                    withAnimation{
                                        selectedDate = day.date
                                    }
                                }
                        }
                    }
                }
                .fullWidth()
            }
            .frame(height: 60)
            .padding()
            .tabViewStyle(.page(indexDisplayMode: .never))
            
        }
        .onAppear{
            weeks.append(Date.now.fetchPreviousWeek())
            weeks.append(Date.now.fetchWeek())
            weeks.append(Date.now.fetchNextWeek())
        }
        .onChange(of: selectedIndex) { newValue in
            paginate()
        }
    }
    
    func paginate(){
        if selectedIndex == 0 {
            if let tempDate = weeks[0].first?.date {
                let newWeek = tempDate.fetchPreviousWeek()
                weeks.insert(newWeek, at: 0)
                weeks.removeLast()
                selectedIndex = 1
            }
        } else if selectedIndex == weeks.count - 1 {
            if let tempDate = weeks.last?.first?.date {
                let newWeek = tempDate.fetchNextWeek()
                weeks.append(newWeek)
                weeks.removeFirst()
                selectedIndex = weeks.count - 2
            }
        }
    }
}

#Preview {
    DateSlider()
}
