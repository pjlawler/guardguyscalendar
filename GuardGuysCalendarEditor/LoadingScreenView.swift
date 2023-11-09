//
//  LoadingScreenView.swift
//  GuardGuysCalendarEditor
//
//  Created by Patrick Lawler on 10/18/23.
//

import SwiftUI

struct LoadingScreenView: View {
    var body: some View {
        ZStack {
            Color.clear
            ProgressView().progressViewStyle(CircularProgressViewStyle())
        }
        .ignoresSafeArea(.all)
        .background(.ultraThinMaterial)
    }
}

#Preview {
    LoadingScreenView()
}
