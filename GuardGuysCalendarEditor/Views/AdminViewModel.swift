//
//  AdminViewModel.swift
//  GuardGuysCalendarEditor
//
//  Created by Patrick Lawler on 10/5/23.
//

import SwiftUI

@MainActor class AdminViewModel: ObservableObject {
    
    @Published var members: [UserData] = []
    @Published var isLoading: Bool = false
 
    func getMembers(completion: @escaping (Result<[UserData],NetworkErrors>) -> Void) {
        isLoading = true
        members.removeAll()
        
        Task {
            defer { Task { await MainActor.run { self.isLoading = false } } }
            do {
                let data = try await NetworkManager.shared.makeApiRequestFor(.getMembers)
                let results = try JSONDecoder().decode([UserData].self, from: data)
                await MainActor.run {
                    completion(.success(results))
                }
            }
            catch {
                await MainActor.run {
                    print("Network Error \(error)")
                    completion(.failure(NetworkErrors.networkFailure))
                }
            }
        }
    }
    func addMember(data: UserData, success: @escaping(Bool) -> Void) {
        isLoading = true
        Task {
            defer { Task { await MainActor.run { self.isLoading = false } } }
            do {
                let _ = try await NetworkManager.shared.makeApiRequestFor(.addMember(data: data))
                await MainActor.run { success(true) }
            }
            catch {
                print("Netwrok Error \(error)")
                await MainActor.run { success(false) }
            }
        }
    }
    func updateMember(id: Int, data: UserData, errorMessage: @escaping(NetworkErrors?) -> Void) {
        isLoading = true
        Task {
            defer { Task { await MainActor.run { self.isLoading = false } } }
            do {
                let _ = try await NetworkManager.shared.makeApiRequestFor(.editMember(id: id, data: data))
                await MainActor.run { errorMessage(nil) }
            }
            catch {
                await MainActor.run {
                    switch error {
                    case NetworkErrors.emailValidation: errorMessage(NetworkErrors.emailValidation)
                    case NetworkErrors.passwordValidation: errorMessage(NetworkErrors.passwordValidation)
                    default: errorMessage(NetworkErrors.unknownError)
                    }
                }
            }
        }
    }
    func deleteMember(id: Int, success: @escaping(Bool) -> Void) {
        isLoading = true
        Task {
            defer { Task { await MainActor.run { self.isLoading = false } } }
            do {
                let _ = try await NetworkManager.shared.makeApiRequestFor(.deleteMember(id: id))
                await MainActor.run { success(true) }
            }
            catch {
                print("Netwrok Error \(error)")
                await MainActor.run { success(false) }
            }
            
        }
    }
}

