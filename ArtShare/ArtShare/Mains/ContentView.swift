//
//  RootView.swift
//  ArtShare
//
//  Created by Huseyin D. Ulu (RIT Student) on 03.12.2024..
//

import SwiftUI

struct ContentView: View {
    
    
    @State private var showSignInView: Bool = false
    var body: some View {
        ZStack{
            NavigationStack{
                MainTabView(showSignInView: $showSignInView)
            }
        }
        .onAppear{
            let authUser = try? AuthenticationManager.shared.getAuthenticatedUser()
            self.showSignInView = authUser == nil
        }
        .fullScreenCover(isPresented: $showSignInView) {
            NavigationStack{
                AuthenticationView(showSignInView: $showSignInView)
            }
        }
        
    }
}

#Preview {
    ContentView()
}
