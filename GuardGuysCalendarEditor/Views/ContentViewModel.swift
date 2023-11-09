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
            do {
                let data = try await NetworkManager.shared.makeApiRequestFor(.login(email: email, password: password))
                let results = try JSONDecoder().decode(LoginResult.self, from: data!)
                DispatchQueue.main.async {
                    
                    self.isLoading = false
                    
                    if let _ = results.user {
                        success(true)
                        self.isLoggedIn = true
                        self.username = results.user?.username ?? ""
                        self.isAdmin = results.user?.isAdmin ?? false
                        self.userId = results.user?.id ?? 0

                    }
                    else {
                        success(false)
                        self.isLoggedIn = false
                        self.username = ""
                        self.isAdmin = false
                        self.userId = 0
                    }
                }
            }
            catch {
                success(false)
                self.isLoading = false
                self.isLoggedIn = false
                self.username = ""
                self.isAdmin = false
                self.userId = 0
                
            }
        }
        
        
        
    }
   
}
