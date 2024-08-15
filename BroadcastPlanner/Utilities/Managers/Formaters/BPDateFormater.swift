import Foundation


enum BPDateFormater {
    
    static func format(date: Date) -> String {
        return date.formatted(
            date: .numeric,
            time: .shortened)
    }
}
