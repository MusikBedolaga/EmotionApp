//
//  RegisterView.swift
//  EmotionsApp
//
//  Created by Муса Зарифянов on 08.11.2025.
//

import SwiftUI

struct RegisterView: View {
    private let authService: any AuthService
    @StateObject private var vm: RegisterVM
    @FocusState private var focused: Field?
    
    init(authService: any AuthService) {
        self.authService = authService
        _vm = StateObject(wrappedValue: RegisterVM(authService: authService))
    }
    
    enum Field: Hashable { case username, email, password }
    
    var body: some View {
        VStack {
            Form {
                TextField("Введите ваше имя", text: $vm.username)
                    .textContentType(.name)
                    .submitLabel(.next)
                    .focused($focused, equals: .username)
                
                TextField("Введите email", text: $vm.email)
                    .keyboardType(.emailAddress)
                    .textContentType(.emailAddress)
                    .autocapitalization(.none)
                    .textInputAutocapitalization(.never)
                    .submitLabel(.next)
                    .focused($focused, equals: .email)
                
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
                Task { await vm.register() }
            } label: {
                if vm.loading {
                    ProgressView()
                } else {
                    Text("Зарегистрироваться")
                }
            }
            .padding(.horizontal, 20)
            .disabled(vm.loading)
            
        }
        .padding(.bottom, 20)
        .onAppear { focused = .email }
    }
}


#Preview {
    let secureStore = KeychainStore()
    let client = AuthClient(baseURL: Bundle.main.serverBaseURL)
    let authService = AuthServiceImpl(client: client, secureStore: secureStore)
    AuthView(authService: authService)
}
