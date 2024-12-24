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
}
