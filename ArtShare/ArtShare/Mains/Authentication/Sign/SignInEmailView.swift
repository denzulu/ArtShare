//
//  SignInEmailView.swift
//  ArtShare
//
//  Created by Huseyin D. Ulu (RIT Student) on 03.12.2024..
//

import SwiftUI

final class SignInEmailViewModel: ObservableObject{
    @Published var email = ""
    @Published var password = ""
    
    func signIn() {
        guard !email.isEmpty, !password.isEmpty else{
            print("No Email or Password found")
            return
        }
        
        Task{
            do{
                let returnedUserData = try await AuthenticationManager.shared.signInUser(email: email, password: password)
                print("Success")
                print(returnedUserData)
            } catch{
                print("Error \(error)")
            }
        }
    }
}

struct SignInEmailView: View {
    @StateObject private var viewModel = SignInEmailViewModel()
    @Binding var showSignInView: Bool
    
    var body: some View {
        VStack{
            TextField("Email", text: $viewModel.email)
                .padding()
                .background(Color.gray.opacity(0.4))
                .cornerRadius(10)
            
            SecureField("Password", text: $viewModel.password)
                .padding()
                .background(Color.gray.opacity(0.4))
                .cornerRadius(10)
            
            Button{
                viewModel.signIn()
                showSignInView = false
            }label: {
                Text("Sign In With Email")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(height: 55)
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)
                    .cornerRadius(10)
            }
            Spacer()
            
            Text("Test Accounts:")
                .font(.headline)
                .padding(.top)
            Text("aaa@gmail.com")
            Text("bbb@gmail.com")
            Text("Passwords: 123456")
                .italic()
                .padding(.bottom)
            
        }
        .padding()
        .navigationTitle("Sign In With Email")
    }
}

#Preview {
    NavigationStack{
        SignInEmailView(showSignInView: .constant(false))
    }
}
