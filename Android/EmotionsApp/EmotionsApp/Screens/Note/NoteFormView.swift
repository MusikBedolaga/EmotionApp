//
//  NoteFormView.swift
//  EmotionsApp
//
//  Created by Муса Зарифянов on 21.11.2025.
//

import SwiftUI

struct NoteFormView: View {
    @Environment(\.dismiss) private var dismiss

    @State private var title: String = ""
    @State private var content: String = ""

    let onSave: (String, String) -> Void

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Заголовок")) {
                    TextField("Введите заголовок", text: $title)
                }
                Section(header: Text("Текст заметки")) {
                    TextField("Введите текст", text: $content, axis: .vertical)
                        .lineLimit(4...10)
                }
            }
            .navigationTitle("Новая заметка")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Отмена") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Сохранить") {
                        onSave(title, content)
                        dismiss()
                    }
                    .disabled(title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
    }
}
