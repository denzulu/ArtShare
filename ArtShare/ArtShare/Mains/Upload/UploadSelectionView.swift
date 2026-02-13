//
//  UploadSelectionView.swift
//  ArtShare
//
//  Created by Huseyin D. Ulu (RIT Student) on 08.12.2024..
//


import SwiftUI

struct UploadSelectionView: View {
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                NavigationLink(destination: UploadView()) {
                    Text("Upload via URL")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }

                NavigationLink(destination: UploadFromDeviceView()) {
                    Text("Upload from Device")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                Spacer()
            }
            .padding()
            .navigationTitle("Upload Options")
        }
    }
}
