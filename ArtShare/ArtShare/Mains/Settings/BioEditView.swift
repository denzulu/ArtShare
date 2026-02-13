//
//  BioEditView.swift
//  ArtShare
//
//  Created by Huseyin D. Ulu (RIT Student) on 07.12.2024..
//
import SwiftUI

struct BioEditView: View {
    let user: DbUser
    var onSave: (String) -> Void

    @State private var newBio: String = ""
    @State private var errorMessage: String?

    var body: some View {
        VStack(spacing: 20) {
            Text("Edit Bio")
                .font(.title)
                .fontWeight(.bold)

            TextField("Enter new bio", text: $newBio)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
                .onAppear {
                    newBio = user.bio ?? ""
                }

            if let error = errorMessage {
                Text(error)
                    .foregroundColor(.red)
                    .font(.footnote)
            }

            Button("Save") {
                guard !newBio.isEmpty else {
                    errorMessage = "Bio cannot be empty."
                    return
                }
                onSave(newBio)
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
