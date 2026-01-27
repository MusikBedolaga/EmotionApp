import Foundation

enum AuthAPI {
    case signIn(request: SignInRequestDTO)
    case signUp(request: SignUpRequestDTO)
}

// MARK: - Endpoint
extension AuthAPI: Endpoint {
    var path: String {
        switch self {
        case .signIn:
            return "auth/sign-in"
        case .signUp:
            return "auth/sign-up"
        }
    }

    var method: HTTPMethod {
        switch self {
        case .signIn, .signUp:
            return .post
        }
    }

    var body: Encodable? {
        switch self {
        case .signIn(let request):
            return request
        case .signUp(let request):
            return request
        }
    }

    var requiresAuth: Bool {
        false
    }
}

