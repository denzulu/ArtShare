//
//  PostView.swift
//  ArtShare
//
//  Created by Huseyin D. Ulu (RIT Student) on 07.12.2024..
//
import SwiftUI
import FirebaseFirestore


struct PostView: View {
    var post: Post

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(post.title)
                .font(.headline)
                .fontWeight(.bold)

            ZStack(alignment: .topTrailing) {
                if let url = post.imageUrl, let imageUrl = URL(string: url) {
                    AsyncImage(url: imageUrl) { image in
                        image.resizable()
                            .scaledToFit()
                            .frame(height: 150)
                            .cornerRadius(10)
                    } placeholder: {
                        ProgressView()
                            .frame(height: 150)
                    }
                }

                if !post.tags.isEmpty {
                    Text(post.tags.joined(separator: ", "))
                        .font(.caption)
                        .foregroundColor(.white)
                        .padding(5)
                        .background(Color.black.opacity(0.7))
                        .cornerRadius(5)
                        .padding(5)
                }
            }

            HStack {
                Text(post.username)
                    .font(.subheadline)
                    .foregroundColor(.secondary)

                Spacer()

                Text(post.timestampFormatted)
                    .font(.caption)
                    .foregroundColor(.gray)
            }
        }
        .padding(.vertical, 10)
    }
}

struct Post {
    var id: String
    var title: String
    var description: String
    var imageUrl: String?
    var userId: String
    var timestamp: Timestamp
    var username: String
    var tags: [String]
    var likes: Int


    var timestampFormatted: String {
        let date = timestamp.dateValue()
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}
