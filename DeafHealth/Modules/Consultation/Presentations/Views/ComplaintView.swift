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
    @State private var selectedSegment: String = AppLabel.mainSymptoms
    @State private var showAlert = false
    @State private var customComplaint = ""

    var body: some View {
        VStack(spacing: DecimalConstants.zeros) {
            ZStack {
                HStack {
                    Spacer()

                    HStack {
                        Text("1").bold().font(Font.system(size: 14)).bold() + Text(" / 6 pertanyaan").font(Font.custom("SF Pro", size: 13))
                    }
                    .foregroundColor(.gray)
                }
                .padding(.horizontal, DecimalConstants.d8 * 2.75)
                .padding(.top, DecimalConstants.d16 * 1.5)
            }

            HStack(spacing: DecimalConstants.d8) {
                Text("\(AppLabel.complaintStatement) ")
                    .font(Font.system(size: 20)) +

                    Text(complaintViewModel.currentComplaint.answers[0].isEmpty ? "____." : "\(complaintViewModel.currentComplaint.answers[0].lowercased())." )
                    .font(.title3)
                    .foregroundColor(.darkBlue).bold()
            }
            .padding(.horizontal)
            .padding(.top, DecimalConstants.d8 * 2)
            .multilineTextAlignment(.center)
            .frame(maxWidth: 300, alignment: .center)

            Picker("Select Category", selection: $selectedSegment) {
                Text(AppLabel.mainSymptoms).tag(AppLabel.mainSymptoms)
                Text(AppLabel.certainBodyParts).tag(AppLabel.certainBodyParts)
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding(.horizontal)
            .padding(.top, DecimalConstants.d16)
            .padding(.bottom, 15)

            ScrollView {
                if selectedSegment == AppLabel.mainSymptoms {
                    gridOfSymptoms(generalSymptoms)
                } else {
                    gridOfSpecificSymptoms(specificSymptoms)
                }
            }
            .padding(.horizontal)
            .padding(.bottom, 10)

            Spacer()

            Button {
                coordinator.present(sheet: .symptomStartTime)
            } label: {
                Text(AppLabel.continueButton).frame(width: 363, height: 52)
                    .background(isAnswerProvided ? Color(red: 0.25, green: 0.48, blue: 0.68) : Color.gray)
                    .cornerRadius(25)
                    .foregroundColor(Color("FFFFFF"))
                    .disabled(!isAnswerProvided)
                    .padding(.bottom, DecimalConstants.d16 * 2)
            }

//            Button(AppLabel.continueButton) {
//                coordinator.present(sheet: .symptomStartTime)
//            }
//            .frame(width: 363, height: 52)
//            .background(isAnswerProvided ? Color(red: 0.25, green: 0.48, blue: 0.68) : Color.gray)
//            .cornerRadius(25)
//            .foregroundColor(Color("FFFFFF"))
//            .disabled(!isAnswerProvided)
//            .padding(.bottom, DecimalConstants.d16 * 2)
        }
        .background {
            Image(ImageLabel.sheetBackground)
        }
        .alert("Tambahkan Keluhan", isPresented: $showAlert, actions: {
            TextField("Keluhan Anda", text: $customComplaint)
            Button("Simpan", action: saveCustomComplaint)
            Button("Batal", role: .cancel, action: {})
        })
        .edgesIgnoringSafeArea(.bottom)
        .navigationBarBackButtonHidden(true)
        .edgesIgnoringSafeArea(.bottom)
        .navigationBarBackButtonHidden(true)
    }

    func gridOfSymptoms(_ symptoms: [String]) -> some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: DecimalConstants.d16) {
            ForEach(symptoms, id: \.self) { symptom in
                Button(action: {
                    if symptom == "Gejala Lainnya" {
                        showAlert = true
                    } else {
                        selectedComplaint = symptom
                        isAnswerProvided = true
                        complaintViewModel.updateAnswer(for: 0, with: selectedComplaint)
                        complaintViewModel.updateAnswer(for: 1, with: "")
                    }
                }) {
                    symptomButton(symptom)
                }
            }
        }
        .padding(.top, DecimalConstants.d16)
    }

    func gridOfSpecificSymptoms(_ symptoms: [String]) -> some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: DecimalConstants.d16) {
            ForEach(symptoms, id: \.self) { symptom in
                Button(action: {
                    selectedComplaint = symptom
                    complaintViewModel.updateAnswer(for: 0, with: selectedComplaint)
                    coordinator.present(sheet: .selectBodyPart)

                }) {
                    symptomButton(symptom)
                }
            }
        }
        .padding(.top, DecimalConstants.d16)
    }

    func saveCustomComplaint() {
        selectedComplaint = customComplaint
        isAnswerProvided = true
        complaintViewModel.updateAnswer(for: 0, with: selectedComplaint)
        complaintViewModel.updateAnswer(for: 1, with: "")
    }

    func symptomButton(_ symptom: String) -> some View {
        ZStack {
            Text(symptom)
                .font(.headline)
                .foregroundColor(selectedComplaint == symptom ? .white : .primary)
                .offset(y: -55)

            Image(symptom)
                .resizable()
                .scaledToFit()
                .foregroundColor(.white)
        }
        .frame(width: 170, height: 140)
        .background(selectedComplaint == symptom ? .darkBlue : Color(red: 0.91, green: 0.95, blue: 0.99))
        .cornerRadius(12)
    }
}

#Preview {
    ComplaintView()
        .environmentObject(Coordinator())
        .environmentObject(ComplaintViewModel(datasource: LocalDataSource.shared))
}
