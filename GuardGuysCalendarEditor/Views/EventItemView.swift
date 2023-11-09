//
//  EventItemView.swift
//  GuardGuysCalendarEditor
//
//  Created by Patrick Lawler on 10/23/23.
//

import SwiftUI

struct EventItemView: View {
    
    var item: ScheduleEvent
    
    var body: some View {
        
        ZStack(alignment: .topLeading) {
            
            Text("space").font(.caption2).opacity(0.0) // used to bring the list separator to the left
            
            HStack(alignment: .top, spacing: 10) {
                VStack(alignment: .trailing) {
                    Text(convertApiDateToStringTime(apiDate: item.date))
                    Text(convertApiDateToStringTime(apiDate: item.date, addDuration: Int(item.duration)))
                    Text(item.user?.username ?? "????").minimumScaleFactor(0.5).lineLimit(1).padding(.top, 5)
                }
                .padding(.leading, 15).padding(.vertical, 4).padding(.trailing, 10)
                .frame(width: 100, alignment: .trailing).background(.thinMaterial).font(.subheadline)
                
                Text(item.event).font(.headline)
                    .multilineTextAlignment(.leading)
                    .minimumScaleFactor(0.7)
            }
        }.overlay(alignment: .leading) {
            Rectangle().fill(item.onsite ? .blue : .clear).frame(width: 12)
            Image(systemName: "music.note").resizable().scaledToFit().frame(width: 8).opacity(item.notes.isEmpty ? 0 : 1)
        }
    }
}
