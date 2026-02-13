//
//  SettingsView.swift
//  ArtShare
//
//  Created by Huseyin D. Ulu (RIT Student) on 03.12.2024..
//

import SwiftUI

@MainActor
final class SettingsViewModel: ObservableObject{
    @Published var user: DbUser?
    @Published var bio: String = ""

    
    func loadUser() async {
        do {
            let authDataResult = try AuthenticationManager.shared.getAuthenticatedUser()
            self.user = try await UserManager.shared.getUser(userId: authDataResult.uid)
            self.bio = self.user?.bio ?? ""
        } catch {
            print("Error loading user: \(error)")
        }
    }
    
    
    func updateName(newName: String) async throws {
        guard let currentUser = user else {
            throw URLError(.badServerResponse)
        }
        
        try await UserManager.shared.updateUserName(userId: currentUser.userId, newName: newName)
        
        self.user = DbUser(
            userId: currentUser.userId,
            name: newName,
            photoUrl: currentUser.photoUrl,
            bio: currentUser.bio,
            dateCreated: currentUser.dateCreated
        )
    }
    
    func updateBio(newBio: String) async throws {
        guard let currentUser = user else {
            throw URLError(.badServerResponse)
        }

        try await UserManager.shared.updateUserBio(userId: currentUser.userId, newBio: newBio)

        self.user = DbUser(
            userId: currentUser.userId,
            name: currentUser.name,
            photoUrl: currentUser.photoUrl,
            bio: newBio, // Yeni bio'yu güncelliyoruz.
            dateCreated: currentUser.dateCreated
        )
    }
    
    func updateProfilePhoto(url: String) async throws {
        guard let currentUser = user else {
            throw URLError(.badServerResponse)
        }

        try await UserManager.shared.updateUserPhotoUrl(userId: currentUser.userId, photoUrl: url)

        self.user = DbUser(
            userId: currentUser.userId,
            name: currentUser.name,
            photoUrl: url,
            bio: currentUser.bio,
            dateCreated: currentUser.dateCreated
        )
    }

    
    
    func signOut() throws{
        try AuthenticationManager.shared.signOut()
    }
}

struct SettingsView: View {
    @StateObject private var viewModel = SettingsViewModel()
    @Binding var showSignInView: Bool
    @State private var isEditingName = false
    @State private var isEditingBio: Bool = false
    @State private var isEditingPhoto: Bool = false
    
    var body: some View {
        List {
            if let user = viewModel.user {
                Section(header: Text("User Info")) {
                    HStack {
                        Text("Edit Name")
                        Spacer()
                        Button {
                            isEditingName = true
                        } label: {
                            Image(systemName: "pencil")
                                .foregroundColor(.blue)
                        }
                    }
                    HStack {
                        Text("Edit Profile Photo")
                        Spacer()
                        Button {
                            isEditingPhoto = true
                        } label: {
                            Image(systemName: "pencil")
                                .foregroundColor(.blue)
                        }
                    }
                    .sheet(isPresented: $isEditingPhoto) {
                        if let user = viewModel.user {
                            PhotoEditView(currentPhotoUrl: user.photoUrl) { newUrl in
                                Task {
                                    try? await viewModel.updateProfilePhoto(url: newUrl)
                                }
                            }
                        }
                    }
                    
                    HStack {
                        Text("Edit Bio")
                        Spacer()
                        Button {
                            isEditingBio = true
                        } label: {
                            Image(systemName: "pencil")
                                .foregroundColor(.blue)
                        }
                    }
                    
                    
                    HStack {
                        Text("User ID:")
                        Spacer()
                        Text(user.userId)
                            .foregroundColor(.secondary)
                    }
                }
            }

            Section {
                Button("Log Out") {
                    Task {
                        do {
                            try viewModel.signOut()
                            showSignInView = true
                        } catch {
                            print(error)
                        }
                    }
                }
            }
        }
        .navigationTitle("Settings")
        .task {
            await viewModel.loadUser()
        }
        .sheet(isPresented: $isEditingName) {
            if let user = viewModel.user {
                NameEditView(user: user) { newName in
                    Task {
                        try? await viewModel.updateName(newName: newName)
                        isEditingName = false
                    }
                }
            }
        }
        .sheet(isPresented: $isEditingBio) {
            if let user = viewModel.user {
                BioEditView(user: user) { newBio in
                    Task {
                        try? await viewModel.updateBio(newBio: newBio)
                        isEditingBio = false
                    }
                }
            }
        }
    }
}

#Preview {
    NavigationStack{
        SettingsView(showSignInView: .constant(false))
    }
    
}
