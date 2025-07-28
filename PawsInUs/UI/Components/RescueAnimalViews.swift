//
//  RescueAnimalViews.swift
//  Pawsinus
//
//  Created by Assistant on 1/28/25.
//

import SwiftUI

// MARK: - Rescue Animal Card
struct RescueAnimalCard: View {
    let animal: RescueAnimal
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 0) {
                // Animal image
                ZStack(alignment: .topTrailing) {
                    if let firstImageURL = animal.imageUrls.first,
                       let url = URL(string: firstImageURL) {
                        CachedAsyncImage(url: url) { image in
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                        } placeholder: {
                            Rectangle()
                                .fill(Color.gray.opacity(0.3))
                                .overlay(
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle())
                                )
                        }
                    } else {
                        Rectangle()
                            .fill(Color.gray.opacity(0.3))
                            .overlay(
                                VStack {
                                    Image(systemName: "photo")
                                        .font(.title2)
                                        .foregroundColor(.gray)
                                    Text("사진 없음")
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                }
                            )
                    }
                    
                    // Status indicators
                    VStack(alignment: .trailing, spacing: 4) {
                        // Medical status
                        MedicalStatusBadge(status: animal.medicalStatus)
                        
                        // Featured badge
                        if animal.isFeatured {
                            HStack(spacing: 4) {
                                Image(systemName: "star.fill")
                                    .font(.system(size: 10))
                                Text("추천")
                                    .font(.system(size: 10, weight: .medium))
                            }
                            .foregroundColor(.white)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color.orange)
                            .cornerRadius(8)
                        }
                    }
                    .padding(8)
                }
                .frame(height: 140)
                .clipped()
                
                // Animal info
                VStack(alignment: .leading, spacing: 4) {
                    Text(animal.name)
                        .font(.system(size: 16, weight: .semibold))
                        .lineLimit(1)
                        .foregroundColor(.primary)
                    
                    HStack(spacing: 4) {
                        Text("\(animal.age)세")
                            .font(.system(size: 13))
                            .foregroundColor(.secondary)
                        Text("•")
                            .font(.system(size: 13))
                            .foregroundColor(.secondary)
                        Text(animal.breed)
                            .font(.system(size: 13))
                            .lineLimit(1)
                            .truncationMode(.tail)
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    
                    // Availability status
                    HStack {
                        Circle()
                            .fill(animal.available ? Color.green : Color.gray)
                            .frame(width: 8, height: 8)
                        Text(animal.available ? "입양 가능" : "입양 불가")
                            .font(.system(size: 12))
                            .foregroundColor(animal.available ? .green : .gray)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 12)
                .padding(.vertical, 10)
                .background(Color(.systemBackground))
            }
        }
        .buttonStyle(PlainButtonStyle())
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(color: .black.opacity(0.1), radius: 6, x: 0, y: 3)
        .padding(.horizontal, 2)
    }
}

// MARK: - Medical Status Badge
struct MedicalStatusBadge: View {
    let status: MedicalStatus
    
    var body: some View {
        HStack(spacing: 4) {
            Circle()
                .fill(badgeColor)
                .frame(width: 6, height: 6)
            Text(status.displayName)
                .font(.system(size: 10, weight: .medium))
        }
        .foregroundColor(.white)
        .padding(.horizontal, 6)
        .padding(.vertical, 2)
        .background(badgeColor.opacity(0.8))
        .cornerRadius(8)
    }
    
    private var badgeColor: Color {
        switch status {
        case .healthy:
            return .green
        case .needsTreatment:
            return .red
        case .recovering:
            return .orange
        case .specialNeeds:
            return .blue
        }
    }
}

// MARK: - Add Rescue Animal View
struct AddRescueAnimalView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.injected) private var diContainer
    
    @State private var name = ""
    @State private var breed = ""
    @State private var age = 1
    @State private var size: DogSize = .medium
    @State private var gender: DogGender = .male
    @State private var bio = ""
    @State private var location = ""
    @State private var energyLevel: EnergyLevel = .medium
    @State private var isGoodWithKids = false
    @State private var isGoodWithPets = false
    @State private var houseTrained = false
    @State private var specialNeeds = ""
    @State private var adoptionFee = ""
    @State private var rescueStory = ""
    @State private var medicalStatus: MedicalStatus = .healthy
    @State private var medicalNotes = ""
    @State private var isSpayedNeutered = false
    @State private var rescuerNotes = ""
    @State private var isFeatured = false
    
    @State private var isLoading = false
    @State private var error: Error?
    
    var body: some View {
        NavigationView {
            Form {
                Section("기본 정보") {
                    HStack {
                        Text("이름")
                        TextField("동물 이름", text: $name)
                            .multilineTextAlignment(.trailing)
                    }
                    
                    HStack {
                        Text("품종")
                        TextField("품종", text: $breed)
                            .multilineTextAlignment(.trailing)
                    }
                    
                    HStack {
                        Text("나이")
                        Picker("나이", selection: $age) {
                            ForEach(1...20, id: \.self) { age in
                                Text("\(age)세").tag(age)
                            }
                        }
                        .pickerStyle(MenuPickerStyle())
                    }
                    
                    HStack {
                        Text("크기")
                        Picker("크기", selection: $size) {
                            ForEach(DogSize.allCases, id: \.self) { size in
                                Text(size.displayName).tag(size)
                            }
                        }
                        .pickerStyle(MenuPickerStyle())
                    }
                    
                    HStack {
                        Text("성별")
                        Picker("성별", selection: $gender) {
                            ForEach(DogGender.allCases, id: \.self) { gender in
                                Text(gender.displayName).tag(gender)
                            }
                        }
                        .pickerStyle(MenuPickerStyle())
                    }
                }
                
                Section("위치 및 설명") {
                    HStack {
                        Text("위치")
                        TextField("위치", text: $location)
                            .multilineTextAlignment(.trailing)
                    }
                    
                    VStack(alignment: .leading) {
                        Text("소개")
                        TextEditor(text: $bio)
                            .frame(minHeight: 80)
                    }
                }
                
                Section("성격 및 특성") {
                    HStack {
                        Text("활동량")
                        Picker("활동량", selection: $energyLevel) {
                            ForEach(EnergyLevel.allCases, id: \.self) { level in
                                Text(level.displayName).tag(level)
                            }
                        }
                        .pickerStyle(MenuPickerStyle())
                    }
                    
                    Toggle("아이들과 잘 어울림", isOn: $isGoodWithKids)
                    Toggle("다른 반려동물과 잘 어울림", isOn: $isGoodWithPets)
                    Toggle("배변 훈련됨", isOn: $houseTrained)
                    
                    VStack(alignment: .leading) {
                        Text("특별한 요구사항")
                        TextField("특별한 요구사항이 있다면 입력하세요", text: $specialNeeds)
                    }
                }
                
                Section("의료 정보") {
                    HStack {
                        Text("건강 상태")
                        Picker("건강 상태", selection: $medicalStatus) {
                            ForEach(MedicalStatus.allCases, id: \.self) { status in
                                Text(status.displayName).tag(status)
                            }
                        }
                        .pickerStyle(MenuPickerStyle())
                    }
                    
                    VStack(alignment: .leading) {
                        Text("의료 기록")
                        TextEditor(text: $medicalNotes)
                            .frame(minHeight: 60)
                    }
                    
                    Toggle("중성화 수술 완료", isOn: $isSpayedNeutered)
                }
                
                Section("기타") {
                    HStack {
                        Text("입양비")
                        TextField("입양비 (원)", text: $adoptionFee)
                            .multilineTextAlignment(.trailing)
                            .keyboardType(.numberPad)
                    }
                    
                    VStack(alignment: .leading) {
                        Text("구조 이야기")
                        TextEditor(text: $rescueStory)
                            .frame(minHeight: 80)
                    }
                    
                    VStack(alignment: .leading) {
                        Text("내부 메모")
                        TextEditor(text: $rescuerNotes)
                            .frame(minHeight: 60)
                    }
                    
                    Toggle("추천 동물로 표시", isOn: $isFeatured)
                }
            }
            .navigationTitle("새 동물 등록")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("취소") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("저장") {
                        saveAnimal()
                    }
                    .disabled(isLoading || name.isEmpty || breed.isEmpty)
                }
            }
            .overlay {
                if isLoading {
                    Color.black.opacity(0.3)
                        .ignoresSafeArea()
                        .overlay(
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle())
                                .scaleEffect(1.5)
                        )
                }
            }
        }
        .alert("오류", isPresented: .constant(error != nil)) {
            Button("확인") {
                error = nil
            }
        } message: {
            Text(error?.localizedDescription ?? "알 수 없는 오류가 발생했습니다.")
        }
    }
    
    private func saveAnimal() {
        isLoading = true
        
        Task {
            do {
                let adoptionFeeDouble = Double(adoptionFee) ?? 0.0
                
                let newAnimal = CreateRescueAnimal(
                    name: name,
                    breed: breed,
                    age: age,
                    size: size,
                    gender: gender,
                    bio: bio.isEmpty ? nil : bio,
                    location: location,
                    traits: [], // TODO: Add traits selection
                    energyLevel: energyLevel,
                    isGoodWithKids: isGoodWithKids,
                    isGoodWithPets: isGoodWithPets,
                    houseTrained: houseTrained,
                    specialNeeds: specialNeeds.isEmpty ? nil : specialNeeds,
                    adoptionFee: adoptionFeeDouble > 0 ? adoptionFeeDouble : nil,
                    available: true,
                    imageUrls: [], // TODO: Add image upload
                    rescueDate: Date(),
                    rescueLocation: nil,
                    rescueStory: rescueStory.isEmpty ? nil : rescueStory,
                    medicalStatus: medicalStatus,
                    medicalNotes: medicalNotes.isEmpty ? nil : medicalNotes,
                    isSpayedNeutered: isSpayedNeutered,
                    rescuerNotes: rescuerNotes.isEmpty ? nil : rescuerNotes,
                    isFeatured: isFeatured,
                    vaccinations: nil,
                    fosterFamilyId: nil,
                    documentUrls: []
                )
                
                _ = try await diContainer.interactors.rescueInteractor.addRescueAnimal(newAnimal)
                
                await MainActor.run {
                    isLoading = false
                    dismiss()
                }
            } catch {
                await MainActor.run {
                    isLoading = false
                    self.error = error
                }
            }
        }
    }
}

// MARK: - Rescue Animal Detail View
struct RescueAnimalDetailView: View {
    let animal: RescueAnimal
    @Environment(\.dismiss) private var dismiss
    @Environment(\.injected) private var diContainer
    
    @State private var showingEditView = false
    @State private var showingDeleteAlert = false
    @State private var isDeleting = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Animal images
                    if !animal.imageUrls.isEmpty {
                        TabView {
                            ForEach(animal.imageUrls, id: \.self) { imageURL in
                                CachedAsyncImage(url: URL(string: imageURL)) { image in
                                    image
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                } placeholder: {
                                    Rectangle()
                                        .fill(Color.gray.opacity(0.3))
                                        .overlay(ProgressView())
                                }
                                .frame(height: 300)
                                .clipped()
                            }
                        }
                        .tabViewStyle(PageTabViewStyle())
                        .frame(height: 300)
                    }
                    
                    VStack(alignment: .leading, spacing: 16) {
                        // Basic info
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Text(animal.name)
                                    .font(.largeTitle)
                                    .fontWeight(.bold)
                                
                                Spacer()
                                
                                MedicalStatusBadge(status: animal.medicalStatus)
                            }
                            
                            Text("\(animal.age)세 • \(animal.breed) • \(animal.gender.displayName)")
                                .font(.title3)
                                .foregroundColor(.secondary)
                        }
                        
                        Divider()
                        
                        // Bio
                        if let bio = animal.bio, !bio.isEmpty {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("소개")
                                    .font(.headline)
                                Text(bio)
                                    .font(.body)
                            }
                            
                            Divider()
                        }
                        
                        // Rescue story
                        if let rescueStory = animal.rescueStory, !rescueStory.isEmpty {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("구조 이야기")
                                    .font(.headline)
                                Text(rescueStory)
                                    .font(.body)
                            }
                            
                            Divider()
                        }
                        
                        // Characteristics
                        VStack(alignment: .leading, spacing: 8) {
                            Text("특성")
                                .font(.headline)
                            
                            VStack(spacing: 4) {
                                CharacteristicRow(label: "활동량", value: animal.energyLevel.displayName)
                                CharacteristicRow(label: "아이들과 어울림", value: animal.isGoodWithKids ? "좋음" : "어려움")
                                CharacteristicRow(label: "다른 반려동물과 어울림", value: animal.isGoodWithPets ? "좋음" : "어려움")
                                CharacteristicRow(label: "배변 훈련", value: animal.houseTrained ? "완료" : "필요")
                                CharacteristicRow(label: "중성화 수술", value: animal.isSpayedNeutered ? "완료" : "필요")
                            }
                        }
                        
                        Divider()
                        
                        // Medical info
                        if let medicalNotes = animal.medicalNotes, !medicalNotes.isEmpty {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("의료 기록")
                                    .font(.headline)
                                Text(medicalNotes)
                                    .font(.body)
                            }
                            
                            Divider()
                        }
                        
                        // Internal notes for rescuer
                        if let rescuerNotes = animal.rescuerNotes, !rescuerNotes.isEmpty {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("내부 메모")
                                    .font(.headline)
                                Text(rescuerNotes)
                                    .font(.body)
                                    .foregroundColor(.secondary)
                            }
                            
                            Divider()
                        }
                        
                        // Status and availability
                        VStack(alignment: .leading, spacing: 8) {
                            Text("상태")
                                .font(.headline)
                            
                            HStack {
                                Circle()
                                    .fill(animal.available ? Color.green : Color.gray)
                                    .frame(width: 12, height: 12)
                                Text(animal.available ? "입양 가능" : "입양 불가")
                                    .font(.body)
                                    .foregroundColor(animal.available ? .green : .gray)
                            }
                            
                            if let adoptionFee = animal.adoptionFee, adoptionFee > 0 {
                                Text("입양비: ₩\(Int(adoptionFee))")
                                    .font(.body)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("동물 상세")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("닫기") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        Button("편집", systemImage: "pencil") {
                            showingEditView = true
                        }
                        
                        Divider()
                        
                        Button("삭제", systemImage: "trash", role: .destructive) {
                            showingDeleteAlert = true
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                    }
                }
            }
        }
        .sheet(isPresented: $showingEditView) {
            EditRescueAnimalView(animal: animal)
        }
        .alert("동물 삭제", isPresented: $showingDeleteAlert) {
            Button("취소", role: .cancel) { }
            Button("삭제", role: .destructive) {
                deleteAnimal()
            }
        } message: {
            Text("\(animal.name)을(를) 삭제하시겠습니까? 이 작업은 되돌릴 수 없습니다.")
        }
        .overlay {
            if isDeleting {
                Color.black.opacity(0.3)
                    .ignoresSafeArea()
                    .overlay(
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle())
                            .scaleEffect(1.5)
                    )
            }
        }
    }
    
    private func deleteAnimal() {
        isDeleting = true
        
        Task {
            do {
                try await diContainer.interactors.rescueInteractor.deleteRescueAnimal(id: animal.id)
                await MainActor.run {
                    isDeleting = false
                    dismiss()
                }
            } catch {
                await MainActor.run {
                    isDeleting = false
                    // TODO: Show error alert
                }
            }
        }
    }
}

// MARK: - Characteristic Row
struct CharacteristicRow: View {
    let label: String
    let value: String
    
    var body: some View {
        HStack {
            Text(label)
                .font(.body)
            Spacer()
            Text(value)
                .font(.body)
                .foregroundColor(.secondary)
        }
    }
}

// MARK: - Edit Rescue Animal View
struct EditRescueAnimalView: View {
    let animal: RescueAnimal
    @Environment(\.dismiss) private var dismiss
    @Environment(\.injected) private var diContainer
    
    @State private var name: String
    @State private var breed: String
    @State private var age: Int
    @State private var size: DogSize
    @State private var gender: DogGender
    @State private var bio: String
    @State private var location: String
    @State private var energyLevel: EnergyLevel
    @State private var isGoodWithKids: Bool
    @State private var isGoodWithPets: Bool
    @State private var houseTrained: Bool
    @State private var specialNeeds: String
    @State private var adoptionFee: String
    @State private var rescueStory: String
    @State private var medicalStatus: MedicalStatus
    @State private var medicalNotes: String
    @State private var isSpayedNeutered: Bool
    @State private var rescuerNotes: String
    @State private var isFeatured: Bool
    @State private var available: Bool
    
    @State private var isLoading = false
    @State private var error: Error?
    
    init(animal: RescueAnimal) {
        self.animal = animal
        _name = State(initialValue: animal.name)
        _breed = State(initialValue: animal.breed)
        _age = State(initialValue: animal.age)
        _size = State(initialValue: animal.size)
        _gender = State(initialValue: animal.gender)
        _bio = State(initialValue: animal.bio ?? "")
        _location = State(initialValue: animal.location)
        _energyLevel = State(initialValue: animal.energyLevel)
        _isGoodWithKids = State(initialValue: animal.isGoodWithKids)
        _isGoodWithPets = State(initialValue: animal.isGoodWithPets)
        _houseTrained = State(initialValue: animal.houseTrained)
        _specialNeeds = State(initialValue: animal.specialNeeds ?? "")
        _adoptionFee = State(initialValue: animal.adoptionFee != nil ? String(Int(animal.adoptionFee!)) : "")
        _rescueStory = State(initialValue: animal.rescueStory ?? "")
        _medicalStatus = State(initialValue: animal.medicalStatus)
        _medicalNotes = State(initialValue: animal.medicalNotes ?? "")
        _isSpayedNeutered = State(initialValue: animal.isSpayedNeutered)
        _rescuerNotes = State(initialValue: animal.rescuerNotes ?? "")
        _isFeatured = State(initialValue: animal.isFeatured)
        _available = State(initialValue: animal.available)
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section("기본 정보") {
                    HStack {
                        Text("이름")
                        TextField("동물 이름", text: $name)
                            .multilineTextAlignment(.trailing)
                    }
                    
                    HStack {
                        Text("품종")
                        TextField("품종", text: $breed)
                            .multilineTextAlignment(.trailing)
                    }
                    
                    HStack {
                        Text("나이")
                        Picker("나이", selection: $age) {
                            ForEach(1...20, id: \.self) { age in
                                Text("\(age)세").tag(age)
                            }
                        }
                        .pickerStyle(MenuPickerStyle())
                    }
                    
                    HStack {
                        Text("크기")
                        Picker("크기", selection: $size) {
                            ForEach(DogSize.allCases, id: \.self) { size in
                                Text(size.displayName).tag(size)
                            }
                        }
                        .pickerStyle(MenuPickerStyle())
                    }
                    
                    HStack {
                        Text("성별")
                        Picker("성별", selection: $gender) {
                            ForEach(DogGender.allCases, id: \.self) { gender in
                                Text(gender.displayName).tag(gender)
                            }
                        }
                        .pickerStyle(MenuPickerStyle())
                    }
                }
                
                Section("위치 및 설명") {
                    HStack {
                        Text("위치")
                        TextField("위치", text: $location)
                            .multilineTextAlignment(.trailing)
                    }
                    
                    VStack(alignment: .leading) {
                        Text("소개")
                        TextEditor(text: $bio)
                            .frame(minHeight: 80)
                    }
                }
                
                Section("성격 및 특성") {
                    HStack {
                        Text("활동량")
                        Picker("활동량", selection: $energyLevel) {
                            ForEach(EnergyLevel.allCases, id: \.self) { level in
                                Text(level.displayName).tag(level)
                            }
                        }
                        .pickerStyle(MenuPickerStyle())
                    }
                    
                    Toggle("아이들과 잘 어울림", isOn: $isGoodWithKids)
                    Toggle("다른 반려동물과 잘 어울림", isOn: $isGoodWithPets)
                    Toggle("배변 훈련됨", isOn: $houseTrained)
                    
                    VStack(alignment: .leading) {
                        Text("특별한 요구사항")
                        TextField("특별한 요구사항이 있다면 입력하세요", text: $specialNeeds)
                    }
                }
                
                Section("의료 정보") {
                    HStack {
                        Text("건강 상태")
                        Picker("건강 상태", selection: $medicalStatus) {
                            ForEach(MedicalStatus.allCases, id: \.self) { status in
                                Text(status.displayName).tag(status)
                            }
                        }
                        .pickerStyle(MenuPickerStyle())
                    }
                    
                    VStack(alignment: .leading) {
                        Text("의료 기록")
                        TextEditor(text: $medicalNotes)
                            .frame(minHeight: 60)
                    }
                    
                    Toggle("중성화 수술 완료", isOn: $isSpayedNeutered)
                }
                
                Section("기타") {
                    HStack {
                        Text("입양비")
                        TextField("입양비 (원)", text: $adoptionFee)
                            .multilineTextAlignment(.trailing)
                            .keyboardType(.numberPad)
                    }
                    
                    VStack(alignment: .leading) {
                        Text("구조 이야기")
                        TextEditor(text: $rescueStory)
                            .frame(minHeight: 80)
                    }
                    
                    VStack(alignment: .leading) {
                        Text("내부 메모")
                        TextEditor(text: $rescuerNotes)
                            .frame(minHeight: 60)
                    }
                    
                    Toggle("추천 동물로 표시", isOn: $isFeatured)
                    Toggle("입양 가능", isOn: $available)
                }
            }
            .navigationTitle("동물 편집")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("취소") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("저장") {
                        saveChanges()
                    }
                    .disabled(isLoading || name.isEmpty || breed.isEmpty)
                }
            }
            .overlay {
                if isLoading {
                    Color.black.opacity(0.3)
                        .ignoresSafeArea()
                        .overlay(
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle())
                                .scaleEffect(1.5)
                        )
                }
            }
        }
        .alert("오류", isPresented: .constant(error != nil)) {
            Button("확인") {
                error = nil
            }
        } message: {
            Text(error?.localizedDescription ?? "알 수 없는 오류가 발생했습니다.")
        }
    }
    
    private func saveChanges() {
        isLoading = true
        
        Task {
            do {
                let adoptionFeeDouble = Double(adoptionFee) ?? 0.0
                
                let updatedAnimal = RescueAnimal(
                    id: animal.id,
                    rescuerId: animal.rescuerId,
                    name: name,
                    breed: breed,
                    age: age,
                    size: size,
                    gender: gender,
                    imageUrls: animal.imageUrls,
                    bio: bio.isEmpty ? nil : bio,
                    location: location,
                    traits: animal.traits,
                    energyLevel: energyLevel,
                    isGoodWithKids: isGoodWithKids,
                    isGoodWithPets: isGoodWithPets,
                    houseTrained: houseTrained,
                    specialNeeds: specialNeeds.isEmpty ? nil : specialNeeds,
                    adoptionFee: adoptionFeeDouble > 0 ? adoptionFeeDouble : nil,
                    available: available,
                    rescueDate: animal.rescueDate,
                    rescueLocation: animal.rescueLocation,
                    rescueStory: rescueStory.isEmpty ? nil : rescueStory,
                    medicalStatus: medicalStatus,
                    medicalNotes: medicalNotes.isEmpty ? nil : medicalNotes,
                    isSpayedNeutered: isSpayedNeutered,
                    vaccinations: animal.vaccinations ?? [:],
                    fosterFamilyId: animal.fosterFamilyId,
                    documentUrls: animal.documentUrls,
                    rescuerNotes: rescuerNotes.isEmpty ? nil : rescuerNotes,
                    isFeatured: isFeatured,
                    shelterName: animal.shelterName,
                    shelterId: animal.shelterId,
                    dateAdded: animal.dateAdded,
                    createdAt: animal.createdAt,
                    updatedAt: animal.updatedAt
                )
                
                _ = try await diContainer.interactors.rescueInteractor.updateRescueAnimal(updatedAnimal)
                
                await MainActor.run {
                    isLoading = false
                    dismiss()
                }
            } catch {
                await MainActor.run {
                    isLoading = false
                    self.error = error
                }
            }
        }
    }
}