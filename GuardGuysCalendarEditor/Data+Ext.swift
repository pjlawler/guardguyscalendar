//
//  Data+Ext.swift
//  GuardGuysCalendarEditor
//
//  Created by Patrick Lawler on 10/11/23.
//
import Foundation

extension Data {
    
    
    func consolePrintAsJson() {
            do {
                let json = try JSONSerialization.jsonObject(with: self, options: [])
                let data = try JSONSerialization.data(withJSONObject: json, options: .prettyPrinted)
                guard let jsonString = String(data: data, encoding: .utf8) else {
                    print("Inavlid data")
                    return
                }
                print(jsonString)
            } catch {
                print("Error: \(error.localizedDescription)")
            }
        }
    
    
}
