//
//  ScheduleWeekViewModel.swift
//  GuardGuysCalendarEditor
//
//  Created by Patrick Lawler on 10/5/23.
//

import SwiftUI

@MainActor
class ScheduleWeekViewModel: ObservableObject {
    
    @Published var members: [UserData] = []
    @Published var isLoading: Bool = false
    
    @AppStorage("loggedInState") var isLoggedIn = false
    @AppStorage("loggedInAsAdmin") var isAdmin = false
    @AppStorage("loggedInUserId") var userId = 0
    @AppStorage("lastEventDownload") var lastDate = ""
    
    func verifyStatus() {
        Task {
            do {
                let data = try await NetworkManager.shared.makeApiRequestFor(.getMembers)
                let results = try JSONDecoder().decode([UserData].self, from: data)
                if results.contains(where: {$0.id == userId && $0.isAdmin == isAdmin }) { return }
                isLoggedIn = false
            }
            catch {
                print("error")
            }
        }
    }
    
    func getMembers(completion: @escaping (Result<[UserData],NetworkErrors>) -> Void) {
        isLoading = true
        members.removeAll()
        
        Task {
            do {
                let data = try await NetworkManager.shared.makeApiRequestFor(.getMembers)
                let results = try JSONDecoder().decode([UserData].self, from: data)
                DispatchQueue.main.async { 
                    self.isLoading = false
                    completion(.success(results)) }
            }
            catch {
                self.isLoading = false
                print("Network Error \(error)")
                completion(.failure(NetworkErrors.networkFailure))
            }
        }
    }
    func getWeekEvents(for date: Date, completion: @escaping (Result<[ScheduleEvent], NetworkErrors>) -> Void) {
        
        verifyStatus()
        
        isLoading = true
        
        Task {
            do {
                let data = try await NetworkManager.shared.makeApiRequestFor(.getEvents(date: date))
                let results = try JSONDecoder().decode([ScheduleEvent].self, from: data)
                DispatchQueue.main.async {
                    self.isLoading = false
                    self.lastDate = convertDateToApiString(date: .now)
                    completion(.success(results)) }
            }
            catch {
                print("Network Error \(error)")
                DispatchQueue.main.async {
                    self.isLoading = false
                    completion(.failure(NetworkErrors.networkFailure)) }
            }
        }
    }
    func createEvent(event: SubmitEvent, success: @escaping(Bool) -> Void) {
        isLoading = true
        Task {
            do {
                let _ = try await NetworkManager.shared.makeApiRequestFor(.addEvent(data: event))
                DispatchQueue.main.async {
                    self.isLoading = false
                    success(true)
                }
            }
            catch {
                DispatchQueue.main.async {
                    self.isLoading = false
                    success(false)
                }
            }
        }
        
    }
    func updateEvent(id: Int, event: SubmitEvent, success: @escaping(Bool) -> Void) {
        isLoading = true
        Task {
            do { let _ = try await NetworkManager.shared.makeApiRequestFor(.editEvent(id: id, data: event))
                DispatchQueue.main.async { 
                    self.isLoading = false
                    success(true) }
            }
            catch { DispatchQueue.main.async { 
                self.isLoading = false
                success(false) }
            }
        }
    }
    func deleteEvent(id: Int, success: @escaping(Bool) -> Void) {
        isLoading = true
        Task {
            do { let _ = try await NetworkManager.shared.makeApiRequestFor(.deleteEvent(id: id))
                DispatchQueue.main.async { 
                    self.isLoading = false
                    success(true) }
            }
            catch { DispatchQueue.main.async { 
                self.isLoading = false
                success(false) }
            }
        }
    }
}
