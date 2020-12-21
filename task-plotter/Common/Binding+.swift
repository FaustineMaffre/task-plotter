//
//  Binding+.swift
//  task-plotter
//
//  Created by Faustine Maffre on 13/12/2020.
//

import SwiftUI

extension Binding where Value == Double? {
    /// Returns a string binding to an optional double value.
    ///
    /// (This is a workaround because number formatter (in a TextField for example) on an optional value seem to cause
    /// issues.)
    func stringBinding(formatter: NumberFormatter) -> Binding<String> {
        Binding<String> {
            formatter.string(for: self.wrappedValue) ?? ""
        } set: { newString in
            if newString.isEmpty {
                // empty string: result is nil
                self.wrappedValue = nil
            } else if let parsed = formatter.number(from: newString) {
                // non-empty string that can be parsed: set value
                self.wrappedValue = parsed.doubleValue
            }
            // non-empty string that cannot be parsed: value not updated
        }
    }
}

extension Binding where Value == Int {
    /// Returns a double binding to an integer value.
    func doubleBinding(rounding: Bool = false) -> Binding<Double> {
        Binding<Double> {
            Double(self.wrappedValue)
        } set: {
            self.wrappedValue = Int(rounding ? round($0) : $0)
        }
    }
}
