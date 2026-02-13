//
//  CommentsSection.swift
//  ArtShare
//
//  Created by Huseyin D. Ulu (RIT Student) on 07.12.2024..
//
import SwiftUI

struct CommentsSection: View {
    let comments: [Comment]
    let postId: String
    let toggleCommentLike: (String) async -> Void
    let checkCommentLikeStatus: (String) async -> Bool
    let currentUserId: String
    let postOwnerId: String
    let deleteComment: (String) async -> Void
    
    @State private var likedComments: [String: Bool] = [:]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Comments")
                .font(.headline)
            
            if comments.isEmpty {
                Text("No comments yet.")
                    .foregroundColor(.gray)
            } else {
                ForEach(comments) { comment in
                    VStack(alignment: .leading) {
                        Text("\(comment.username):")
                            .font(.subheadline)
                            .foregroundColor(.blue)
                        Text(comment.text)
                            .font(.body)
                        
                        HStack {
                            Button(action: {
                                Task {
                                    await toggleCommentLike(comment.id)
                                    await refreshLikeStatus(for: comment.id)
                                }
                            }) {
                                HStack {
                                    Image(systemName: likedComments[comment.id] == true ? "heart.fill" : "heart")
                                        .foregroundColor(likedComments[comment.id] == true ? .red : .gray)
                                    Text("\(comment.likes)")
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                }
                            }
                            
                            Spacer()
                            
                            if currentUserId == comment.userId || currentUserId == postOwnerId {
                                Button(role: .destructive) {
                                    Task {
                                        await deleteComment(comment.id)
                                    }
                                } label: {
                                    Image(systemName: "trash")
                                        .foregroundColor(.red)
                                }
                            }
                        }
                        Divider()
                    }
                    .task {
                        await refreshLikeStatus(for: comment.id)
                    }
                }
            }
        }
    }
    
    private func refreshLikeStatus(for commentId: String) async {
        let isLiked = await checkCommentLikeStatus(commentId)
        DispatchQueue.main.async {
            likedComments[commentId] = isLiked
        }
    }
}
