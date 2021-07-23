//
//  AxisFomatter.swift
//  CoincheckAPIApp
//
//  Created by Satoshi Ota on 2021/07/24.
//

import Foundation
import Charts

class IAxisDateFomatter: NSObject, IAxisValueFormatter {
    func stringForValue(_ value: Double, axis: AxisBase?) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .none
        formatter.timeStyle = .short
        return formatter.string(from: Date())
    }
}
