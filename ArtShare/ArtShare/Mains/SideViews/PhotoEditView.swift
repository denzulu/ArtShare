//
//  PhotoEditView.swift
//  ArtShare
//
//  Created by Huseyin D. Ulu (RIT Student) on 07.12.2024..
//

import SwiftUI

struct PhotoEditView: View {
    @Environment(\.dismiss) var dismiss
    @State private var photoUrl: String = ""
    var currentPhotoUrl: String?
    var onSave: (String) -> Void

    var body: some View {
        VStack(spacing: 20) {
            Text("Edit Profile Photo")
                .font(.title)
                .fontWeight(.bold)

            TextField("Enter photo URL", text: $photoUrl)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
                .onAppear {
                    if let currentPhotoUrl = currentPhotoUrl {
                        photoUrl = currentPhotoUrl
                    }
                }

            Button("Save") {
                guard !photoUrl.isEmpty else { return }
                onSave(photoUrl)
                dismiss()
            }
            .padding()
            .frame(maxWidth: .infinity)
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(8)
        }
        .padding()
    }
}
