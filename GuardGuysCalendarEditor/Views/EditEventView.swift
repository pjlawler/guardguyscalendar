//
//  EditEventView.swift
//  GuardGuysCalendarEditor
//
//  Created by Patrick Lawler on 10/11/23.
//

import SwiftUI


struct EditEventView: View {

    @Environment(\.dismiss) var dismiss
    
    var newEvent = false
    var event: ScheduleEvent
    
    @ObservedObject var vm: ScheduleWeekViewModel

    @State var input_event: String = ""
    @State var input_date: String = ""
    @State var input_duration: Int64 = 0
    @State var input_onsite: Bool = false
    @State var input_userId: Int? = nil
    @State var input_notes: String = ""
    
    @FocusState var eventFocused: Bool
    @FocusState var notesFocused: Bool

    
    @State var input_from: Date = Date.now
    @State var input_to: Date = Date.now
    @State var input_username: String = "????"
    @State var inputUserIndex: Int = 0
    @State var showDeleteAlert = false
    @State var users: [UserData] = []
    @State var pickerNames: [String] = []
    
    var scheduleDate: Date? = nil
    var defaultDuration: Int64 = 3_600_000
    
    var body: some View {

        VStack {
            
            let current_duration: Int64 = {
                return Int64(input_to.timeIntervalSince(input_from)) * 1000
            }()

            
            let current_userId: Int? = {
                if let index = users.firstIndex(where: { item in
                    item.username == input_username
                }) { return users[index].id } else { return nil }
            }()
            

            let dataUpdated: Bool = {
                if event.event != input_event { return true}
                if event.onsite != input_onsite { return true }
                if convertApiDateToDate(apiDate: event.date) != input_from { return true }
                if event.duration != current_duration { return true }
                if event.userId != current_userId { return true }
                if event.notes != input_notes { return true}
                return false
            }()
            
            let formValidation: Bool = {
                return input_event != ""
            }()
            
            Form {
                Section(header: Text("Event Info")) {
                    
                    TextField("Event", text: $input_event, axis: .vertical)
                        .focused($eventFocused)
                        .frame(maxWidth: .infinity)
                        .frame(height: 80, alignment: .top)
                        .multilineTextAlignment(.leading)
                        .onTapGesture { eventFocused = true }
                    
                    Toggle("OnSite", isOn: $input_onsite).toggleStyle(.switch)
                    
                    DatePicker("From", selection: $input_from)
                    
                    DatePicker("To", selection: $input_to)
                    
                    Picker("Assigned To", selection: $input_username) {
                        ForEach(pickerNames, id:\.self) {
                            Text($0)
                        }
                    }
                    
                    TextField("Notes", text: $input_notes, axis: .vertical)
                        .focused($notesFocused)
                        .frame(maxWidth: .infinity)
                        .frame(height: 120, alignment: .top)
                        .multilineTextAlignment(.leading)
                        .contentShape(Rectangle())
                        .onTapGesture { notesFocused = true }
                }
            }
            Button(action: {
                
                if newEvent {
                    
                    let event       = input_event
                    let onsite      = input_onsite
                    let date        = stringUTCDate(from: input_from)
                    let duration    = current_duration
                    let userId      = current_userId
                    let notes       = input_notes
                    let data        = SubmitEvent(event: event, date: date, duration: duration, onsite: onsite, userId: userId, notes: notes)
                    vm.createEvent(event: data) { success in
                        switch success {
                        case true:
                            dismiss()
                        case false:
                            break
                        }
                    }
                }
                else {
                    let id          = self.event.id
                    let event       = self.event.event != input_event ? input_event : nil
                    let onsite      = self.event.onsite != input_onsite ? input_onsite : nil
                    let date        = convertApiDateToDate(apiDate: self.event.date) != input_from ? stringUTCDate(from: input_from) : nil
                    let duration    = self.event.duration != current_duration ? current_duration : nil
                    let userId      = self.event.userId != current_userId ? current_userId == nil ? -1 : current_userId : nil
                    let notes       = self.event.notes != input_notes ? input_notes : nil
                    let data        = SubmitEvent(event: event, date: date, duration: duration, onsite: onsite, userId: userId, notes: notes)
                    vm.updateEvent(id: id, event: data) { success in
                        switch success {
                        case true:
                            dismiss()
                        case false:
                            break
                        }
                    }
                }
                
                
                
                
            }, label: {
                Text(newEvent ? "Add" : "Update")
                
            }).disabled(!dataUpdated || !formValidation).buttonStyle(.bordered)
                .padding(.bottom, 40)
            
            
        }
        .navigationTitle("Event")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            
            vm.getMembers { results in
                
                pickerNames.removeAll()
               
                switch results {
                case .success(let success):
                    users.append(contentsOf: success)
                    if newEvent { input_username = "????" }
                    else if !users.isEmpty && !newEvent {
                        input_username = users.first(where: {$0.id == event.userId})?.username ?? "????"
                    }
                    pickerNames = success.map({ item in
                        return item.username ?? ""
                    })
                    pickerNames.append("????")
                case .failure(let failure):
                    print(failure)
                }
            }
            
            if !newEvent {
                input_event = event.event
                input_onsite = event.onsite
                input_from  = convertApiDateToDate(apiDate: event.date)
                input_to = input_from.addingTimeInterval(Double((event.duration) / 1000))
                input_notes = event.notes
            }
            else {
                input_from      = newAppointmentDate(date: scheduleDate ?? Date.now)
                input_duration  = defaultDuration
                input_to        = input_from.addingTimeInterval(Double((defaultDuration) / 1000))
            }
        
        }
        
    }
}

public struct SubmitEvent {
    let event: String?
    let date: String?
    let duration: Int64?
    let onsite: Bool?
    let userId: Int?
    let notes: String?
}
