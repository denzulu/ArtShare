//
//  GalleryView.swift
//  ArtShare
//
//  Created by Huseyin D. Ulu (RIT Student) on 05.12.2024..
//

import SwiftUI
import FirebaseFirestore
import FirebaseAuth

@MainActor
final class GalleryViewModel: ObservableObject {
    @Published var posts: [Post] = []
    @Published var filteredPosts: [Post] = []
    @Published var selectedFilter: String = "All"
    @Published var sortBy: String = "Date"
    @Published var searchText: String = ""

    func fetchPosts() async {
        do {
            let snapshot = try await Firestore.firestore()
                .collection("posts")
                .order(by: "date_created", descending: true)
                .getDocuments()
            
            var newPosts: [Post] = []
            for doc in snapshot.documents {
                let data = doc.data()
                let title = data["title"] as? String ?? ""
                let description = data["description"] as? String ?? ""
                let imageUrl = data["image_url"] as? String ?? ""
                let userId = data["user_id"] as? String ?? "unknown"
                let timestamp = data["date_created"] as? Timestamp ?? Timestamp()
                let tags = data["tags"] as? [String] ?? []
                let likes = data["likes"] as? Int ?? 0

                let username = await fetchUsername(for: userId)

                let post = Post(
                    id: doc.documentID,
                    title: title,
                    description: description,
                    imageUrl: imageUrl,
                    userId: userId,
                    timestamp: timestamp,
                    username: username,
                    tags: tags,
                    likes: likes
                )
                newPosts.append(post)
            }
            
            self.posts = newPosts
            applyFiltersAndSorting()
        } catch {
            print("Error fetching posts: \(error)")
        }
    }

    func applyFiltersAndSorting() {
        var filtered = posts

        if !searchText.isEmpty {
            filtered = filtered.filter { post in
                post.title.localizedCaseInsensitiveContains(searchText) ||
                post.tags.contains { $0.localizedCaseInsensitiveContains(searchText) }
            }
        }

        if sortBy == "Date" {
            filteredPosts = filtered.sorted { $0.timestamp.dateValue() > $1.timestamp.dateValue() }
        } else if sortBy == "Likes" {
            filteredPosts = filtered.sorted { $0.likes > $1.likes }
        }
    }

    private func fetchUsername(for userId: String) async -> String {
        do {
            let userSnapshot = try await Firestore.firestore().collection("users").document(userId).getDocument()
            if let userData = userSnapshot.data(), let username = userData["name"] as? String {
                return username
            }
        } catch {
            print("Error fetching username: \(error)")
        }
        return "Unknown User"
    }
}

struct GalleryView: View {
    @StateObject private var viewModel = GalleryViewModel()
    @State private var isFilterPanelVisible: Bool = false

    var body: some View {
        NavigationView {
            VStack {
                // Filtre Panelini Göster/Gizle Düğmesi
                HStack {
                    Button(action: {
                        withAnimation {
                            isFilterPanelVisible.toggle()
                        }
                    }) {
                        Text("Filters")
                            .font(.headline)
                            .padding(.horizontal)
                            .padding(.vertical, 8)
                            .background(Color.blue.opacity(0.1))
                            .foregroundColor(.blue)
                            .cornerRadius(8)
                    }

                    Spacer()
                }
                .padding([.top, .horizontal])

                // Filtre Paneli
                if isFilterPanelVisible {
                    VStack(spacing: 10) {
                        // Sıralama
                        Picker("Sort By", selection: $viewModel.sortBy) {
                            Text("Date").tag("Date")
                            Text("Likes").tag("Likes")
                        }
                        .pickerStyle(SegmentedPickerStyle())
                        .onChange(of: viewModel.sortBy) {
                            viewModel.applyFiltersAndSorting()
                        }

                        // Arama Alanı
                        TextField("Search by title or tag...", text: $viewModel.searchText)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .padding(.horizontal)
                            .onChange(of: viewModel.searchText) {                                viewModel.applyFiltersAndSorting()
                            }
                    }
                    .padding()
                    .background(Color(UIColor.secondarySystemBackground))
                    .cornerRadius(10)
                    .shadow(radius: 5)
                }

                // Gönderi Listesi
                List(viewModel.filteredPosts, id: \.id) { post in
                    NavigationLink(destination: PostDetailView(post: post)) {
                        PostView(post: post)
                    }
                }
                .listStyle(PlainListStyle())
            }
            .task {
                await viewModel.fetchPosts()
            }
        }
    }
}




#Preview {
    GalleryView()
}
