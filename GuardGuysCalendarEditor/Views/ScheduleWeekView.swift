//
//  ScheduleWeekView.swift
//  GuardGuysCalendarEditor
//
//  Created by Patrick Lawler on 10/21/23.
//

import SwiftUI

struct ScheduleWeekView: View {
    
    @Environment(\.scenePhase) private var scenePhase
    
    @StateObject private var vm = ScheduleWeekViewModel()
    
    @AppStorage("lastEventDownload") var lastDate = ""
    
    @State private var events:[ScheduleEvent] = []
    @State private var weekOf = getFirstDayOfWeek(for: Date.now)
   
    var body: some View {
        
        NavigationStack {
            
            VStack(spacing: 0) {
                
                // top control bar
                ZStack(alignment: .top) {
                    Color.clear
                    currentButton.offset(x: -150)
                    datePicker
                    addButton.offset(x: 150)
                }
                .frame(height: 75)
                .overlay(alignment: .bottom) { Rectangle().fill(.black).frame(height: 1) }
                
                
                // main view
                ZStack {
                    portraitView
                    if vm.isLoading { LoadingScreenView() }
                }
                
            }
            .onAppear {
                vm.getWeekEvents(for: weekOf) { result in
                    switch result {
                    case .success(let success):
                        events.removeAll()
                        events.append(contentsOf: success.sorted(by: {$0.date < $1.date }))
                    case .failure(let failure):
                        print(failure)
                    }
                }
            }
            .onChange(of: scenePhase) { value in
                if value == .active && !vm.isLoading {
                    
                    guard timeSinceApiDate(apiDate: lastDate, date: .now) > 30 else { return }
                    
                    vm.getWeekEvents(for: weekOf) { results in
                        switch results {
                        case .success(let success):
                            events.removeAll()
                            events.append(contentsOf: success.sorted(by: {$0.date < $1.date }))
                        case .failure(let failure):
                            print(failure)
                        }
                    }
                }
            }
            .onChange(of: weekOf) { _ in
                
                weekOf = getFirstDayOfWeek(for: weekOf)
                
                vm.getWeekEvents(for: weekOf) { results in
                    switch results {
                    case .success(let success):
                        events.removeAll()
                        events.append(contentsOf: success.sorted(by: {$0.date < $1.date }))
                    case .failure(let failure):
                        print(failure)
                    }
                }
            }
            .navigationTitle("Schedule")
            .navigationBarTitleDisplayMode(.inline)
        }
        
    }
    var currentButton: some View {
        Button(action: {
            weekOf = getFirstDayOfWeek(for: .now)
        }, label: {
            VStack(spacing: 5) {
                Text("This Week").font(.caption)
                Image(systemName: "calendar.circle")
                    .resizable()
                    .scaledToFit()
                    .frame(height: 25)
            }
        })
    }
    
    var addButton: some View {
        NavigationLink {
            EditEventView(newEvent: true, event: ScheduleEvent(id: 0, date: "", event: "", onsite: false, notes: "", duration: 0, userId: nil, createdAt: "", updatedAt: "", user: nil), vm: vm, scheduleDate: weekOf)
        } label: {
            VStack(spacing: 5) {
                Text("Add Event").font(.caption)
                Image(systemName: "plus.circle")
                    .resizable()
                    .scaledToFit()
                    .frame(height: 25)
            }
        }
    }
    
    var datePicker: some View {
        VStack(spacing: 0) {
            Text("Week of:").font(.caption2).fontWeight(.semibold)
            HStack {
                Button(action: {
                    weekOf = weekOf.addingTimeInterval(-604_800)
                }, label: {
                    Image(systemName: "chevron.left.square.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(height: 30)
                })
                
                DatePicker("Week of date", selection: $weekOf, displayedComponents: .date)
                    .labelsHidden()
               
                Button(action: {
                    weekOf = weekOf.addingTimeInterval(604_800)
                }, label: {
                    Image(systemName: "chevron.right.square.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(height: 30)
                })
            }
        }
    }
    
    var portraitView: some View {
        
        List {
            ForEach(0...6, id:\.self) {
                
                let sectionDate = weekOf.addingTimeInterval(Double($0 * 86_400))
                
                Section(header:
                            ZStack {
                    Color.clear
                    Text("\(dayLabel(date: sectionDate) )")
                }
                ) {
                    let eventsForDay = events.filter({ compareDates(apiDate: $0.date, date: sectionDate) })
                    
                    if eventsForDay.isEmpty {
                        HStack {
                            Text("No Events Scheduled").font(.headline)
                        }
                    }
                    else {
                        ForEach(eventsForDay, id:\.uuid) { item in
                            
                            NavigationLink {
                                EditEventView(event: ScheduleEvent(id: item.id, date: item.date, event: item.event, onsite: item.onsite, notes: item.notes, duration: item.duration, userId: item.userId, createdAt: "", updatedAt: "", user: nil), vm: vm)
                                
                            } label: {
                                
                                EventItemView(item: item)
                                    .swipeActions(allowsFullSwipe: false) {
                                        Button {
                                            vm.deleteEvent(id: item.id) { success in
                                                switch success {
                                                case true:
                                                    vm.getWeekEvents(for: weekOf) { results in
                                                        switch results {
                                                        case .success(let success):
                                                            events.removeAll()
                                                            events.append(contentsOf: success.sorted(by: { $0.date < $1.date }))
                                                        case .failure(let failure):
                                                            print(failure)
                                                        }
                                                    }
                                                case false:
                                                    print("unable to delete")
                                                }
                                            }
                                        } label: {
                                            Label {  Text("Delete")
                                            } icon: { Image(systemName: "trash.fill").tint(.red) }
                                        }
                                    }
                            }
                        }
                    }
                }.headerProminence(.increased)
            }
        }.listStyle(.plain)
    }
    
}
