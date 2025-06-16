import Foundation


enum BPDateFormater {
    
    static func format(date: Date) -> String {
        return date.formatted(
            date: .numeric,
            time: .shortened)
    }
    
    static func formatDate(date: Date) -> String{
        return date.formatted(
            date: .abbreviated,
            time: .omitted)
    }
    
    static func formatTime(date: Date) -> String{
        return date.formatted(
            date: .omitted,
            time: .shortened)
    }
    
    static func timeInterval(to date: Date, currentTime: Date,expiredString: String) -> String {
        let interval = date.timeIntervalSince(currentTime)
        if interval <= 0 {
            return expiredString
        }
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.day,.hour, .minute, .second]
        formatter.unitsStyle = .positional
        return formatter.string(from: interval) ?? "Ошибка"
    }
}
