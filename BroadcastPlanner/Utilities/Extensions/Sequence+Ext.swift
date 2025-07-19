//
//  Sequence+Ext.swift
//  BroadcastPlanner
//
//  Created by Миляев Максим on 19.07.2025.
//

import Foundation

// Расширение для удаления дубликатов из Sequence
extension Sequence where Element: Hashable {
    func uniqued() -> [Element] {
        var seen = Set<Element>()
        return filter { seen.insert($0).inserted }
    }
}
