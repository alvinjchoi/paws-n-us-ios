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
    @State private var otp = ""
    @State private var isLoading = false
    @State private var showAlert = false
    @State private var alertMessage = ""
    @State private var showOTPField = false
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                TextField("이메일 주소", text: $email)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .keyboardType(.emailAddress)
                    .textInputAutocapitalization(.never)
                    .disabled(showOTPField)
                    .padding(.horizontal)
                    .padding(.top, 40)
                
                if showOTPField {
                    TextField("인증 코드 6자리", text: $otp)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .keyboardType(.numberPad)
                        .padding(.horizontal)
                    
                    Button(action: verifyOTP) {
                        if isLoading {
                            ProgressView()
                                .tint(.white)
                        } else {
                            Text("인증하기")
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(Color.orange)
                    .foregroundColor(.white)
                    .cornerRadius(25)
                    .disabled(isLoading || otp.count != 6)
                    .padding(.horizontal)
                    
                    Button(action: { showOTPField = false; otp = "" }) {
                        Text("이메일 다시 입력")
                            .font(.system(size: 14))
                            .foregroundColor(.gray)
                    }
                } else {
                    Button(action: sendOTP) {
                        if isLoading {
                            ProgressView()
                                .tint(.white)
                        } else {
                            Text("인증 코드 받기")
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
            .alert("인증", isPresented: $showAlert) {
                Button("확인", role: .cancel) { }
            } message: {
                Text(alertMessage)
            }
        }
    }
    
    private func sendOTP() {
        guard !email.isEmpty else { return }
        
        isLoading = true
        
        Task {
            do {
                try await diContainer.interactors.authInteractor.signInWithOTP(email: email)
                
                await MainActor.run {
                    isLoading = false
                    showOTPField = true
                    alertMessage = "인증 코드가 이메일로 전송되었습니다."
                    showAlert = true
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
    
    private func verifyOTP() {
        guard otp.count == 6 else { return }
        
        isLoading = true
        
        Task {
            do {
                try await diContainer.interactors.authInteractor.verifyOTP(email: email, token: otp)
                
                await MainActor.run {
                    isLoading = false
                    dismiss()
                }
            } catch {
                await MainActor.run {
                    isLoading = false
                    alertMessage = "인증 코드가 올바르지 않습니다. 다시 시도해주세요."
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