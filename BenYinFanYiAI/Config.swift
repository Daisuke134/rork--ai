import Foundation

nonisolated enum Config {
    static let EXPO_PUBLIC_REVENUECAT_TEST_API_KEY = ProcessInfo.processInfo.environment["EXPO_PUBLIC_REVENUECAT_TEST_API_KEY"] ?? ""
    static let EXPO_PUBLIC_REVENUECAT_IOS_API_KEY = ProcessInfo.processInfo.environment["EXPO_PUBLIC_REVENUECAT_IOS_API_KEY"] ?? ""
    static let EXPO_PUBLIC_TOOLKIT_URL = ProcessInfo.processInfo.environment["EXPO_PUBLIC_TOOLKIT_URL"] ?? ""
}
