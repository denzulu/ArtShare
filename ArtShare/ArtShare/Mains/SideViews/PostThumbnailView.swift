//
//  PostThumbnailView.swift
//  ArtShare
//
//  Created by Huseyin D. Ulu (RIT Student) on 06.12.2024..
//
import SwiftUI

struct PostThumbnailView: View {
    var post: Post


    var body: some View {
        ZStack {
            if let url = post.imageUrl, let imageUrl = URL(string: url) {
                AsyncImage(url: imageUrl) { image in
                    image
                        .resizable()
                        .scaledToFill()
                        .frame(width: 125, height: 125)
                        .clipped()
                        
                } placeholder: {
                    Rectangle()
                        .fill(Color.gray.opacity(0.3))
                        .frame(width: 125, height: 125)
                        
                }
            } else {
                Rectangle()
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: 125, height: 125)
                    
            }
        }
    }
}

