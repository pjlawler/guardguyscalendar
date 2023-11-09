//
//  EditInfoView.swift
//  GuardGuysCalendarEditor
//
//  Created by Patrick Lawler on 10/11/23.
//

import SwiftUI


struct EditInfoView: View {
    
    @Environment(\.dismiss) var dismiss
    @ObservedObject var vm: AdminViewModel
    var employee: UserData
    var newEmployee: Bool = false
    
    @State var input_username: String = ""
    @State var input_email: String = ""
    @State var input_password: String = ""
    @State var input_isAdmin: Bool = false
    @State var shouldDelete: Bool = false
    
    @FocusState var usernameFocused: Bool
    @FocusState var emailFocused: Bool
    @FocusState var passwordFocused: Bool
    
    
    @AppStorage("loggedInState") var isLoggedIn = false
    @AppStorage("loggedInUsername") var username = ""
    @AppStorage("loggedInAsAdmin") var isAdmin = false
    @AppStorage("loggedInUserId") var userId = 0
    
    
    @State private var passwordHidden = true
    @State private var showDeleteUserAlert = false
    @State private var showDeleteErrorAlert = false
    @State private var showNetworkErrorAlert = false
    @State private var networkErrorMessage = ""
    @State private var showUpdateAlert = false
    
    
    var body: some View {
        ZStack(alignment: .top){
            
            let passwordUpdated: Bool = {
                return input_password != ""
            }()
            
            let dataUpdated: Bool = {
                if input_username == employee.username && input_email == employee.email && !passwordUpdated && employee.isAdmin == input_isAdmin {
                    return false
                }
                return true
            }()
            
            let formValidation: Bool = {
                if input_username != employee.username { if input_username.count < 4 { return false } }
                if input_email != employee.email { if input_email.count < 4 {return false } }
                if (passwordUpdated || newEmployee ) && (input_password.count < 4 || input_password.prefix(1) == "$") { return false }
               return true
            }()
            
            Color.clear
            
            VStack() {
                
                VStack(spacing: 20) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Username").font(.footnote).padding(.leading, 8)
                        TextField("User Name", text: $input_username)
                            .padding(.horizontal)
                            .frame(height: 40)
                            .background( Color(uiColor:  UIColor.secondarySystemBackground))
                            .cornerRadius(10)
                            .focused($usernameFocused)
                            .onTapGesture {
                                usernameFocused = true
                            }
                    }
                    VStack(alignment: .leading) {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Email").font(.footnote).padding(.leading, 8)
                            TextField("Email Address", text: $input_email)
                                .autocorrectionDisabled(true)
                                .textInputAutocapitalization(.never)
                                .padding(.horizontal)
                                .frame(height: 40)
                                .background( Color(uiColor:  UIColor.secondarySystemBackground))
                                .cornerRadius(10)
                                .focused($emailFocused)
                                .onTapGesture {
                                    emailFocused = true
                                }
                        }
                        
                    }
                    VStack(alignment: .leading) {
                        
                        VStack(alignment: .leading, spacing: 2) {
                            
                            Text("Password").font(.footnote).padding(.leading, 8)
                            
                            HStack {
                                if passwordHidden {
                                    SecureField("********", text: $input_password) }
                                else {
                                    TextField("Password", text: $input_password)
                                }
                                
                                Button(action: {
                                    passwordHidden.toggle()
                                }, label: {
                                    Image(systemName: passwordHidden ? "eye.slash" : "eye")
                                })
                            }
                            .autocorrectionDisabled(true)
                            .textInputAutocapitalization(.never)
                            .padding(.horizontal)
                            .frame(height: 40)
                            .background( Color(uiColor:  UIColor.secondarySystemBackground))
                            .cornerRadius(10)
                            .focused($passwordFocused)
                            .onTapGesture {
                                passwordFocused = true
                            }
                            
                            ZStack {
                                if input_password != "" {
                                    if input_password.first == "$" { Text("Sorry, passwords may not start with a $").foregroundColor(.red) }
                                    else { Text("Only enter a password if you want to change it.").opacity(newEmployee ? 0 : 1) }
                                }
                            }.frame(height: 20).font(.caption2).frame(maxWidth: .infinity, alignment: .center)
                        }
                    }
                    
                    if isAdmin {
                        Toggle("Admin Rights", isOn: $input_isAdmin)
                            .padding(.horizontal, 8)
                            .disabled(userId == employee.id)
                    }
                }
                
                // update/add cta
                Button(action: {
                    let data = UserData(id: nil,
                                        username: input_username == employee.username ? nil : input_username,
                                        email: input_email == employee.email ? nil : input_email,
                                        password: !passwordUpdated ? nil : input_password ,
                                        isAdmin: input_isAdmin == employee.isAdmin ? nil : input_isAdmin,
                                        createdAt: nil, updatedAt: nil)
                    
                    if newEmployee {
                        vm.addMember(data: data) { success in
                            if success { dismiss() }
                            else { showUpdateAlert.toggle() }
                        }
                    }
                    else {
                        guard employee.id != nil else { return }
                        vm.updateMember(id: employee.id!, data: data) { errMessage in
                            if errMessage == nil { dismiss() }
                            else { showUpdateAlert.toggle() }
                        }
                    }
                }, label: {
                    Text(newEmployee ? "Add Employee" : "Update Info")
                    
                }).disabled((!newEmployee && !dataUpdated) || !formValidation).buttonStyle(.bordered)
                    .padding(.top, 40)
                
                
                Spacer()
                
                //delete button
                
                if isAdmin {
                    
                    Button(role: .destructive ) {
                        showDeleteUserAlert.toggle()
                    } label: {
                        Text("Delete Employee").tint(.red)
                    }
                    
                    .disabled(userId == employee.id || newEmployee).buttonStyle(.bordered)
                    .padding(.bottom, 40)
                }
                
                    
                
                
            }
            .padding(.horizontal, 20)
        }
        .navigationTitle("\(newEmployee ? "New Employee Info" : "Update Employee Info")")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear() {
            input_username = employee.username ?? ""
            input_email = employee.email ?? ""
            input_isAdmin = employee.isAdmin ?? false
        }
        .padding(.top, 75)
        .alert("Are you sure you want to delete this user?", isPresented: $showDeleteUserAlert) {
            
            Button("Delete", action: {
                guard employee.id != nil else { return }
                vm.deleteMember(id: employee.id!) { success in
                    if success { dismiss() }
                    else { showDeleteErrorAlert.toggle() }
                }
            })
            Button("Cancel", action: { print("cancel")})
        }
        .alert("Unable to delete the user! Please try again.", isPresented: $showDeleteErrorAlert) {
            Button("OK", role: .cancel){}
        }
        .alert("Please check your information and try again!", isPresented: $showUpdateAlert) {
            Button("OK", role: .cancel){}
        }
        .alert("\(networkErrorMessage)", isPresented: $showNetworkErrorAlert) {
            Button("OK", role: .cancel){}
        }
    }
}
