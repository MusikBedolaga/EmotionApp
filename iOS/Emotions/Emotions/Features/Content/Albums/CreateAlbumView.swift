import SwiftUI

struct CreateAlbumView: View {
    @SwiftUI.Environment(\.dismiss)
    private var dismiss: DismissAction

    @StateObject
    private var viewModel: CreateAlbumViewModel

    init(userId: Int64, albumsRepo: AlbumsRepositoryProtocol) {
        _viewModel = StateObject(wrappedValue: CreateAlbumViewModel(userId: userId, albumsRepo: albumsRepo))
    }

    var body: some View {
        ZStack {
            Color(.systemGray6)
                .ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    card

                    if let error = viewModel.errorMessage {
                        Text(error)
                            .font(.footnote)
                            .foregroundStyle(Color.red)
                            .frame(maxWidth: .infinity, alignment: .center)
                    }

                    Text("Описание нельзя будет изменить позже")
                        .font(.footnote)
                        .foregroundStyle(Color.secondary)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.top, 6)
                }
                .padding(.horizontal, 16)
                .padding(.top, 16)
                .padding(.bottom, 32)
            }
        }
        .navigationTitle("Новый альбом")
        .navigationBarTitleDisplayMode(.inline)
    }

    private var card: some View {
        VStack(alignment: .leading, spacing: 16) {
            VStack(alignment: .leading, spacing: 8) {
                Text("Название")
                    .font(.headline)

                TextField("Название", text: $viewModel.title)
                    .textFieldStyle(.roundedBorder)

                if let validation = viewModel.titleValidationMessage {
                    Text(validation)
                        .font(.footnote)
                        .foregroundStyle(Color.red)
                }
            }

            VStack(alignment: .leading, spacing: 8) {
                Text("Описание")
                    .font(.headline)

                TextField("Описание", text: $viewModel.description, axis: .vertical)
                    .lineLimit(3...6)
                    .textFieldStyle(.roundedBorder)
            }

            Button {
                Task {
                    let ok = await viewModel.save()
                    if ok {
                        dismiss()
                    }
                }
            } label: {
                ZStack {
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .fill(Color.blue)
                        .frame(height: 54)
                        .shadow(color: Color.black.opacity(0.18), radius: 10, x: 0, y: 6)

                    if viewModel.isSaving {
                        ProgressView()
                            .tint(Color.white)
                    } else {
                        Text("Сохранить")
                            .font(.headline)
                            .foregroundStyle(Color.white)
                    }
                }
            }
            .buttonStyle(.plain)
            .disabled(viewModel.isSaving)
            .opacity(viewModel.isSaving ? 0.85 : 1.0)
            .padding(.top, 4)
        }
        .padding(16)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .shadow(color: Color.black.opacity(0.08), radius: 12, x: 0, y: 6)
    }
}

