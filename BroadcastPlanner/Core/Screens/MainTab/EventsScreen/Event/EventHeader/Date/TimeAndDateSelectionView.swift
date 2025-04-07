//
//  TimeAndDateSelectionView.swift
//  BroadcastPlanner
//
//  Created by Миляев Максим on 16.12.2024.
//

import SwiftUI

final class TimeAndDateSelectionViewModel: ObservableObject{
    let date: Date
    
    @Published var isPresentedDatePicker: Bool = false
    @Published var isPresentedTimePicker: Bool = false
    
    @Published var eventDate: Date
    
    var returnedDate: Date
    
    init(date: Date) {
        self.date = date
        self.eventDate = date
        self.returnedDate = date
    }
    
    func updateDateWithDate(newDate: Date){
        returnedDate = newDate
        eventDate = newDate
        isPresentedDatePicker = false
    }
    
    func updateTimeWithDate(newDate: Date){
        returnedDate = newDate
        eventDate = newDate
        isPresentedTimePicker = false
    }
    
}

struct TimeAndDateSelectionView: View {
    
    @StateObject private var vm: TimeAndDateSelectionViewModel
    let logoSize: Double
    let acceptAction: (Date)->Void
    
    init(date: Date, logoSize: Double = 100, acceptAction: @escaping (Date)->Void) {
        self._vm =  StateObject(wrappedValue: TimeAndDateSelectionViewModel(date: date))
        self.logoSize = logoSize
        self.acceptAction = acceptAction
    }
    
    var body: some View {
        VStack(spacing: 20) {
            Text(
                vm.eventDate.formatted(
                    date: .abbreviated, time: .omitted)
            )
            .fixedSize()
            .font(.subheadline)
            .padding(5)
            
            .background {
                RoundedRectangle(cornerRadius: 5).fill(
                    .ultraThinMaterial
                ).overlay {
                    RoundedRectangle(cornerRadius: 5).stroke(
                        .white, lineWidth: 1)
                }
            }
            .padding(.top, 20)
            .onTapGesture {
                vm.isPresentedDatePicker = true
            }

            Text(
                vm.eventDate.formatted(
                    date: .omitted,
                    time: .shortened)
            )
            .frame(width: logoSize)
            .font(.title)
            .padding(.vertical, 5)
            .background {
                RoundedRectangle(cornerRadius: 5)
                    .fill(.ultraThinMaterial)
                    .overlay {
                        RoundedRectangle(cornerRadius: 5)
                            .stroke(.white, lineWidth: 1)
                    }
            }
            .onTapGesture {
                vm.isPresentedTimePicker = true
            }
        }
        //date picker sheet
        .sheet(
            isPresented: $vm.isPresentedDatePicker,
            content: {
                DateEditView(newDate: vm.eventDate) {
                    vm.isPresentedDatePicker = false
                } acceptAction: { newDate in
                    vm.updateDateWithDate(newDate: newDate)
                    acceptAction(vm.returnedDate)
                }
                .padding(.horizontal)
                .presentationBackground(.ultraThinMaterial)
                .presentationDetents([.fraction(0.65)])
            }
        )
        //time picker
        .sheet(
            isPresented: $vm.isPresentedTimePicker,
            content: {
                TimeEditView(newDate: vm.eventDate) {
                    vm.isPresentedTimePicker = false
                } acceptAction: { newDate in
                    vm.updateTimeWithDate(newDate: newDate)
                    acceptAction(vm.returnedDate)
                }
                .padding(.horizontal)
                .presentationBackground(.ultraThinMaterial)
                .presentationDetents([.fraction(0.5)])
            })
    }
}

#Preview {
    TimeAndDateSelectionView(date: Date()){ newDate in
        print("returning: \(newDate.formatted())")
    }
}
