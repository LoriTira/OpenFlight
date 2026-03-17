import Foundation

enum AppConstants {
    static let appName = "OpenFlight"

    /// UserDefaults key for the AviationStack API key
    static let apiKeyDefaultsKey = "aviationstack_api_key"

    /// Minimum interval between auto-refreshes (in seconds)
    static let refreshInterval: TimeInterval = 300 // 5 minutes

    /// Read the stored API key from UserDefaults
    static var storedAPIKey: String? {
        get { UserDefaults.standard.string(forKey: apiKeyDefaultsKey) }
        set { UserDefaults.standard.set(newValue, forKey: apiKeyDefaultsKey) }
    }
}
