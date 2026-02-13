//
//  AuthenticationView.swift
//  ArtShare
//
//  Created by Huseyin D. Ulu (RIT Student) on 03.12.2024..
//

import SwiftUI
import GoogleSignIn
import GoogleSignInSwift
import FirebaseAuth

struct GoogleSignInResultModel{
    let idToken: String
    let accessToken: String
}

@MainActor
final class AuthenticationViewModel: ObservableObject {
    func signInGoogle(presentingViewController: UIViewController) async throws {
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            GIDSignIn.sharedInstance.signIn(withPresenting: presentingViewController) { signInResult, error in
                if let error = error {
                    continuation.resume(throwing: error)
                    return
                }
                
                guard let signInResult = signInResult,
                      let idToken = signInResult.user.idToken?.tokenString else {
                    continuation.resume(throwing: URLError(.badServerResponse))
                    return
                }
                
                let accessToken = signInResult.user.accessToken.tokenString
                let tokens = GoogleSignInResultModel(idToken: idToken, accessToken: accessToken)
                
                Task {
                    do {
                        let authDataResult = try await AuthenticationManager.shared.signInWithGoogle(tokens: tokens)
                        try await UserManager.shared.createNewUser(auth: authDataResult)
                        continuation.resume()
                    } catch {
                        continuation.resume(throwing: error)
                    }
                }
            }
        }
    }
}


struct AuthenticationView: View {
    
    @StateObject private var viewModel = AuthenticationViewModel()
    @Binding var showSignInView: Bool
    
    var body: some View {
        VStack{
            NavigationLink{
                SignUpEmailView(showSignInView: $showSignInView)
            } label: {
                Text("Sign Up With Email")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(height: 55)
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)
                    .cornerRadius(10)
            }
            
            
            NavigationLink{
                SignInEmailView(showSignInView: $showSignInView)
            } label: {
                Text("Have an account? Sign In With Email")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(height: 55)
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)
                    .cornerRadius(10)
            }
            
            GoogleSignInButton(viewModel: GoogleSignInButtonViewModel(scheme: .light, style: .wide, state: .normal)) {
                Task {
                    do {
                        if let topVC = UIApplication.shared.getRootViewController() {
                            try await viewModel.signInGoogle(presentingViewController: topVC)
                            showSignInView = false
                        }
                    } catch {
                        print(error)
                    }
                }
            }
            
            
            Spacer()
        }
        .padding()
        .navigationTitle("ArtShare")
    }
    
}


extension UIApplication {
    func getRootViewController() -> UIViewController? {
        guard let windowScene = connectedScenes.first as? UIWindowScene,
              let rootVC = windowScene.windows.first?.rootViewController else {
            return nil
        }
        return rootVC
    }
}

#Preview{
    NavigationStack{
        AuthenticationView(showSignInView: .constant(false))
    }
}
