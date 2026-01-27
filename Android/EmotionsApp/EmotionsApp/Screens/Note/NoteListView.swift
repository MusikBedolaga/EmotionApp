//
//  NoteListView.swift
//  EmotionsApp
//
//  Created by Муса Зарифянов on 21.11.2025.
//

import SwiftUI

struct NoteListView: View {
    @StateObject private var vm: NoteListViewModel

    @State private var isShowingNewNoteForm = false

    init(album: Album, noteService: any NoteService) {
        _vm = StateObject(
            wrappedValue: NoteListViewModel(
                albumId: album.id,
                albumTitle: album.title,
                service: noteService
            )
        )
    }

    var body: some View {
        NavigationView {
            Group {
                if vm.isLoading && vm.notes.isEmpty {
                    ProgressView("Загрузка...")
                } else if let error = vm.errorMessage, vm.notes.isEmpty {
                    VStack(spacing: 12) {
                        Text(error)
                            .foregroundColor(.red)
                        Button("Повторить") {
                            Task { await vm.loadNotes() }
                        }
                    }
                } else {
                    List {
                        ForEach(vm.notes) { note in
                            VStack(alignment: .leading, spacing: 6) {
                                Text(note.title)
                                    .font(.headline)

                                Text(note.content)
                                    .font(.subheadline)
                                    .lineLimit(2)
                                    .foregroundColor(.secondary)

                                Text(note.createdAt.formatted(date: .abbreviated, time: .shortened))
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                        .onDelete { indexSet in
                            Task {
                                if let index = indexSet.first {
                                    let id = vm.notes[index].id
                                    await vm.deleteNote(id: id)
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("Заметки — \(vm.albumTitle)")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    HStack {
                        Button {
                            Task { await vm.loadNotes() }
                        } label: {
                            Image(systemName: "arrow.clockwise")
                        }

                        Button {
                            isShowingNewNoteForm = true
                        } label: {
                            Image(systemName: "plus")
                        }
                    }
                }
            }
        }
        .task {
            await vm.loadNotes()
        }
        .sheet(isPresented: $isShowingNewNoteForm) {
            NoteFormView { title, content in
                Task { await vm.createNote(title: title, content: content) }
            }
        }
    }
}
