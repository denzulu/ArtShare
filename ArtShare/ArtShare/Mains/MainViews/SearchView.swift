//
//  SearchView.swift
//  ArtShare
//
//  Created by Huseyin D. Ulu (RIT Student) on 06.12.2024..
//


import SwiftUI
import FirebaseFirestore

struct SearchView: View {
    @State private var query: String = "" // Arama çubuğundaki kullanıcı girişi
    @State private var users: [AppUser] = [] // Arama sonuçları
    @State private var isLoading: Bool = false // Arama sırasında yüklenme durumu

    var body: some View {
        VStack {
            // Arama Çubuğu
            TextField("Search users...", text: $query)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
                .onChange(of: query) {
                    Task {
                        await searchUsers()
                    }
                }
            if isLoading {
                ProgressView("Searching...")
            } else if users.isEmpty {
                Text("No users found.")
                    .foregroundColor(.gray)
            } else {
                List(users) { user in
                    NavigationLink(destination: UserProfileView(user: user)) {
                        HStack {
                            Text(user.name)
                                .font(.headline)
                            Spacer()
                            Text(user.email)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                    }
                }
            }
        }
        .navigationTitle("Search")
    }

    private func searchUsers() async {
        guard !query.isEmpty else {
            users = []
            return
        }

        isLoading = true
        do {
            let snapshot = try await Firestore.firestore()
                .collection("users")
                .whereField("name", isGreaterThanOrEqualTo: query)
                .whereField("name", isLessThanOrEqualTo: query + "\u{f8ff}")
                .getDocuments()

            users = snapshot.documents.compactMap { doc in
                let data = doc.data()
                return AppUser(
                    id: doc.documentID,
                    name: data["name"] as? String ?? "No Name",
                    email: data["email"] as? String ?? "No Email"
                )
            }
        } catch {
            print("Error searching users: \(error)")
        }
        isLoading = false
    }
}

struct AppUser: Identifiable {
    let id: String
    let name: String
    let email: String
}

#Preview {
    SearchView()
}
