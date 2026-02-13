//
//  SignInEmailView.swift
//  ArtShare
//
//  Created by Huseyin D. Ulu (RIT Student) on 03.12.2024..
//

import SwiftUI

final class SignUpEmailViewModel: ObservableObject{
    @Published var email = ""
    @Published var password = ""
    @Published var name = ""
    
    func signUp() async throws{
        guard !email.isEmpty, !password.isEmpty, !name.isEmpty else{
            print("No Email or Password or Name found")
            return
        }
        let authDataResult = try await AuthenticationManager.shared.createUser(email: email, password: password)
        try await UserManager.shared.createNewUser(auth: authDataResult, name: name)
       
    }
}

struct SignUpEmailView: View {
    @StateObject private var viewModel = SignUpEmailViewModel()
    @Binding var showSignInView: Bool
    @State private var errorMessage: String = ""

    
    var body: some View {
        VStack{
            TextField("Name", text: $viewModel.name)
                .padding()
                .background(Color.gray.opacity(0.4))
                .cornerRadius(10)
            
            TextField("Email", text: $viewModel.email)
                .padding()
                .background(Color.gray.opacity(0.4))
                .cornerRadius(10)
            
            SecureField("Password", text: $viewModel.password)
                .padding()
                .background(Color.gray.opacity(0.4))
                .cornerRadius(10)
            if !errorMessage.isEmpty {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .padding(.top, 5)
            }
            Button{
                Task {
                    do {
                        guard !viewModel.name.isEmpty else {
                            errorMessage = "Name is required."
                            return
                        }
                        guard !viewModel.email.isEmpty else {
                            errorMessage = "Email is required."
                            return
                        }
                        guard !viewModel.password.isEmpty else {
                            errorMessage = "Password is required."
                            return
                        }
                        
                        errorMessage = ""
                        
                        try await viewModel.signUp()
                        showSignInView = false
                        return
                    } catch {
                        errorMessage = "Sign-up failed: \(error.localizedDescription)"
                    }
                }
            }label: {
                Text("Sign Up With Email")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(height: 55)
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)
                    .cornerRadius(10)
            }
            Spacer()
            
        }
        .padding()
        .navigationTitle("Sign Up With Email")
    }
}

#Preview {
    NavigationStack{
        SignUpEmailView(showSignInView: .constant(false))
    }
}
