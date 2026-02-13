//
//  UserManager.swift
//  ArtShare
//
//  Created by Huseyin D. Ulu (RIT Student) on 05.12.2024..
//

import Foundation
import FirebaseFirestore

struct DbUser{
    let userId: String
    let name: String
    let photoUrl: String?
    let bio: String?
    let dateCreated: Date?
}



final class UserManager{
    
    static let shared = UserManager()
    private init(){
        
    }
    
    func createNewUser(auth: AuthDataResultModel, name: String? = nil, bio: String? = nil) async throws{
        var userData: [String:Any] = [
            "user_id": auth.uid,
            "date_created": Timestamp()
            
        ]
        if let name = name{
            userData["name"] = name
        }
        if let email = auth.email{
            userData["email"] = email
        }
        if let bio = bio {
            userData["bio"] = bio
        }

        if let photoUrl = auth.photoUrl{
            userData["photo_url"] = photoUrl
        }
        
        try await Firestore.firestore().collection("users").document(auth.uid).setData(userData, merge: false)
    }
    
    func getUser(userId: String) async throws -> DbUser{
        let snap = try await Firestore.firestore().collection("users").document(userId).getDocument()
        
        guard let data = snap.data(), let userId = data["user_id"] as? String else{
            throw URLError(.badURL)
        }
        
        let name = data["name"] as? String ?? "No name"
        let photoUrl = data["photo_url"] as? String
        let dateCreated = data["date_created"] as? Date
        let bio = data["bio"] as? String

        
        return DbUser(userId: userId,name: name , photoUrl: photoUrl, bio: bio, dateCreated: dateCreated)
    }
    
    func updateProfileImage(userId: String, newPhotoUrl: String) async throws {
            try await Firestore.firestore()
            .collection("users").document(userId).updateData(["photo_url": newPhotoUrl])
        }

    
    func updateUserName(userId: String, newName: String) async throws {
        try await Firestore.firestore()
            .collection("users")
            .document(userId)
            .updateData(["name": newName])
    }
    
    func updateUserBio(userId: String, newBio: String) async throws {
        try await Firestore.firestore()
            .collection("users")
            .document(userId)
            .updateData(["bio": newBio])
    }
    
    func deletePost(postId: String) async throws {
        try await Firestore.firestore()
            .collection("posts")
            .document(postId)
            .delete()
    }
    
    func updatePostLikes(postId: String, increment: Bool) async throws {
        let incrementValue = increment ? 1 : -1
        try await Firestore.firestore()
            .collection("posts")
            .document(postId)
            .updateData(["likes": FieldValue.increment(Int64(incrementValue))])
    }
    
    func updateUserPhotoUrl(userId: String, photoUrl: String) async throws {
        try await Firestore.firestore()
            .collection("users")
            .document(userId)
            .updateData(["photo_url": photoUrl])
    }


}
