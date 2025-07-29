//
//  APIIntegrationStatus.swift
//  PawsInUs
//
//  Shows the status of API integration
//

import SwiftUI

struct APIIntegrationStatus: View {
    @State private var isBackendRunning = false
    @State private var lastAnimalCreated: String? = nil
    @State private var isChecking = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("API Integration Status")
                .font(.headline)
            
            // Backend Status
            HStack {
                Image(systemName: isBackendRunning ? "checkmark.circle.fill" : "xmark.circle.fill")
                    .foregroundColor(isBackendRunning ? .green : .red)
                Text("Live API (https://pawsnus.com)")
                    .font(.system(.body, design: .monospaced))
            }
            
            // Last Created Animal
            if let lastAnimal = lastAnimalCreated {
                HStack {
                    Image(systemName: "pawprint.fill")
                        .foregroundColor(.blue)
                    Text("Last created: \(lastAnimal)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            Button(action: checkBackendStatus) {
                HStack {
                    if isChecking {
                        ProgressView()
                            .scaleEffect(0.8)
                    } else {
                        Image(systemName: "arrow.clockwise")
                    }
                    Text("Check Status")
                }
            }
            .disabled(isChecking)
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
        .onAppear {
            checkBackendStatus()
        }
    }
    
    private func checkBackendStatus() {
        isChecking = true
        
        Task {
            // Check if backend is running
            do {
                let animalsResponse = try await LocalAPIClient.shared.getAnimals(limit: 1)
                await MainActor.run {
                    isBackendRunning = true
                    if let firstAnimal = animalsResponse.animals.first {
                        lastAnimalCreated = "\(firstAnimal.name) (ID: \(firstAnimal.id.prefix(8))...)"
                    }
                }
            } catch {
                await MainActor.run {
                    isBackendRunning = false
                    // Backend check failed
                }
            }
            
            await MainActor.run {
                isChecking = false
            }
        }
    }
}

// Preview
struct APIIntegrationStatus_Previews: PreviewProvider {
    static var previews: some View {
        APIIntegrationStatus()
            .padding()
    }
}