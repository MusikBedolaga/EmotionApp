//
//  AlbumView.swift
//  EmotionsApp
//
//  Created by Муса Зарифянов on 20.11.2025.
//

import SwiftUI

struct AlbumListView: View {
    @StateObject private var vm: AlbumViewModel

    @State private var isShowingForm = false
    @State private var editingAlbum: Album? = nil

    init(albumService: any AlbumService) {
        _vm = StateObject(wrappedValue: AlbumViewModel(service: albumService))
    }

    var body: some View {
        NavigationView {
            Group {
                if vm.isLoading && vm.albums.isEmpty {
                    ProgressView("Загрузка...")
                } else if let error = vm.errorMessage, vm.albums.isEmpty {
                    VStack(spacing: 12) {
                        Text(error)
                            .foregroundColor(.red)
                        Button("Повторить") {
                            Task { await vm.loadAlbums() }
                        }
                    }
                } else {
                    List {
                        ForEach(vm.albums, id: \.id) { album in
                            VStack(alignment: .leading, spacing: 4) {
                                Text(album.title)
                                    .font(.headline)
                                Text(album.description)
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                            .contentShape(Rectangle())
                            .onTapGesture {
                                editingAlbum = album
                                isShowingForm = true
                            }
                        }
                        .onDelete { indexSet in
                            Task {
                                if let index = indexSet.first {
                                    let id = vm.albums[index].id
                                    await vm.deleteAlbum(id: id)
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("Альбомы")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    if vm.isLoading && !vm.albums.isEmpty {
                        ProgressView()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    HStack {
                        Button("Обновить") {
                            Task { await vm.loadAlbums() }
                        }
                        Button {
                            editingAlbum = nil      // режим создания
                            isShowingForm = true
                        } label: {
                            Image(systemName: "plus")
                        }
                    }
                }
            }
        }
        .task {
            await vm.loadAlbums()
        }
        .sheet(isPresented: $isShowingForm) {
            AlbumFormView(album: editingAlbum) { title, description in
                Task {
                    if var album = editingAlbum {
                        album.title = title
                        album.description = description
                        await vm.updateAlbum(album)
                    } else {
                        await vm.createAlbum(title: title, description: description)
                    }
                }
            }
        }
    }
}


