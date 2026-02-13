//
//  UploadFromDeviceView.swift
//  ArtShare
//
//  Created by Huseyin D. Ulu (RIT Student) on 08.12.2024..
//


import SwiftUI
import PhotosUI

struct UploadFromDeviceView: View {
    @State private var selectedImage: UIImage? = nil
    @State private var isPickerPresented = false
    @State private var title: String = ""
    @State private var description: String = ""
    @State private var tagInput: String = ""

    var body: some View {
        VStack(spacing: 20) {
            if let selectedImage = selectedImage {
                Image(uiImage: selectedImage)
                    .resizable()
                    .scaledToFit()
                    .frame(height: 200)
                    .cornerRadius(10)
            } else {
                Button("Select Image") {
                    isPickerPresented = true
                }
                .font(.headline)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.gray.opacity(0.2))
                .cornerRadius(10)
            }

            TextField("Title", text: $title)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.horizontal)

            TextField("Description", text: $description)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.horizontal)

            TextField("Tags (separate by commas)", text: $tagInput)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.horizontal)

            Button("Upload") {
                uploadArtwork()
            }
            .disabled(selectedImage == nil || title.isEmpty)
            .font(.headline)
            .frame(maxWidth: .infinity)
            .padding()
            .background(selectedImage != nil && !title.isEmpty ? Color.blue : Color.gray)
            .cornerRadius(10)
            .foregroundColor(.white)

            Spacer()
        }
        .padding()
        .sheet(isPresented: $isPickerPresented) {
            ImagePicker(selectedImage: $selectedImage)
        }
    }

    private func uploadArtwork() {
        let tags = tagInput.split(separator: ",").map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
        print("Uploading artwork titled: \(title) with tags: \(tags)")
    }
}
