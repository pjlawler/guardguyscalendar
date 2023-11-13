//
//  ContentView.swift
//  GuardGuysCalendarEditor
//
//  Created by Patrick Lawler on 10/5/23.
//

import SwiftUI

struct ContentView: View {
    
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.scenePhase) private var scenePhase
    
    @StateObject var vm = ContentViewModel()
    @AppStorage("loggedInState") var isLoggedIn = false
    @AppStorage("loggedInUsername") var username = ""
    @AppStorage("loggedInAsAdmin") var isAdmin = false
    
    @State var loginMessage = ""
    @State var email: String = ""
    @State var password: String = ""
    @State var passwordHidden = true
    @State var loginError = false
    @State var isLoading: Bool = false
    
    var body: some View {
        
        ZStack {
            Color.clear
            switch isLoggedIn {
            case true: mainView
            case false: loginScreen
            }
        }.dynamicTypeSize(.large)
       
    }
    
    var loginScreen: some View {
        ZStack() {
            Color.clear
            VStack {
                VStack(spacing: 5) {
                    
                    Text("Schedule Log-in").font(.largeTitle).padding(.vertical, 20)
                    
                    Text("\(loginMessage)")
                        .foregroundStyle(loginError ? .red : .primary)
                        .multilineTextAlignment(.center)
                        .frame(height: 60)
                    
                    VStack(alignment: .leading) {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Email").font(.footnote).padding(.leading, 8)
                            TextField("Email Address", text: $email)
                                .textInputAutocapitalization(.never)
                                .autocorrectionDisabled()
                                .padding(.horizontal)
                                .frame(height: 40)
                                .background(.background)
                                .cornerRadius(10)
                        }
                        
                    }
                    
                    VStack(alignment: .leading) {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Password").font(.footnote).padding(.leading, 8)
                            
                            HStack {
                                if passwordHidden {
                                    SecureField("********", text: $password)
                                        .textInputAutocapitalization(.never)
                                        .autocorrectionDisabled()
                                }
                                
                                else {
                                    TextField("Password", text: $password)
                                        .textInputAutocapitalization(.never)
                                        .autocorrectionDisabled()
                                }
                                
                                Button(action: {
                                    passwordHidden.toggle()
                                }, label: {
                                    Image(systemName: passwordHidden ? "eye.slash" : "eye")
                                })
                            }
                            .padding(.horizontal)
                            .frame(height: 40)
                            .background(.background)
                            .cornerRadius(10)
                        
                        }
                        
                    }
                    
                    Button("Login") {
                        loginMessage = "Logging into the GuardGuys' server..."
                        vm.login(email: email, password: password) { success in
                            loginMessage = success ? "" : "Unable to log in, please check your credentials and try again!"
                            loginError = !success
                            isLoggedIn = success
                        }}
                    .disabled(isLoading)
                    .buttonStyle(.bordered)
                    .padding(.top, 30)
                    
                    
                }
                .padding(20)
                .background(.ultraThinMaterial)
                .cornerRadius(20)
                .padding(.horizontal, 30)
            }.frame(height: 150)
            
           
            if isLoading { LoadingScreenView() }
        }
        .background (alignment: .top) {
            Image(colorScheme == .dark ? "logo-white" : "logo-black")
                .resizable()
                .scaledToFit()
                .frame(width: 250)
                .padding(.top, 30)
        }
        .frame(maxWidth: 600)
        .onAppear {
            email = ""
            password = ""
            loginError = false
            loginMessage  = "Please enter your employee credentials"
        }
    }
    var mainView: some View {
        TabView {
            ScheduleWeekView().tabItem { Label("Schedule", systemImage: "calendar") }
            AdminView().tabItem { Label("User Admin", systemImage: "person.fill") }
        }
    }
    
    
}
