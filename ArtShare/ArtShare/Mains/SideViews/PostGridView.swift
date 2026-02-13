//
//  PostGridView.swift
//  ArtShare
//
//  Created by Huseyin D. Ulu (RIT Student) on 07.12.2024..
//

import SwiftUI

struct PostGridView: View {
    let posts: [Post]
    let onDelete: (Post) -> Void

    var body: some View {
        ScrollView {
            LazyVGrid(
                columns: Array(repeating: GridItem(.flexible(), spacing: 5), count: 3),
                spacing: 5
            ) {
                ForEach(posts, id: \.id) { post in
                    NavigationLink(destination: PostDetailView(post: post)) {
                        PostThumbnailView(post: post)
                    }
                    .contextMenu {
                        Button(role: .destructive) {
                            onDelete(post)
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
