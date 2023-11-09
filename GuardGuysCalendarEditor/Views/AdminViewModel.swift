//
//  AdminViewModel.swift
//  GuardGuysCalendarEditor
//
//  Created by Patrick Lawler on 10/5/23.
//

import SwiftUI

class AdminViewModel: ObservableObject {
    
    @Published var members: [UserData] = []
    @Published var isLoading: Bool = false
 
    func getMembers(completion: @escaping (Result<[UserData],NetworkErrors>) -> Void) {
        isLoading = true
        members.removeAll()
        
        Task {
            do {
                let data = try await NetworkManager.shared.makeApiRequestFor(.getMembers)
                let results = try JSONDecoder().decode([UserData].self, from: data!)
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
    func addMember(data: UserData, success: @escaping(Bool) -> Void) {
        isLoading = true
        Task {
            do {
                let _ = try await NetworkManager.shared.makeApiRequestFor(.addMember(data: data))
                DispatchQueue.main.async { 
                    self.isLoading = false
                    success(true) }
            }
            catch {
                print("Netwrok Error \(error)")
                DispatchQueue.main.async {  
                    self.isLoading = false
                    success(false) }
            }
        }
    }
    func updateMember(id: Int, data: UserData, errorMessage: @escaping(NetworkErrors?) -> Void) {
        isLoading = true
        Task {
            do {
                let _ = try await NetworkManager.shared.makeApiRequestFor(.editMember(id: id, data: data))
                DispatchQueue.main.async { 
                    self.isLoading = false
                    errorMessage(nil) }
            }
            catch {
               
                DispatchQueue.main.async {
                    self.isLoading = false
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
            do {
                let _ = try await NetworkManager.shared.makeApiRequestFor(.deleteMember(id: id))
                DispatchQueue.main.async {  
                    self.isLoading = false
                    success(true) }
               
            }
            catch {
                print("Netwrok Error \(error)")
                DispatchQueue.main.async {
                    self.isLoading = false
                    success(false) }
            }
            
        }
    }
}
