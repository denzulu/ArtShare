//
//  UploadView.swift
//  ArtShare
//
//  Created by Huseyin D. Ulu (RIT Student) on 05.12.2024..
//

import SwiftUI
import FirebaseStorage
import FirebaseFirestore
import FirebaseAuth

struct UploadView: View {
    @State private var title: String = ""
    @State private var description: String = ""
    @State private var imageUrl: String = "" // Image URL
    @State private var isUploading: Bool = false
    @State private var errorMessage: String = ""
    @State private var tags: String = ""


    var body: some View {
        VStack(spacing: 20) {
            TextField("Enter Title", text: $title)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.horizontal)

            TextField("Enter Description", text: $description)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.horizontal)

            TextField("Enter Image URL", text: $imageUrl)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.horizontal)
            
            TextField("Enter Tags (comma-separated)", text: $tags)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.horizontal)

            Button {
                Task {
                    await uploadPost()
                }
            } label: {
                Text("Upload")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(title.isEmpty || imageUrl.isEmpty ? Color.gray : Color.green)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .disabled(title.isEmpty || imageUrl.isEmpty)

            if isUploading {
                ProgressView("Uploading...")
            }

            if !errorMessage.isEmpty {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .font(.footnote)
            }

            Spacer()
        }
        .padding()
        .navigationTitle("Upload Artwork")
    }

    private func uploadPost() async {
        isUploading = true
        errorMessage = ""

        // Here you can directly save the URL you get (for now it's entered manually)
        let sampleImageUrl = imageUrl // You get this from the TextField

        // Save to Firestore
        do {
            try await saveMetadataToFirestore(imageUrl: sampleImageUrl)
            errorMessage = "Upload successful!"
        } catch {
            errorMessage = "Upload failed: \(error.localizedDescription)"
        }

        isUploading = false
    }

    private func saveMetadataToFirestore(imageUrl: String) async throws {
        let tagArray = tags.split(separator: ",").map { $0.trimmingCharacters(in: .whitespaces) }
        let postData: [String: Any] = [
            "title": title,
            "description": description,
            "image_url": imageUrl,  // Saving the URL instead of uploading an image
            "user_id": Auth.auth().currentUser?.uid ?? "unknown",
            "tags": tagArray,
            "date_created": Timestamp()
        ]

        try await Firestore.firestore().collection("posts").addDocument(data: postData)
    }
}


#Preview {
    UploadView()
}
