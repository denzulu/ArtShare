//
//  UserProfileView.swift
//  ArtShare
//
//  Created by Huseyin D. Ulu (RIT Student) on 06.12.2024..
//

import SwiftUI
import FirebaseFirestore

struct UserProfileView: View {
    let user: AppUser
    @State private var posts: [Post] = []
    @State private var isLoading: Bool = false

    var body: some View {
        VStack(spacing: 10) {
            // Kullanıcı bilgileri
            VStack {
                Image(systemName: "person.crop.circle.fill")
                    .resizable()
                    .frame(width: 80, height: 80)
                    .foregroundColor(.gray)

                Text(user.name)
                    .font(.title2)
                    .fontWeight(.bold)

                Text("\(posts.count) Posts")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            .padding(.top, 10)

            Divider()

            if isLoading {
                ProgressView("Loading posts...")
            } else if posts.isEmpty {
                Text("No posts found.")
                    .foregroundColor(.gray)
            } else {
                ScrollView {
                    LazyVGrid(
                        columns: Array(repeating: GridItem(.flexible(), spacing: 5), count: 3),
                        spacing: 5
                    ) {
                        ForEach(posts, id: \.id) { post in
                            NavigationLink(destination: PostDetailView(post: post)) {
                                PostThumbnailView(post: post)
                            }
                        }
                    }
                    .padding(.horizontal, 5)
                }
            }
        }
        .navigationTitle(user.name)
        .task {
            await fetchUserPosts()
        }
    }

    private func fetchUserPosts() async {
        isLoading = true
        do {
            let snapshot = try await Firestore.firestore()
                .collection("posts")
                .whereField("user_id", isEqualTo: user.id)
                .getDocuments()

            posts = snapshot.documents.compactMap { doc in
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
                    username: user.name,
                    tags: tags,
                    likes: likes
                )
            }
        } catch {
            print("Error fetching posts: \(error)")
        }
        isLoading = false
    }
}
