//
//  AddCommentView.swift
//  ArtShare
//
//  Created by Huseyin D. Ulu (RIT Student) on 06.12.2024..
//


import SwiftUI
import FirebaseFirestore
import FirebaseAuth

struct AddCommentView: View {
    var postId: String
    var onCommentAdded: () -> Void

    @State private var newComment: String = ""
    @State private var errorMessage: String = ""

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            TextField("Add a comment...", text: $newComment)
                .textFieldStyle(RoundedBorderTextFieldStyle())
            
            Button {
                Task {
                    await addComment()
                }
            } label: {
                Text("Post Comment")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .disabled(newComment.isEmpty)

            if !errorMessage.isEmpty {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .font(.footnote)
            }
        }
    }

    private func addComment() async {
        guard !newComment.isEmpty else { return }
        do {
            let commentData: [String: Any] = [
                "text": newComment,
                "timestamp": Timestamp(),
                "user_id": Auth.auth().currentUser?.uid ?? "unknown"
            ]
            try await Firestore.firestore()
                .collection("posts")
                .document(postId)
                .collection("comments")
                .addDocument(data: commentData)
            DispatchQueue.main.async {
                self.newComment = ""
                self.onCommentAdded()
            }
        } catch {
            errorMessage = "Failed to add comment: \(error.localizedDescription)"
        }
    }
}
