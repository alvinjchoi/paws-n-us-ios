//
//  AuthView.swift
//  Pawsinus
//
//  Created by Assistant on 1/27/25.
//

import SwiftUI
import Supabase

struct AuthView: View {
    @Environment(\.injected) private var diContainer
    @Environment(\.dismiss) private var dismiss
    @State private var showEmailSignIn = false
    
    var body: some View {
        NavigationStack {
            VStack {
                // Close button
                HStack {
                    Spacer()
                    Button(action: {
                        dismiss()
                    }) {
                        Image(systemName: "xmark")
                            .font(.system(size: 24))
                            .foregroundColor(.black)
                    }
                    .padding()
                }
                
                Spacer()
                    .frame(height: 60)
                
                // Title
                VStack(alignment: .leading, spacing: 8) {
                    Text("포인어스에서")
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(.black)
                    
                    Text("운명의 반려견을 만나보세요")
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(.black)
                }
                .padding(.horizontal, 30)
                .frame(maxWidth: .infinity, alignment: .leading)
                
                Spacer()
                
                // Sign in buttons
                VStack(spacing: 16) {
                    // Kakao login
                    Button(action: {
                        // Handle Kakao login
                    }) {
                        HStack {
                            Image(systemName: "message.fill")
                                .font(.system(size: 20))
                            Text("카카오로 계속하기")
                                .font(.system(size: 17, weight: .medium))
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(Color(red: 254/255, green: 229/255, blue: 0/255))
                        .foregroundColor(.black)
                        .cornerRadius(28)
                    }
                    
                    // Apple login
                    Button(action: {
                        // Handle Apple login
                    }) {
                        HStack {
                            Image(systemName: "apple.logo")
                                .font(.system(size: 20))
                            Text("Apple로 계속하기")
                                .font(.system(size: 17, weight: .medium))
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(Color.black)
                        .foregroundColor(.white)
                        .cornerRadius(28)
                    }
                    
                    // Email login
                    Button(action: {
                        showEmailSignIn = true
                    }) {
                        HStack {
                            Image(systemName: "pawprint.fill")
                                .font(.system(size: 20))
                            Text("이메일로 계속하기")
                                .font(.system(size: 17, weight: .medium))
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(Color.white)
                        .foregroundColor(.black)
                        .overlay(
                            RoundedRectangle(cornerRadius: 28)
                                .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                        )
                        .cornerRadius(28)
                    }
                    
                    // Phone login
                    Button(action: {
                        // Handle phone login
                    }) {
                        HStack {
                            Image(systemName: "phone.fill")
                                .font(.system(size: 20))
                            Text("휴대폰 번호로 계속하기")
                                .font(.system(size: 17, weight: .medium))
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(Color.white)
                        .foregroundColor(.black)
                        .overlay(
                            RoundedRectangle(cornerRadius: 28)
                                .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                        )
                        .cornerRadius(28)
                    }
                }
                .padding(.horizontal, 30)
                
                Spacer()
                    .frame(height: 40)
                
                // Footer links
                HStack(spacing: 20) {
                    Button("계정 찾기") {
                        // Handle find account
                    }
                    .font(.system(size: 14))
                    .foregroundColor(.gray)
                    
                    Text("|")
                        .font(.system(size: 14))
                        .foregroundColor(.gray.opacity(0.3))
                    
                    Button("비밀번호 찾기") {
                        // Handle find password
                    }
                    .font(.system(size: 14))
                    .foregroundColor(.gray)
                    
                    Text("|")
                        .font(.system(size: 14))
                        .foregroundColor(.gray.opacity(0.3))
                    
                    Button("문의하기") {
                        // Handle contact
                    }
                    .font(.system(size: 14))
                    .foregroundColor(.gray)
                }
                
                Spacer()
                    .frame(height: 40)
            }
            .background(Color.white)
            .navigationBarHidden(true)
            .sheet(isPresented: $showEmailSignIn) {
                EmailSignInView()
            }
        }
    }
}

struct EmailSignInView: View {
    @Environment(\.injected) private var diContainer
    @Environment(\.dismiss) private var dismiss
    @State private var email = ""
    @State private var magicLinkURL = ""
    @State private var isLoading = false
    @State private var showAlert = false
    @State private var alertMessage = ""
    @State private var emailSent = false
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                TextField("이메일 주소", text: $email)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .keyboardType(.emailAddress)
                    .textInputAutocapitalization(.never)
                    .disabled(emailSent)
                    .padding(.horizontal)
                    .padding(.top, 40)
                
                if emailSent {
                    VStack(spacing: 16) {
                        Text("이메일을 확인해주세요!")
                            .font(.headline)
                        
                        Text("로그인 링크가 \(email)로 전송되었습니다.")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                        
                        Divider()
                            .padding(.vertical)
                        
                        Text("링크가 작동하지 않나요?")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        Text("이메일에서 링크를 복사하여 아래에 붙여넣으세요:")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                        
                        TextField("매직 링크 URL", text: $magicLinkURL)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .textInputAutocapitalization(.never)
                            .autocorrectionDisabled()
                            .padding(.horizontal)
                        
                        Button(action: processMagicLink) {
                            if isLoading {
                                ProgressView()
                                    .tint(.white)
                            } else {
                                Text("로그인")
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 44)
                        .background(Color.orange)
                        .foregroundColor(.white)
                        .cornerRadius(22)
                        .disabled(isLoading || magicLinkURL.isEmpty)
                        .padding(.horizontal)
                    }
                    .padding()
                    
                    Button(action: { emailSent = false; email = ""; magicLinkURL = "" }) {
                        Text("다른 이메일로 시도")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.orange)
                    }
                } else {
                    Button(action: sendMagicLink) {
                        if isLoading {
                            ProgressView()
                                .tint(.white)
                        } else {
                            Text("로그인 링크 받기")
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(Color.orange)
                    .foregroundColor(.white)
                    .cornerRadius(25)
                    .disabled(isLoading || email.isEmpty)
                    .padding(.horizontal)
                }
                
                Spacer()
            }
            .navigationTitle("이메일로 로그인")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("취소") {
                        dismiss()
                    }
                }
            }
            .alert("알림", isPresented: $showAlert) {
                Button("확인", role: .cancel) { }
            } message: {
                Text(alertMessage)
            }
            .onOpenURL { url in
                // Handle the magic link callback
                Task {
                    do {
                        try await diContainer.supabaseClient.auth.session(from: url)
                        dismiss()
                    } catch {
                        alertMessage = "로그인에 실패했습니다. 다시 시도해주세요."
                        showAlert = true
                    }
                }
            }
        }
    }
    
    private func sendMagicLink() {
        guard !email.isEmpty else { return }
        
        isLoading = true
        
        Task {
            do {
                try await diContainer.interactors.authInteractor.signInWithOTP(email: email)
                
                await MainActor.run {
                    isLoading = false
                    emailSent = true
                }
            } catch {
                await MainActor.run {
                    isLoading = false
                    alertMessage = error.localizedDescription
                    showAlert = true
                }
            }
        }
    }
    
    private func processMagicLink() {
        guard !magicLinkURL.isEmpty else { return }
        
        isLoading = true
        
        Task {
            do {
                // Extract the token from the URL
                guard let url = URL(string: magicLinkURL) else {
                    throw NSError(domain: "Invalid URL", code: -1)
                }
                
                // Process the magic link
                try await diContainer.supabaseClient.auth.session(from: url)
                
                await MainActor.run {
                    isLoading = false
                    dismiss()
                }
            } catch {
                await MainActor.run {
                    isLoading = false
                    alertMessage = "로그인에 실패했습니다. URL을 확인해주세요."
                    showAlert = true
                }
            }
        }
    }
}

#Preview {
    AuthView()
        .inject(DIContainer(
            appState: AppState(),
            interactors: .stub,
            modelContainer: .stub,
            supabaseClient: SupabaseConfig.client
        ))
}