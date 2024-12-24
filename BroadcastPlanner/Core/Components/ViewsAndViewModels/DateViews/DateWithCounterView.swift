//
//  DateWithCounterView.swift
//  BroadcastPlanner
//
//  Created by Миляев Максим on 13.12.2024.
//

import SwiftUI
import Combine

final class DateWithCounterViewModel: ObservableObject {
    
    var date: Date
    @Published var eventDate: String = ""
    @Published var counter: String = "counter here"
    var timer = Timer.publish(every: 1,
                              on: .main,
                              in: .common)
        .autoconnect()
    var timeRemaining: TimeInterval {
        max(date.timeIntervalSinceNow, 0)
        }
    
    var countdownFormatter: DateComponentsFormatter {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.day, .hour, .minute, .second]
        formatter.unitsStyle = .positional
        formatter.zeroFormattingBehavior = .pad
        return formatter
    }
    
    var cancellables: Set<AnyCancellable> = []
    
    init(date: Date) {
        print("counter init")
        self.date = date
//        self.eventDate = BPDateFormater.format(date: date)
//        self.makePublisher()
    }
    
    func reConfigWithDate(date: Date){
        print("update vm")
        self.date = date
        self.eventDate = BPDateFormater.format(date: date)
        self.makePublisher()
    }
    
    func makePublisher(){
        cancellables.forEach { item in
            item.cancel()
        }
        self.timer.sink { [weak self] timer in
            self?.updateCounter()
        }
        .store(in: &cancellables)
    }
    
    func updateCounter() {
        if timeRemaining > 0 {
            counter = "\(countdownFormatter.string(from: timeRemaining) ?? "Time's up!")"
        } else {
            counter = "Time Up!"
        }
    }
}

struct DateWithCounterView: View {
    
    @StateObject var vm: DateWithCounterViewModel
    let date: Date
    
    init(date: Date) {
        print("counter view init")
        self.date = date
        self._vm = StateObject(wrappedValue: DateWithCounterViewModel(date: date))
    }
    
    var body: some View {
        VStack{
            Text(date.formatted())
            Text(vm.counter)
        }
        .task {
            vm.reConfigWithDate(date: date)
        }
    }
}

#Preview {
    DateWithCounterView(date: Date().addingTimeInterval(100000))
}
