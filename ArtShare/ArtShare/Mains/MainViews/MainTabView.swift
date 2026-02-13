//
//  MainTabView.swift
//  ArtShare
//
//  Created by Huseyin D. Ulu (RIT Student) on 05.12.2024..
//


import SwiftUI

struct MainTabView: View {
    @State private var selectedTab: Tab = .profile
    @Binding var showSignInView: Bool
    enum Tab {
        case gallery
        case upload
        case search
        case profile
    }

    var body: some View {
        
        
        TabView(selection: $selectedTab) {
            GalleryView()
                .tabItem {
                    Label("Gallery", systemImage: "photo.on.rectangle.angled")
                }
                .tag(Tab.gallery)

            UploadSelectionView()
                .tabItem {
                    Label("Upload", systemImage: "plus.circle")
                }
                .tag(Tab.upload)
            
            SearchView()                .tabItem {
                    Label("Search", systemImage: "magnifyingglass")
                }
                .tag(Tab.search)
            
            ProfileView(showSignInView: $showSignInView)
                .tabItem {
                    Label("Profile", systemImage: "person.crop.circle")
                }
                .tag(Tab.profile)
            
        }
    }
}

#Preview {
    MainTabView(showSignInView: .constant(false))
}
