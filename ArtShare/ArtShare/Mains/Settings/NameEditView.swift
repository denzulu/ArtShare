//
//  NameEditView.swift
//  ArtShare
//
//  Created by Huseyin D. Ulu (RIT Student) on 05.12.2024..
//

import SwiftUI

struct NameEditView: View {
    let user: DbUser
    var onSave: (String) -> Void
    
    @State private var newName: String = ""
    @State private var errorMessage: String = ""

    var body: some View {
        VStack(spacing: 20) {
            Text("Edit Name")
                .font(.title)
                .fontWeight(.bold)

            TextField("Enter new name", text: $newName)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
                .onAppear {
                    newName = user.name
                }

            if !errorMessage.isEmpty {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .font(.footnote)
            }

            Button {
                guard !newName.isEmpty else {
                    errorMessage = "Name cannot be empty."
                    return
                }
                errorMessage = ""
                onSave(newName)
            } label: {
                Text("Save")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(height: 55)
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)
                    .cornerRadius(10)
            }
        }
        .padding()
    }
}


