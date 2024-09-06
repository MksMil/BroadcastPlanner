//
//  String+Ext.swift
//  BroadcastPlanner
//
//  Created by Миляев Максим on 05.09.2024.
//

import Foundation

extension String
{
    func isValidEmail() -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}"
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: self)
    }
}
