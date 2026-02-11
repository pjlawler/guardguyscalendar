//
//  ViewModel.swift
//  GuardGuysCalendarEditor
//
//  Created by Patrick Lawler on 10/5/23.
//

import SwiftUI

class ContentViewModel: ObservableObject {
    
    @Published var members: [UserData] = []
    @Published var isLoading: Bool = false
    
    @AppStorage("loggedInState") var isLoggedIn = false
    @AppStorage("loggedInUsername") var username = ""
    @AppStorage("loggedInAsAdmin") var isAdmin = false
    @AppStorage("loggedInUserId") var userId = 0
    @AppStorage("lastEventDownload") var lastDate = ""
    
    func login(email: String, password: String, success: @escaping(Bool) -> Void) {
        isLoading = true
        Task {
            defer {
                Task { await MainActor.run { self.isLoading = false } }
            }
            do {
                let data = try await NetworkManager.shared.makeApiRequestFor(.login(email: email, password: password))
                let results = try JSONDecoder().decode(LoginResult.self, from: data)
                await MainActor.run {
                    setUserLoginData(user: results.user)
                    success(results.user != nil ? true : false)
                }
            }
            catch {
                await MainActor.run {
                    setUserLoginData()
                    success(false)
                }
            }
        }
    }

    private func setUserLoginData(user: UserData? = nil) {
        if let user {
            self.isLoggedIn = true
            self.username = user.username ?? ""
            self.isAdmin = user.isAdmin ?? false
            self.userId = user.id ?? 0
        } else {
            self.isLoggedIn = false
            self.username = ""
            self.isAdmin = false
            self.userId = 0
        }
    }
}

