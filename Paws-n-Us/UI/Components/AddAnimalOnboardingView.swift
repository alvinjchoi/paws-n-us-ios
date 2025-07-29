//
//  AddAnimalOnboardingView.swift
//  PawsInUs
//
//  Comprehensive animal onboarding flow for rescuers
//

import SwiftUI
import PhotosUI
import Supabase

// MARK: - Main Onboarding Flow
struct AddAnimalOnboardingView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel = AnimalOnboardingViewModel()
    @State private var showingError = false
    @State private var errorMessage = ""
    @State private var isPublishing = false
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(.systemBackground)
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Header with progress and actions
                    headerView
                    
                    // Content area
                    TabView(selection: $viewModel.currentStep) {
                        ForEach(OnboardingStep.allCases, id: \.self) { step in
                            stepContent(for: step)
                                .tag(step)
                        }
                    }
                    .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                    .animation(.easeInOut, value: viewModel.currentStep)
                    
                    // Bottom navigation
                    bottomNavigationView
                }
            }
        }
        .navigationBarHidden(true)
        .alert("Error", isPresented: $showingError) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(errorMessage)
        }
    }
    
    // MARK: - Header
    private var headerView: some View {
        VStack(spacing: 16) {
            HStack {
                Button("Save & exit") {
                    viewModel.saveDraft()
                    dismiss()
                }
                .font(.system(size: 16))
                .foregroundColor(.primary)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(Color(.systemGray6))
                .cornerRadius(20)
                
                Spacer()
                
                Button("Questions?") {
                    // Show help
                }
                .font(.system(size: 16))
                .foregroundColor(.primary)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(Color(.systemGray6))
                .cornerRadius(20)
            }
            .padding(.horizontal, 20)
            .padding(.top, 10)
            
            // Progress bar
            ProgressView(value: viewModel.progress)
                .progressViewStyle(LinearProgressViewStyle(tint: .black))
                .scaleEffect(x: 1, y: 2, anchor: .center)
                .padding(.horizontal, 20)
        }
    }
    
    // MARK: - Step Content
    @ViewBuilder
    private func stepContent(for step: OnboardingStep) -> some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                switch step {
                case .welcome:
                    WelcomeStepView()
                case .basicInfo:
                    BasicInfoStepView(viewModel: viewModel)
                case .photos:
                    PhotosStepView(viewModel: viewModel)
                case .characteristics:
                    CharacteristicsStepView(viewModel: viewModel)
                case .medical:
                    MedicalStepView(viewModel: viewModel)
                case .location:
                    LocationStepView(viewModel: viewModel)
                case .review:
                    ReviewStepView(viewModel: viewModel)
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 32)
        }
    }
    
    // MARK: - Bottom Navigation
    private var bottomNavigationView: some View {
        HStack {
            if viewModel.currentStep != .welcome {
                Button("Back") {
                    viewModel.goToPreviousStep()
                }
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.primary)
                .background(
                    Rectangle()
                        .frame(height: 1)
                        .foregroundColor(.primary)
                        .offset(y: 2),
                    alignment: .bottom
                )
            } else {
                Spacer()
            }
            
            Spacer()
            
            Button(viewModel.isLastStep ? (isPublishing ? "Publishing..." : "Publish") : "Next") {
                print("🔵 Button tapped - isLastStep: \(viewModel.isLastStep), canProceed: \(viewModel.canProceed), isPublishing: \(isPublishing)")
                if viewModel.isLastStep {
                    print("🔵 Starting publish process...")
                    isPublishing = true
                    Task {
                        do {
                            let animalId = try await viewModel.publishAnimal()
                            await MainActor.run {
                                // Successfully published animal
                                isPublishing = false
                                dismiss()
                            }
                        } catch {
                            await MainActor.run {
                                // Failed to publish animal
                                errorMessage = error.localizedDescription
                                showingError = true
                                isPublishing = false
                            }
                        }
                    }
                } else {
                    viewModel.goToNextStep()
                }
            }
            .font(.system(size: 16, weight: .medium))
            .foregroundColor(.white)
            .padding(.horizontal, 24)
            .padding(.vertical, 12)
            .background(viewModel.canProceed && !isPublishing ? Color.black : Color.gray)
            .cornerRadius(8)
            .disabled(!viewModel.canProceed || isPublishing)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .background(Color(.systemBackground))
    }
}

// MARK: - Onboarding Steps
enum OnboardingStep: Int, CaseIterable {
    case welcome = 0
    case basicInfo = 1
    case photos = 2
    case characteristics = 3
    case medical = 4
    case location = 5
    case review = 6
    
    var title: String {
        switch self {
        case .welcome: return "Welcome"
        case .basicInfo: return "Basic Information"
        case .photos: return "Photos"
        case .characteristics: return "Characteristics"
        case .medical: return "Health Info"
        case .location: return "Location"
        case .review: return "Review"
        }
    }
}

// MARK: - View Model
@MainActor
class AnimalOnboardingViewModel: ObservableObject {
    @Published var currentStep: OnboardingStep = .welcome
    @Published var animalData = AnimalDraftData()
    
    var progress: Double {
        return Double(currentStep.rawValue) / Double(OnboardingStep.allCases.count - 1)
    }
    
    var isLastStep: Bool {
        currentStep == OnboardingStep.allCases.last
    }
    
    var canProceed: Bool {
        let result: Bool
        switch currentStep {
        case .welcome:
            result = true
        case .basicInfo:
            result = !animalData.name.isEmpty && !animalData.species.isEmpty && (animalData.ageYears > 0 || animalData.ageMonths > 0)
        case .photos:
            result = animalData.photos.count >= 1
            // Photos step validation
        case .characteristics:
            result = !animalData.bio.isEmpty
        case .medical:
            result = !animalData.medicalStatus.isEmpty
        case .location:
            result = !animalData.location.isEmpty
        case .review:
            result = true
        }
        return result
    }
    
    func goToNextStep() {
        if let nextStep = OnboardingStep(rawValue: currentStep.rawValue + 1) {
            withAnimation {
                currentStep = nextStep
            }
        }
    }
    
    func goToPreviousStep() {
        if let previousStep = OnboardingStep(rawValue: currentStep.rawValue - 1) {
            withAnimation {
                currentStep = previousStep
            }
        }
    }
    
    func saveDraft() {
        // Save draft to local storage or database
        // Saving draft
    }
    
    func publishAnimal() async throws -> String {
        // Publishing animal with data
        
        // Convert age to total months
        let ageInMonths = animalData.ageYears * 12 + animalData.ageMonths
        
        // Map help types to API format
        let helpTypes = animalData.helpTypes.map { type in
            switch type {
            case "transport": return "Transport"
            case "temporary_care": return "Temporary Care"
            case "grooming": return "Grooming"
            default: return type
            }
        }
        
        // Get current user's auth token if available
        let authToken = try? await SupabaseConfig.client.auth.session.accessToken
        
        // Call the local API
        let response = try await LocalAPIClient.shared.createAnimal(
            name: animalData.name,
            species: animalData.species,
            breed: animalData.breed.isEmpty ? nil : animalData.breed,
            age: ageInMonths,
            gender: animalData.gender.isEmpty ? "male" : animalData.gender,
            size: animalData.size.isEmpty ? "medium" : animalData.size,
            bio: animalData.bio,
            traits: animalData.traits,
            energyLevel: "medium", // Default for now
            goodWithKids: false, // Default for now
            goodWithPets: false, // Default for now
            houseTrained: false, // Default for now
            location: animalData.location,
            specialNeeds: nil,
            isSpayedNeutered: animalData.isSpayedNeutered ?? false,
            medicalStatus: animalData.medicalStatus.isEmpty ? "healthy" : animalData.medicalStatus,
            medicalNotes: animalData.medicalNotes.isEmpty ? nil : animalData.medicalNotes,
            vaccinations: animalData.vaccinations.isEmpty ? nil : animalData.vaccinations,
            weight: animalData.weight > 0 ? animalData.weight : nil,
            adoptionFee: nil,
            rescueDate: Date(),
            rescueLocation: animalData.location,
            rescueStory: animalData.rescueStory.isEmpty ? nil : animalData.rescueStory,
            images: animalData.photos,
            helpNeeded: helpTypes,
            rescuerId: nil,
            authToken: authToken
        )
        
        // Animal published successfully
        return response.animal.id
    }
}

// MARK: - Data Model
struct AnimalDraftData {
    var name: String = ""
    var species: String = ""
    var breed: String = ""
    var ageYears: Int = 0
    var ageMonths: Int = 0
    
    var age: Int {
        return ageYears * 12 + ageMonths // Total age in months for API compatibility
    }
    var size: String = ""
    var gender: String = ""
    var photos: [UIImage] = []
    var bio: String = ""
    var traits: [String] = []
    var medicalStatus: String = ""
    var vaccinations: String = ""
    var isSpayedNeutered: Bool? = false
    var weight: Double = 0.0
    var medicalNotes: String = ""
    var location: String = ""
    var rescueStory: String = ""
    var helpTypes: [String] = []

    mutating func toggleHelpType(_ type: String) {
        if helpTypes.contains(type) {
            helpTypes.removeAll { $0 == type }
        } else {
            helpTypes.append(type)
        }
    }
}

// MARK: - Welcome Step
struct WelcomeStepView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            VStack(alignment: .leading, spacing: 12) {
                Text("새로운 동물을\n보호 목록에 추가해주세요")
                    .font(.system(size: 32, weight: .semibold))
                    .lineLimit(nil)
                
                Text("구조된 동물의 정보를 단계별로 입력하여 입양을 위한 프로필을 만들어보세요.")
                    .font(.system(size: 18))
                    .foregroundColor(.secondary)
                    .lineSpacing(4)
            }
            
            Spacer()
                .frame(height: 40)
            
            // Features list
            VStack(alignment: .leading, spacing: 20) {
                FeatureRow(icon: "camera.fill", title: "사진 업로드", description: "동물의 매력적인 사진들을 추가하세요")
                FeatureRow(icon: "heart.fill", title: "상세 정보", description: "성격, 건강상태, 특징을 기록하세요")
                FeatureRow(icon: "location.fill", title: "위치 정보", description: "구조 위치와 현재 보호소를 설정하세요")
            }
            
            Spacer()
        }
    }
}

struct FeatureRow: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundColor(.blue)
                .frame(width: 24)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 16, weight: .medium))
                Text(description)
                    .font(.system(size: 14))
                    .foregroundColor(.secondary)
            }
        }
    }
}

