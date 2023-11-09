//
//  EditEmployeeView.swift
//  GuardGuysCalendarEditor
//
//  Created by Patrick Lawler on 10/6/23.
//

import SwiftUI


struct AdminView: View {
    
    @StateObject var vm = AdminViewModel()
    
    @State var members:[UserData] = []
    
    @AppStorage("loggedInState") var isLoggedIn = false
    @AppStorage("loggedInUsername") var username = ""
    @AppStorage("loggedInAsAdmin") var isAdmin = false
    @AppStorage("loggedInUserId") var userId = 0
    
    var body: some View {
        
        NavigationStack {
            
            ZStack(content: {
                
                VStack(spacing: 0) {
                    
                    HStack(spacing: 0) {
                        Group {
                            Text("Logged in as:").font(.subheadline) +
                            Text("  \(username)").font(.headline)
                        }
                        Button("Logout") {
                            username = ""
                            isAdmin = false
                            isLoggedIn = false
                        }.buttonStyle(.bordered).padding(.leading, 40)
                        
                        Spacer()
                        NavigationLink {
                            EditInfoView(vm: vm, employee: UserData(id: nil, username: nil, email: nil, password: nil, isAdmin: nil, createdAt: nil, updatedAt: nil), newEmployee: true)
                        } label: {
                            VStack {
                                Image(systemName: "person.badge.plus")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(height: 25)
                            }
                        }.opacity(isAdmin ? 1 : 0)
                        
                    }.padding(.horizontal, 40).frame(height: 75)
                        .overlay(alignment: .bottom) { Rectangle().fill(.black).frame(height: 1) }
                    
                    ZStack {
                        List(members.filter({isAdmin ? true : $0.id == userId }), id:\.uuid) { member in
                            NavigationLink( "\(member.username ?? "")", destination: EditInfoView(vm: vm, employee: member))
                        }
                        
                        if vm.isLoading { LoadingScreenView() }
                        
                    }.ignoresSafeArea(.all)
                  
                    
                }
            })
            .navigationTitle("User Admin")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                members.removeAll()
                vm.getMembers { results in
                    switch results {
                    case .success(let success):
                        members.append(contentsOf: success)
                    case .failure(_):
                        break
                    }
                }
            }
        }
        
    }
    
    
}
