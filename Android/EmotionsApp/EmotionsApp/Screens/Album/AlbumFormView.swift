//
//  AlbumFormView.swift
//  EmotionsApp
//
//  Created by Муса Зарифянов on 21.11.2025.
//

import SwiftUI

struct AlbumFormView: View {
    @Environment(\.dismiss) private var dismiss

    @State private var title: String
    @State private var description: String

    let isEditing: Bool
    let onSave: (String, String) -> Void

    init(album: Album?, onSave: @escaping (String, String) -> Void) {
        _title = State(initialValue: album?.title ?? "")
        _description = State(initialValue: album?.description ?? "")
        self.isEditing = (album != nil)
        self.onSave = onSave
    }

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Название")) {
                    TextField("Введите название", text: $title)
                }
                Section(header: Text("Описание")) {
                    TextField("Введите описание", text: $description, axis: .vertical)
                        .lineLimit(3...6)
                }
            }
            .navigationTitle(isEditing ? "Изменить альбом" : "Новый альбом")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Отмена") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Сохранить") {
                        onSave(title, description)
                        dismiss()
                    }
                    .disabled(title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
    }
}
