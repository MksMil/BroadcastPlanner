// MARK: - MainEventListCell.swift
import SwiftUI
import Combine

struct MainEventListCell: View {

    let broadcast: Broadcast
    let currentUserId: String
    let timerPublisher: AnyPublisher<Date, Never>

    @State private var isExpired: Bool

    private var status: BroadcastStatus {
        broadcast.status(id: currentUserId)
    }

    private var borderColor: Color {
        status == .currentMemberOwned ? .red.opacity(0.4) : .white.opacity(0.4)
    }

    private var backgroundOpacity: Double {
        status == .currentMemberParticipated ? 0.5 : 0.3
    }

    init(
        broadcast: Broadcast,
        currentUserId: String,
        timerPublisher: AnyPublisher<Date, Never>
    ) {
        self.broadcast = broadcast
        self.currentUserId = currentUserId
        self.timerPublisher = timerPublisher
        self._isExpired = State(initialValue: broadcast.isExpired)
    }

    var body: some View {
        HStack {
            // MARK: Время и таймер
            VStack(spacing: 5) {
                Text(BPDateFormater.formatDate(date: broadcast.viewDate))
                    .font(.caption2)
                Text(BPDateFormater.formatTime(date: broadcast.viewDate))
              RemainingTimeView(goalDate: broadcast.viewDate,
                                timerPublisher: timerPublisher)
            }
            .frame(width: 100)

            Divider()
                .background(.white.opacity(0.4))

            // MARK: Логотипы
            LogosCellImageView(
                homeImageId: broadcast.homeClub?.viewId,
                guestImageId: broadcast.guestClub?.viewId,
                size: 45
            )
            .frame(height: 45)
            .padding(.vertical, 2)

            Divider()
                .background(.white.opacity(0.4))

            // MARK: Название и адрес
            VStack(alignment: .leading) {
                Text(broadcast.viewTitle)
                    .font(.title3)
                    .lineLimit(1)
                    .minimumScaleFactor(0.35)
                Spacer()
                Text(broadcast.viewAddress)
                    .font(.caption)
                    .lineLimit(2)
                    .minimumScaleFactor(0.35)
            }
            .padding(.vertical, 10)

            Spacer()
        }
        .frame(height: 70)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.white.opacity(backgroundOpacity))
        )
        .overlay {
            RoundedRectangle(cornerRadius: 8)
                .strokeBorder(borderColor, lineWidth: 2)
        }
        .foregroundStyle(Color.black)
        .opacity(isExpired ? 0.3 : 1)
        .onReceive(timerPublisher) { currentTime in
            if currentTime >= broadcast.viewDate {
                isExpired = true
            }
        }
    }
}
