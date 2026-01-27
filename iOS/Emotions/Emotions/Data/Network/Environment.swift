import Foundation

enum Environment {
    static var baseURL: URL {
        #if targetEnvironment(simulator)
        guard let url = URL(string: AppConstants.API.simulatorBaseURL) else {
            return URL(string: AppConstants.API.deviceBaseURL)!
        }
        #else
        guard let url = URL(string: AppConstants.API.deviceBaseURL) else {
            return URL(string: AppConstants.API.simulatorBaseURL)!
        }
        #endif
        return url
    }
}
