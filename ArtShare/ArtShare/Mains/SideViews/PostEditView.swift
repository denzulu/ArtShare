//
//  PostEditView.swift
//  ArtShare
//
//  Created by Huseyin D. Ulu (RIT Student) on 07.12.2024..
//

import SwiftUI

struct PostEditView: View {
    @Binding var title: String
    @Binding var description: String
    @Binding var tags: String 

    var onSave: () -> Void

    var body: some View {
        Form {
            Section(header: Text("Title")) {
                TextField("Enter title", text: $title)
            }

            Section(header: Text("Description")) {
                TextField("Enter description", text: $description)
            }

            Section(header: Text("Tags (comma-separated)")) {
                TextField("Enter tags", text: $tags)
            }

            Button("Save Changes") {
                onSave()
            }
            .frame(maxWidth: .infinity, alignment: .center)
            .padding()
            .foregroundColor(.white)
            .background(Color.blue)
            .cornerRadius(8)
        }
        .navigationTitle("Edit Post")
    }
}
