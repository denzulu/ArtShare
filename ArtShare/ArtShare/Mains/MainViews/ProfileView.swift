//
//  ProfileView.swift
//  ArtShare
//
//  Created by Huseyin D. Ulu (RIT Student) on 04.12.2024..
//

import SwiftUI
import FirebaseFirestore

@MainActor
final class ProfileViewModel: ObservableObject{
    
    @Published private(set) var user: DbUser? = nil
    @Published var posts: [Post] = []
    
    func loadCurrentUser() async throws{
        let authDataResult = try  AuthenticationManager.shared.getAuthenticatedUser()
        self.user = try await UserManager.shared.getUser(userId: authDataResult.uid)
    }
    
    func loadUserPosts() async {
        guard let userId = user?.userId else {
            print("User ID is nil")
            return
        }
        do {
            let snapshot = try await Firestore.firestore()
                .collection("posts")
                .whereField("user_id", isEqualTo: userId)
                
                .getDocuments()

            if snapshot.documents.isEmpty {
                print("No posts found for user ID: \(userId)")
            }

            posts = snapshot.documents.map { doc in
                let data = doc.data()
                let title = data["title"] as? String ?? ""
                let description = data["description"] as? String ?? ""
                let imageUrl = data["image_url"] as? String ?? ""
                let userId = data["user_id"] as? String ?? "unknown"
                let timestamp = data["date_created"] as? Timestamp ?? Timestamp()
                let tags = data["tags"] as? [String] ?? []
                let likes = data["likes"] as? Int ?? 0 

                

                return Post(
                    id: doc.documentID,
                    title: title,
                    description: description,
                    imageUrl: imageUrl,
                    userId: userId,
                    timestamp: timestamp,
                    username: user?.name ?? "Unknown",
                    tags: tags,
                    likes: likes
                )
            }
            print("Loaded posts: \(posts.count)")
        } catch {
            print("Error loading user posts: \(error)")
        }
    }
    
    func deletePost(post: Post) async {
        do {
            try await UserManager.shared.deletePost(postId: post.id)
            posts.removeAll { $0.id == post.id } // Arayüzü güncellemek için listeden kaldırıyoruz
        } catch {
            print("Error deleting post: \(error)")
        }
    }

    
}

struct ProfileView: View {
    @StateObject private var viewModel = ProfileViewModel()
    @Binding var showSignInView: Bool
    @State private var showDeleteConfirmation = false
    @State private var postToDelete: Post?

    var body: some View {
        VStack(spacing: 10) {
            if let user = viewModel.user {
                VStack {
                    if let photoUrl = user.photoUrl, let url = URL(string: photoUrl) {
                        AsyncImage(url: url) { image in
                            image
                                .resizable()
                                .scaledToFill()
                                .frame(width: 80, height: 80)
                                .clipShape(Circle())
                        } placeholder: {
                            ProgressView()
                        }
                    } else {
                        Image(systemName: "person.crop.circle.fill")
                            .resizable()
                            .frame(width: 80, height: 80)
                            .foregroundColor(.gray)
                    }
                    
                    Text(user.name)
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    if let bio = user.bio, !bio.isEmpty {
                        Text(bio)
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    
                    Text("\(viewModel.posts.count) Posts")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                .padding(.top, 10)
            }
            
            Divider()

            if viewModel.posts.isEmpty {
                Text("You haven't uploaded any posts yet.")
                    .foregroundColor(.gray)
            } else {
                ScrollView {
                    LazyVGrid(
                        columns: Array(repeating: GridItem(.flexible(), spacing: 5), count: 3),
                        spacing: 5
                    ) {
                        ForEach(viewModel.posts, id: \.id) { post in
                            NavigationLink(destination: PostDetailView(post: post)) {
                                PostThumbnailView(post: post)
                            }
                            .contextMenu {
                                Button(role: .destructive) {
                                    postToDelete = post
                                    showDeleteConfirmation = true
                                } label: {
                                    Label("Delete Post", systemImage: "trash")
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 5)
                }
            }
        }
        .alert("Are you sure you want to delete this post?", isPresented: $showDeleteConfirmation) {
            Button("Cancel", role: .cancel) {}
            Button("Delete", role: .destructive) {
                if let post = postToDelete {
                    Task {
                        await viewModel.deletePost(post: post)
                    }
                }
            }
        }
        .task {
            try? await viewModel.loadCurrentUser()
            await viewModel.loadUserPosts()
        }
        .navigationTitle("Profile")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                NavigationLink(destination: SettingsView(showSignInView: $showSignInView)) {
                    Image(systemName: "gear")
                        .font(.headline)
                }
            }
        }
    }
}
