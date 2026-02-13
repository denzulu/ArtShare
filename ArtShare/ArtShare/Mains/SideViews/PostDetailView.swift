//
//  PostDetailView.swift
//  ArtShare
//
//  Created by Huseyin D. Ulu (RIT Student) on 06.12.2024..
//


import SwiftUI
import FirebaseFirestore
import FirebaseAuth


struct Comment: Identifiable {
    let id: String
    let userId: String
    let username: String
    let text: String
    let likes: Int
    let timestamp: Timestamp
}


@MainActor
final class PostDetailViewModel: ObservableObject {
    @Published var post: Post
    @Published var comments: [Comment] = []
    
    init(post: Post) {
        self.post = post
    }
    
    func togglePostLike(postId: String) async {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        
        let likeRef = Firestore.firestore()
            .collection("posts")
            .document(postId)
            .collection("likes")
            .document(userId)
        
        do {
            let snapshot = try await likeRef.getDocument()
            if snapshot.exists {
                try await likeRef.delete()
            } else {
                try await likeRef.setData(["timestamp": FieldValue.serverTimestamp()])
            }
            await updatePostLikeCount(postId: postId)
        } catch {
            print("Error toggling post like: \(error)")
        }
    }

    private func updatePostLikeCount(postId: String) async {
        let likesRef = Firestore.firestore()
            .collection("posts")
            .document(postId)
            .collection("likes")

        do {
            let snapshot = try await likesRef.getDocuments()
            let likeCount = snapshot.documents.count

            try await Task.detached {
                try await Firestore.firestore()
                    .collection("posts")
                    .document(postId)
                    .updateData(["likes": likeCount])
            }.value

            await MainActor.run {
                post.likes = likeCount
            }
        } catch {
            print("Error updating post like count: \(error)")
        }
    }


    
    func isPostLikedByCurrentUser(postId: String) async -> Bool {
        guard let userId = Auth.auth().currentUser?.uid else { return false }
        
        let likeRef = Firestore.firestore()
            .collection("posts")
            .document(postId)
            .collection("likes")
            .document(userId)
        
        do {
            let snapshot = try await likeRef.getDocument()
            return snapshot.exists
        } catch {
            print("Error checking like status: \(error)")
            return false
        }
    }
    
    
    
    
    func toggleCommentLike(postId: String, commentId: String) async {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        
        let likeRef = Firestore.firestore()
            .collection("posts")
            .document(postId)
            .collection("comments")
            .document(commentId)
            .collection("likes")
            .document(userId)
        
        do {
            let snapshot = try await likeRef.getDocument()
            
            if snapshot.exists {
                try await likeRef.delete()
            } else {
                try await likeRef.setData(["timestamp": FieldValue.serverTimestamp()])
            }
            
            await updateCommentLikeCount(postId: postId, commentId: commentId)
        } catch {
            print("Error toggling comment like: \(error)")
        }
    }
    
    private func updateCommentLikeCount(postId: String, commentId: String) async {
        let likesRef = Firestore.firestore()
            .collection("posts")
            .document(postId)
            .collection("comments")
            .document(commentId)
            .collection("likes")
        
        do {
            let snapshot = try await likesRef.getDocuments()
            let likeCount = snapshot.documents.count
            
            try await Task.detached {
                try await Firestore.firestore()
                    .collection("posts")
                    .document(postId)
                    .collection("comments")
                    .document(commentId)
                    .updateData(["likes": likeCount])
            }.value
            
            await MainActor.run {
                if let index = comments.firstIndex(where: { $0.id == commentId }) {
                    var updatedComment = comments[index]
                    updatedComment = Comment(
                        id: updatedComment.id,
                        userId: updatedComment.userId,
                        username: updatedComment.username,
                        text: updatedComment.text,
                        likes: likeCount,
                        timestamp: updatedComment.timestamp
                    )
                    comments[index] = updatedComment
                }
            }
        } catch {
            print("Error updating comment like count: \(error)")
        }
    }
    
    func isCommentLikedByCurrentUser(commentId: String) async -> Bool {
        guard let userId = Auth.auth().currentUser?.uid else { return false }
        
        let likeRef = Firestore.firestore()
            .collection("posts")
            .document(post.id)
            .collection("comments")
            .document(commentId)
            .collection("likes")
            .document(userId)
        
        do {
            let snapshot = try await likeRef.getDocument()
            return snapshot.exists
        } catch {
            print("Error checking like status: \(error)")
            return false
        }
    }
    
    
    
    
    func updatePost(title: String, description: String, tags: [String]) async throws {
        let updatedData: [String: Any] = [
            "title": title,
            "description": description,
            "tags": tags
        ]
        
        try await Firestore.firestore()
            .collection("posts")
            .document(post.id)
            .updateData(updatedData)
        
        await MainActor.run {
            post.title = title
            post.description = description
            post.tags = tags
        }
    }
    
    func deleteComment(postId: String, commentId: String) async {
        do {
            try await Firestore.firestore()
                .collection("posts")
                .document(postId)
                .collection("comments")
                .document(commentId)
                .delete()
            
            await MainActor.run {
                self.comments.removeAll { $0.id == commentId }
            }
        } catch {
            print("Error deleting comment: \(error)")
        }
    }
    
}


struct PostDetailView: View {
    @StateObject private var viewModel: PostDetailViewModel
    @State private var newComment: String = ""
    @State private var isEditingPost = false
    @State private var editedTitle: String = ""
    @State private var editedDescription: String = ""
    @State private var editedTags: String = ""
    @State private var isPostLiked = false
    
    
    init(post: Post) {
        _viewModel = StateObject(wrappedValue: PostDetailViewModel(post: post))
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 10) {
                
                if !viewModel.post.username.isEmpty {
                    NavigationLink(
                        destination: UserProfileView(
                            user: AppUser(
                                id: viewModel.post.userId,
                                name: viewModel.post.username,
                                email: ""
                            )
                        )
                    ) {
                        Text("Posted by: \(viewModel.post.username)")
                            .font(.subheadline)
                            .foregroundColor(.blue)
                    }
                }
                
                
                Text(viewModel.post.title)
                    .font(.title)
                    .fontWeight(.bold)
                
                if let url = viewModel.post.imageUrl, let imageUrl = URL(string: url) {
                    AsyncImage(url: imageUrl) { image in
                        image
                            .resizable()
                            .scaledToFit()
                            .cornerRadius(10)
                    } placeholder: {
                        ProgressView()
                    }
                }
                
                if !viewModel.post.description.isEmpty {
                    Text(viewModel.post.description)
                        .font(.body)
                        .padding(.vertical, 10)
                }
                
                if !viewModel.post.tags.isEmpty {
                    Text("Tags: \(viewModel.post.tags.joined(separator: ", "))")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                if Auth.auth().currentUser?.uid == viewModel.post.userId {
                    Button("Edit Post") {
                        editedTitle = viewModel.post.title
                        editedDescription = viewModel.post.description
                        editedTags = viewModel.post.tags.joined(separator: ", ")
                        isEditingPost = true
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.blue.opacity(0.1))
                    .foregroundColor(.blue)
                    .cornerRadius(8)
                }
                
                Divider()
                
                HStack {
                    Button(action: {
                        Task {
                            await viewModel.togglePostLike(postId: viewModel.post.id)
                            isPostLiked = await viewModel.isPostLikedByCurrentUser(postId: viewModel.post.id)
                        }
                    }) {
                        HStack {
                            Image(systemName: isPostLiked ? "heart.fill" : "heart")
                                .foregroundColor(isPostLiked ? .red : .gray)
                            Text("\(viewModel.post.likes)")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                    }
                }
                .task {
                    isPostLiked = await viewModel.isPostLikedByCurrentUser(postId: viewModel.post.id)
                }
                .padding(.vertical, 10)
                Divider()
                
                CommentsSection(
                    comments: viewModel.comments,
                    postId: viewModel.post.id,
                    toggleCommentLike: { commentId in
                        await viewModel.toggleCommentLike(postId: viewModel.post.id, commentId: commentId)
                    },
                    checkCommentLikeStatus: { commentId in
                        await viewModel.isCommentLikedByCurrentUser(commentId: commentId)
                    },
                    currentUserId: Auth.auth().currentUser?.uid ?? "",
                    postOwnerId: viewModel.post.userId,
                    deleteComment: { commentId in
                        await viewModel.deleteComment(postId: viewModel.post.id, commentId: commentId)
                    }
                )
                
                
                AddCommentView(postId: viewModel.post.id, onCommentAdded: {
                    Task {
                        await fetchComments()
                    }
                })
            }
            .padding()
        }
        .navigationTitle("Post Details")
        .task {
            await fetchComments()
        }
        .sheet(isPresented: $isEditingPost) {
            PostEditView(
                title: $editedTitle,
                description: $editedDescription,
                tags: $editedTags
            ) {
                Task {
                    let tagsArray = editedTags.split(separator: ",").map { $0.trimmingCharacters(in: .whitespaces) }
                    try? await viewModel.updatePost(
                        title: editedTitle,
                        description: editedDescription,
                        tags: tagsArray
                    )
                    isEditingPost = false
                }
            }
        }
    }
    
    private func fetchComments() async {
        do {
            let snapshot = try await Firestore.firestore()
                .collection("posts")
                .document(viewModel.post.id)
                .collection("comments")
                .order(by: "timestamp", descending: false)
                .getDocuments()
            
            var fetchedComments: [Comment] = []
            
            for doc in snapshot.documents {
                let data = doc.data()
                let text = data["text"] as? String ?? ""
                let userId = data["user_id"] as? String ?? "unknown"
                let likes = data["likes"] as? Int ?? 0
                let timestamp = data["timestamp"] as? Timestamp ?? Timestamp()
                let username = await fetchUsername(for: userId)
                
                fetchedComments.append(Comment(
                    id: doc.documentID,
                    userId: userId,
                    username: username,
                    text: text,
                    likes: likes,
                    timestamp: timestamp
                ))
            }
            
            DispatchQueue.main.async {
                viewModel.comments = fetchedComments
            }
        } catch {
            print("Error fetching comments: \(error)")
        }
    }
    
    private func fetchUsername(for userId: String) async -> String {
        do {
            let userSnapshot = try await Firestore.firestore()
                .collection("users")
                .document(userId)
                .getDocument()
            if let userData = userSnapshot.data(), let username = userData["name"] as? String {
                return username
            }
        } catch {
            print("Error fetching username: \(error)")
        }
        return "Unknown User"
    }
}
