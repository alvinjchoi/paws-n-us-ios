//
//  AuthView.swift
//  Pawsinus
//
//  Created by Assistant on 1/27/25.
//

import SwiftUI
import Supabase
import Combine

struct AuthView: View {
    @Environment(\.injected) private var diContainer
    @Environment(\.dismiss) private var dismiss
    @State private var showEmailSignIn = false
    @State private var showPhoneSignIn = false
    
    var body: some View {
        NavigationView {
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
                    Text("포앤어스에서")
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
                        showPhoneSignIn = true
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
            .sheet(isPresented: $showPhoneSignIn) {
                PhoneSignInView()
            }
            .onReceive(diContainer.appState.updates(for: \.userData.isAuthenticated).removeDuplicates()) { isAuthenticated in
                if isAuthenticated {
                    // User is now authenticated, dismiss the auth view
                    dismiss()
                    // Also switch to profile tab
                    diContainer.appState[\.routing.selectedTab] = .profile
                }
            }
        }
    }
}

struct EmailSignInView: View {
    @Environment(\.injected) private var diContainer
    @Environment(\.dismiss) private var dismiss
    @State private var email = ""
    @State private var isLoading = false
    @State private var showAlert = false
    @State private var alertMessage = ""
    @State private var emailSent = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                TextField("이메일 주소", text: $email)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .keyboardType(.emailAddress)
                    .textInputAutocapitalization(.never)
                    .disabled(emailSent)
                    .padding(.horizontal)
                    .padding(.top, 40)
                
                if emailSent {
                    VStack(spacing: 20) {
                        Image(systemName: "envelope.fill")
                            .font(.system(size: 50))
                            .foregroundColor(.orange)
                        
                        Text("이메일을 확인해주세요!")
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        Text("로그인 링크가 \(email)로 전송되었습니다.")
                            .font(.body)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                        
                        Text("링크를 클릭하면 자동으로 Paws-N-Us 앱이 열립니다.")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                    .padding()
                    
                    Button(action: { emailSent = false; email = "" }) {
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
    
}

struct PhoneSignInView: View {
    @Environment(\.injected) private var diContainer
    @Environment(\.dismiss) private var dismiss
    @State private var phoneNumber = ""
    @State private var verificationCode = ""
    @State private var isLoading = false
    @State private var showAlert = false
    @State private var alertMessage = ""
    @State private var codeSent = false
    @State private var selectedCountryCode = "+82" // Korea default
    @State private var resendTimer = 60
    @State private var canResend = false
    
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                if !codeSent {
                    // Phone number input
                    VStack(alignment: .leading, spacing: 8) {
                        Text("휴대폰 번호")
                            .font(.headline)
                            .padding(.horizontal)
                        
                        HStack {
                            // Country code picker
                            Menu {
                                Button("+82 🇰🇷") { selectedCountryCode = "+82" }
                                Button("+1 🇺🇸") { selectedCountryCode = "+1" }
                                Button("+81 🇯🇵") { selectedCountryCode = "+81" }
                                Button("+86 🇨🇳") { selectedCountryCode = "+86" }
                            } label: {
                                HStack {
                                    Text(selectedCountryCode)
                                        .font(.system(size: 16))
                                    Image(systemName: "chevron.down")
                                        .font(.system(size: 12))
                                }
                                .padding(.horizontal, 12)
                                .padding(.vertical, 8)
                                .background(Color(.systemGray6))
                                .cornerRadius(8)
                            }
                            
                            TextField("01012345678", text: $phoneNumber)
                                .keyboardType(.phonePad)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                        }
                        .padding(.horizontal)
                        
                        Text("- 없이 숫자만 입력해주세요")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .padding(.horizontal)
                    }
                    .padding(.top, 40)
                    
                    Button(action: sendVerificationCode) {
                        if isLoading {
                            ProgressView()
                                .tint(.white)
                        } else {
                            Text("인증번호 받기")
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(Color.orange)
                    .foregroundColor(.white)
                    .cornerRadius(25)
                    .disabled(isLoading || phoneNumber.isEmpty)
                    .padding(.horizontal)
                } else {
                    // Verification code input
                    VStack(spacing: 20) {
                        Image(systemName: "message.fill")
                            .font(.system(size: 50))
                            .foregroundColor(.orange)
                        
                        Text("인증번호가 전송되었습니다")
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        Text("\(selectedCountryCode) \(phoneNumber)로 전송된\n6자리 인증번호를 입력해주세요")
                            .font(.body)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                        
                        TextField("000000", text: $verificationCode)
                            .keyboardType(.numberPad)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .multilineTextAlignment(.center)
                            .font(.system(size: 24, weight: .semibold))
                            .padding(.horizontal, 40)
                        
                        Button(action: verifyCode) {
                            if isLoading {
                                ProgressView()
                                    .tint(.white)
                            } else {
                                Text("확인")
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(Color.orange)
                        .foregroundColor(.white)
                        .cornerRadius(25)
                        .disabled(isLoading || verificationCode.count != 6)
                        .padding(.horizontal)
                        
                        if canResend {
                            Button(action: resendCode) {
                                Text("인증번호 다시 받기")
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundColor(.orange)
                            }
                        } else {
                            Text("\(resendTimer)초 후 다시 시도")
                                .font(.system(size: 14))
                                .foregroundColor(.secondary)
                        }
                        
                        Button(action: { 
                            codeSent = false
                            verificationCode = ""
                            resendTimer = 60
                            canResend = false
                        }) {
                            Text("번호 변경")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.gray)
                        }
                    }
                    .padding()
                }
                
                Spacer()
            }
            .navigationTitle("휴대폰으로 로그인")
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
            .onReceive(timer) { _ in
                if codeSent && resendTimer > 0 {
                    resendTimer -= 1
                    if resendTimer == 0 {
                        canResend = true
                    }
                }
            }
        }
    }
    
    private func sendVerificationCode() {
        guard !phoneNumber.isEmpty else { return }
        
        // Format phone number
        let fullPhoneNumber = "\(selectedCountryCode)\(phoneNumber)"
        
        isLoading = true
        
        Task {
            do {
                try await diContainer.supabaseClient.auth.signInWithOTP(
                    phone: fullPhoneNumber
                )
                
                await MainActor.run {
                    isLoading = false
                    codeSent = true
                    resendTimer = 60
                    canResend = false
                }
            } catch {
                await MainActor.run {
                    isLoading = false
                    alertMessage = "인증번호 전송에 실패했습니다: \(error.localizedDescription)"
                    showAlert = true
                }
            }
        }
    }
    
    private func verifyCode() {
        guard verificationCode.count == 6 else { return }
        
        let fullPhoneNumber = "\(selectedCountryCode)\(phoneNumber)"
        
        isLoading = true
        
        Task {
            do {
                try await diContainer.supabaseClient.auth.verifyOTP(
                    phone: fullPhoneNumber,
                    token: verificationCode,
                    type: .sms
                )
                
                await MainActor.run {
                    isLoading = false
                    // Authentication successful
                    // The parent AuthView will handle dismissing when it detects auth state change
                }
            } catch {
                await MainActor.run {
                    isLoading = false
                    alertMessage = "인증에 실패했습니다. 인증번호를 다시 확인해주세요."
                    showAlert = true
                }
            }
        }
    }
    
    private func resendCode() {
        guard canResend else { return }
        
        canResend = false
        resendTimer = 60
        sendVerificationCode()
    }
}

#Preview {
    AuthView()
        .inject(DIContainer(
            appState: AppState(),
            interactors: .stub,
            supabaseClient: SupabaseConfig.client
        ))
}