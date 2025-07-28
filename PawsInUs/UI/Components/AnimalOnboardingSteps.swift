import SwiftUI
import PhotosUI

// MARK: - Basic Info Step
struct BasicInfoStepView: View {
    @ObservedObject var viewModel: AnimalOnboardingViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 32) {
            Text("기본 정보")
                .font(.system(size: 28, weight: .bold))
            
            VStack(alignment: .leading, spacing: 24) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("이름 *")
                        .font(.system(size: 16, weight: .medium))
                    TextField("예: 바둑이", text: $viewModel.animalData.name)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("동물 종류 *")
                        .font(.system(size: 16, weight: .medium))
                    Picker("종류", selection: $viewModel.animalData.species) {
                        Text("선택").tag("")
                        Text("강아지").tag("dog")
                        Text("고양이").tag("cat")
                    }
                    .pickerStyle(SegmentedPickerStyle())
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("나이 *")
                        .font(.system(size: 16, weight: .medium))
                    
                    HStack(spacing: 16) {
                        // Years picker
                        VStack(spacing: 4) {
                            Text("년")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.secondary)
                            
                            Picker("Years", selection: $viewModel.animalData.ageYears) {
                                ForEach(0...20, id: \.self) { year in
                                    Text("\(year)")
                                        .tag(year)
                                }
                            }
                            .pickerStyle(WheelPickerStyle())
                            .frame(width: 80, height: 120)
                            .clipped()
                        }
                        
                        // Months picker
                        VStack(spacing: 4) {
                            Text("개월")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.secondary)
                            
                            Picker("Months", selection: $viewModel.animalData.ageMonths) {
                                ForEach(0...11, id: \.self) { month in
                                    Text("\(month)")
                                        .tag(month)
                                }
                            }
                            .pickerStyle(WheelPickerStyle())
                            .frame(width: 80, height: 120)
                            .clipped()
                        }
                        
                        Spacer()
                    }
                    .padding(.vertical, 8)
                    .background(Color(.systemGray6))
                    .cornerRadius(8)
                }
            }
            
            Spacer()
        }
        .padding()
    }
}

// MARK: - Photos Step
struct PhotosStepView: View {
    @ObservedObject var viewModel: AnimalOnboardingViewModel
    
    var body: some View {
        if #available(iOS 16.0, *) {
            PhotosStepViewModern(viewModel: viewModel)
        } else {
            PhotosStepViewLegacy(viewModel: viewModel)
        }
    }
}

@available(iOS 16.0, *)
struct PhotosStepViewModern: View {
    @ObservedObject var viewModel: AnimalOnboardingViewModel
    @State private var selectedImages: [PhotosPickerItem] = []
    
    var body: some View {
        VStack(alignment: .leading, spacing: 32) {
            Text("📷 사진 업로드")
                .font(.system(size: 28, weight: .bold))
            
            Text("동물의 매력적인 사진들을 추가해주세요. 최소 1장이 필요합니다.")
                .font(.system(size: 16))
                .foregroundColor(.secondary)
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), spacing: 12) {
                ForEach(Array(viewModel.animalData.photos.enumerated()), id: \.offset) { index, image in
                    ZStack(alignment: .topTrailing) {
                        Image(uiImage: image)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(height: 100)
                            .clipped()
                            .cornerRadius(8)
                        
                        Button(action: {
                            viewModel.animalData.photos.remove(at: index)
                        }) {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.white)
                                .background(Color.black.opacity(0.6))
                                .clipShape(Circle())
                        }
                        .padding(4)
                    }
                }
                
                if viewModel.animalData.photos.count < 10 {
                    PhotosPicker(
                        selection: $selectedImages,
                        maxSelectionCount: 10 - viewModel.animalData.photos.count,
                        matching: .images
                    ) {
                        VStack {
                            Image(systemName: "plus")
                                .font(.system(size: 24))
                                .foregroundColor(.gray)
                            Text("사진 추가")
                                .font(.system(size: 12))
                                .foregroundColor(.gray)
                        }
                        .frame(height: 100)
                        .frame(maxWidth: .infinity)
                        .background(Color(.systemGray6))
                        .cornerRadius(8)
                    }
                    .onChange(of: selectedImages) { items in
                        Task {
                            await loadSelectedImages(items)
                        }
                    }
                }
            }
            
            Spacer()
        }
        .padding()
    }
    
    private func loadSelectedImages(_ items: [PhotosPickerItem]) async {
        for item in items {
            if let data = try? await item.loadTransferable(type: Data.self),
               let image = UIImage(data: data) {
                await MainActor.run {
                    viewModel.animalData.photos.append(image)
                }
            }
        }
        // Clear selection after loading
        await MainActor.run {
            selectedImages = []
        }
    }
}

struct PhotosStepViewLegacy: View {
    @ObservedObject var viewModel: AnimalOnboardingViewModel
    @State private var showingImagePicker = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 32) {
            Text("📷 사진 업로드")
                .font(.system(size: 28, weight: .bold))
            
            Text("동물의 매력적인 사진들을 추가해주세요. 최소 1장이 필요합니다.")
                .font(.system(size: 16))
                .foregroundColor(.secondary)
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), spacing: 12) {
                ForEach(Array(viewModel.animalData.photos.enumerated()), id: \.offset) { index, image in
                    ZStack(alignment: .topTrailing) {
                        Image(uiImage: image)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(height: 100)
                            .clipped()
                            .cornerRadius(8)
                        
                        Button(action: {
                            viewModel.animalData.photos.remove(at: index)
                        }) {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.white)
                                .background(Color.black.opacity(0.6))
                                .clipShape(Circle())
                        }
                        .padding(4)
                    }
                }
                
                if viewModel.animalData.photos.count < 10 {
                    Button(action: {
                        showingImagePicker = true
                    }) {
                        VStack {
                            Image(systemName: "plus")
                                .font(.system(size: 24))
                                .foregroundColor(.gray)
                            Text("사진 추가")
                                .font(.system(size: 12))
                                .foregroundColor(.gray)
                        }
                        .frame(height: 100)
                        .frame(maxWidth: .infinity)
                        .background(Color(.systemGray6))
                        .cornerRadius(8)
                    }
                    .sheet(isPresented: $showingImagePicker) {
                        ImagePickerLegacy { images in
                            viewModel.animalData.photos.append(contentsOf: images)
                        }
                    }
                }
            }
            
            Spacer()
        }
        .padding()
    }
}

// MARK: - Characteristics Step  
struct CharacteristicsStepView: View {
    @ObservedObject var viewModel: AnimalOnboardingViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 32) {
            Text("🐾 성격과 특징")
                .font(.system(size: 28, weight: .bold))
            
            VStack(alignment: .leading, spacing: 24) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("소개글 *")
                        .font(.system(size: 16, weight: .medium))
                    TextEditor(text: $viewModel.animalData.bio)
                        .frame(minHeight: 100)
                        .padding(8)
                        .background(Color(.systemGray6))
                        .cornerRadius(8)
                }
            }
            
            Spacer()
        }
        .padding()
    }
}

// MARK: - Medical Step
struct MedicalStepView: View {
    @ObservedObject var viewModel: AnimalOnboardingViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 32) {
            Text("🏥 의료 정보")
                .font(.system(size: 28, weight: .bold))
            
            VStack(alignment: .leading, spacing: 24) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("현재 건강 상태 *")
                        .font(.system(size: 16, weight: .medium))
                    Picker("건강상태", selection: $viewModel.animalData.medicalStatus) {
                        Text("선택").tag("")
                        Text("건강함").tag("healthy")
                        Text("치료 필요").tag("needs_treatment")
                        Text("회복 중").tag("recovering")
                    }
                    .pickerStyle(SegmentedPickerStyle())
                }
            }
            
            Spacer()
        }
        .padding()
    }
}

// MARK: - Location Step
struct LocationStepView: View {
    @ObservedObject var viewModel: AnimalOnboardingViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 32) {
            Text("📍 위치 정보")
                .font(.system(size: 28, weight: .bold))
            
            VStack(alignment: .leading, spacing: 24) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("현재 보호 위치 *")
                        .font(.system(size: 16, weight: .medium))
                    TextField("예: 서울시 강남구", text: $viewModel.animalData.location)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("구조 이야기")
                        .font(.system(size: 16, weight: .medium))
                    TextEditor(text: $viewModel.animalData.rescueStory)
                        .frame(minHeight: 100)
                        .padding(8)
                        .background(Color(.systemGray6))
                        .cornerRadius(8)
                }
            }
            
            Spacer()
        }
        .padding()
    }
}

// MARK: - Review Step
struct ReviewStepView: View {
    @ObservedObject var viewModel: AnimalOnboardingViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 32) {
            Text("✨ 필요한 도움 선택")
                .font(.system(size: 28, weight: .bold))
                
            Text("이 아이에게 필요한 도움의 종류를 선택해주세요.")
                .font(.system(size: 16))
                .foregroundColor(.secondary)
            
            VStack(spacing: 16) {
                HelpTypeButton(
                    title: "🚕 이동 봉사",
                    description: "병원 이동, 입양 만남 등 교통 지원",
                    isSelected: viewModel.animalData.helpTypes.contains("transport"),
                    onToggle: { viewModel.animalData.toggleHelpType("transport") }
                )
                
                HelpTypeButton(
                    title: "🏡 임시 보호",
                    description: "단기 보호 가정에서 임시 돌봄",
                    isSelected: viewModel.animalData.helpTypes.contains("temporary_care"),
                    onToggle: { viewModel.animalData.toggleHelpType("temporary_care") }
                )
                
                HelpTypeButton(
                    title: "🧼 미용 지원",
                    description: "목욕, 털 관리 등 미용 서비스",
                    isSelected: viewModel.animalData.helpTypes.contains("grooming"),
                    onToggle: { viewModel.animalData.toggleHelpType("grooming") }
                )
            }
            
            Spacer()
        }
        .padding()
    }
}

// MARK: - Helper Views
struct HelpTypeButton: View {
    let title: String
    let description: String
    let isSelected: Bool
    let onToggle: () -> Void
    
    var body: some View {
        Button(action: onToggle) {
            HStack(spacing: 16) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.primary)
                    Text(description)
                        .font(.system(size: 14))
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.leading)
                }
                
                Spacer()
                
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 20))
                    .foregroundColor(isSelected ? .green : .gray)
            }
            .padding(16)
            .background(isSelected ? Color(.systemGreen).opacity(0.1) : Color(.systemGray6))
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? Color.green : Color.clear, lineWidth: 2)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Legacy Image Picker for iOS 15
struct ImagePickerLegacy: UIViewControllerRepresentable {
    let onImagesSelected: ([UIImage]) -> Void
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        picker.sourceType = .photoLibrary
        picker.allowsEditing = false
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: ImagePickerLegacy
        
        init(_ parent: ImagePickerLegacy) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
            if let image = info[.originalImage] as? UIImage {
                parent.onImagesSelected([image])
            }
            picker.dismiss(animated: true)
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            picker.dismiss(animated: true)
        }
    }
}