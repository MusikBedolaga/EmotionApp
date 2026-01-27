//
//  AuthView.swift
//  EmotionsApp
//
//  Created by Муса Зарифянов on 08.11.2025.
//

import SwiftUI

struct AuthView: View {
    private let authService: any AuthService
    @StateObject private var vm: AuthVM
    @FocusState private var focused: Field?
    
    enum Field: Hashable { case username, password }
    
    init(authService: any AuthService) {
        self.authService = authService
        _vm = StateObject(wrappedValue: AuthVM(authService: authService))
    }
    
    var body: some View {
        VStack {
            Form {
                TextField("Введите ваше имя", text: $vm.username)
                    .textContentType(.name)
                    .submitLabel(.next)
                    .focused($focused, equals: .username)
                
                SecureField("Пароль", text: $vm.password)
                    .textContentType(.newPassword)
                    .submitLabel(.done)
                    .focused($focused, equals: .password)
            }
            
            if let error = vm.error {
                Text(error)
                    .foregroundColor(.red)
                    .padding(.top, 8)
            }
            
            Spacer()
            
            Button {
                Task { await vm.authorization() }
            } label: {
                if vm.loading {
                    ProgressView()
                } else {
                    Text("Войти")
                }
            }
            .padding(.horizontal, 20)
            .disabled(vm.loading)
        }
        .padding(.bottom, 20)
        .onAppear { focused = .username }
    }
}

#Preview {
    let secureStore = KeychainStore()
    let client = AuthClient(baseURL: Bundle.main.serverBaseURL)
    let authService = AuthServiceImpl(client: client, secureStore: secureStore)
    AuthView(authService: authService)
}
