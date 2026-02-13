//
//  UserInfoView.swift
//  ArtShare
//
//  Created by Huseyin D. Ulu (RIT Student) on 07.12.2024..
//

import SwiftUI


struct UserInfoView: View {
    let user: DbUser
    let postCount: Int

    var body: some View {
        VStack {
            if let photoUrl = user.photoUrl, let url = URL(string: photoUrl) {
                AsyncImage(url: url) { image in
                    image
                        .resizable()
                        .scaledToFill()
                } placeholder: {
                    Image(systemName: "person.crop.circle.fill")
                        .resizable()
                        .scaledToFit()
                }
                .frame(width: 80, height: 80)
                .clipShape(Circle())
            } else {
                Image(systemName: "person.crop.circle.fill")
                    .resizable()
                    .frame(width: 80, height: 80)
                    .foregroundColor(.gray)
            }

            Text(user.name)
                .font(.title2)
                .fontWeight(.bold)

            if let bio = user.bio {
                Text(bio)
                    .font(.body)
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 20)
            }

            Text("\(postCount) Posts")
                .font(.caption)
                .foregroundColor(.gray)
        }
        .padding(.top, 10)
    }
}
