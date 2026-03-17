import SwiftUI

struct ImageWidthPreferenceKey: PreferenceKey {
    static var defaultValue: Double?

    static func reduce(value: inout Double?, nextValue: () -> Double?) {
        value = value ?? nextValue()
    }
}
