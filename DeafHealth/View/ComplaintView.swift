//
//  ComplaintView.swift
//  DeafHealth
//
//  Created by Anthony on 16/08/24.
//

import SwiftUI

struct ComplaintView: View {
    @EnvironmentObject var coordinator: Coordinator
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var complaintViewModel: ComplaintViewModel

    @State private var selectedComplaint: String = ""
    @State private var isAnswerProvided: Bool = false
    @State private var selectedSegment: String = "Gejala Umum" // Default segment

    var body: some View {
        VStack(spacing: 0) {
            ZStack {
                HStack {
                    Spacer()

                    HStack {
                        Text("1").bold().font(Font.custom("SF Pro Bold", size: 14)) + Text(" / 6 pertanyaan").font(Font.custom("SF Pro", size: 13))
                    }
                    .foregroundColor(.gray)
                }
                .padding(.horizontal, 22)
                .padding(.top, 24) // Increased top padding
            }

            // Main text question with dynamic complaint insertion
            VStack(spacing: 8) {
                Text("Halo, Dokter. Saya merasakan")
                    .font(.title3)
                    .multilineTextAlignment(.center)

                Text(selectedComplaint.isEmpty ? "____." : selectedComplaint)
                    .font(.title3)
                    .foregroundColor(selectedComplaint.isEmpty ? .primary : Color.blue) // Change color to blue if selected
                    .multilineTextAlignment(.center)
            }
            .padding(.horizontal)
            .padding(.top, 16)

            // Segmented control
            Picker("Select Category", selection: $selectedSegment) {
                Text("Gejala Umum").tag("Gejala Umum")
                Text("Bagian Tertentu").tag("Bagian Tertentu")
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding(.horizontal)
            .padding(.top, 15)
            .padding(.bottom, 15)

            // Complaint selection buttons based on the selected segment
            ScrollView {
                if selectedSegment == "Gejala Umum" {
                    gridOfSymptoms(generalSymptoms)
                } else {
                    gridOfSymptoms(specificSymptoms)
                }
            }
            .padding(.horizontal)
            .padding(.bottom, 10)

            Spacer()

            Button("Lanjutkan") {
                coordinator.present(sheet: .selectBodyPart)
            }
            .frame(width: 363, height: 52)
            .background(isAnswerProvided ? Color(red: 0.25, green: 0.48, blue: 0.68) : Color.gray)
            .cornerRadius(25)
            .foregroundColor(Color("FFFFFF"))
            .disabled(!isAnswerProvided)
            .padding(.bottom, 32) // Increased bottom padding
        }
        .edgesIgnoringSafeArea(.bottom)
        .navigationBarBackButtonHidden(true)
    }

    // View for arranging the symptoms in a grid
    func gridOfSymptoms(_ symptoms: [String]) -> some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
            ForEach(symptoms, id: \.self) { symptom in
                Button(action: {
                    selectedComplaint = symptom
                    isAnswerProvided = true
                    complaintViewModel.updateAnswer(for: 0, with: selectedComplaint)
                }) {
                    symptomButton(symptom)
                }
            }
        }
        .padding(.top, 16)
    }

    // Helper view for symptom buttons
    func symptomButton(_ symptom: String) -> some View {
        VStack {
            Text(symptom)
                .font(.headline)
                .foregroundColor(selectedComplaint == symptom ? .white : .primary)
            
            Image(systemName: "photo") // Placeholder for actual image
                .resizable()
                .scaledToFit()
                .frame(height: 60)
                .foregroundColor(.white)
        }
        .frame(maxWidth: .infinity, maxHeight: 150)
        .padding()
        .background(selectedComplaint == symptom ? Color.blue : Color("light-blue")) // Change color if selected
        .cornerRadius(12)
    }

    // Sample data for symptoms
    var generalSymptoms: [String] {
        ["Flu", "Demam", "Pusing", "Batuk", "Sesak Nafas", "Diare", "Mual/Muntah", "Sakit lain"]
    }

    var specificSymptoms: [String] {
        ["Sakit Kepala", "Nyeri Dada", "Nyeri Punggung", "Nyeri Sendi", "Nyeri Otot"]
    }
}

// CornerRadius on specific corners using a RoundedRectangle background
extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}

struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
}

struct SegmentedProgressBar: View {
    var totalSteps: Int
    var currentStep: Int

    var body: some View {
        HStack(spacing: 4) {
            ForEach(0..<totalSteps, id: \.self) { index in
                Rectangle()
                    .frame(height: 3)
                    .frame(width: 30)
                    .foregroundColor(index < self.currentStep ? Color("dark-green") : Color("light-green"))
                    .cornerRadius(4)
            }
        }
        .padding(.horizontal)
    }
}

#Preview {
    ComplaintView()
        .environmentObject(Coordinator())
        .environmentObject(ComplaintViewModel(datasource: LocalDataSource.shared))
}
