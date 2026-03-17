import Combine
// MARK: - RemainingTimeView.swift
import Foundation
import SwiftUI

struct RemainingTimeView: View {

  let goalDate: Date
  @State private var text: String
  let timerPublisher: AnyPublisher<Date, Never>

  init(
    goalDate: Date,
    timerPublisher: AnyPublisher<Date, Never>
  ) {
    self.goalDate = goalDate
    self._text = State(initialValue:
                        BPDateFormater
                          .timeInterval(to: goalDate,
                                        currentTime: .now,
                                        expiredString: "finished"))
    self.timerPublisher = timerPublisher
  }

  var body: some View {
    Text(text)
      .font(.footnote)
      .onReceive(timerPublisher) { value in
        text = BPDateFormater.timeInterval(
          to: goalDate,
          currentTime: value,
          expiredString: "finished"
        )
      }
  }
}
