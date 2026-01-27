import Foundation

// MARK: - Sign In
struct SignInRequestDTO: Encodable {
    let username: String
    let password: String
}

// MARK: - Sign Up
struct SignUpRequestDTO: Encodable {
    let username: String
    let email: String
    let password: String
}

// MARK: - Auth Response
struct AuthResponseDTO: Decodable {
    let token: String
}
