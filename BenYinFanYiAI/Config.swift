import Foundation

nonisolated enum Config {
    static let EXPO_PUBLIC_REVENUECAT_TEST_API_KEY = ProcessInfo.processInfo.environment["EXPO_PUBLIC_REVENUECAT_TEST_API_KEY"] ?? "test_YSvEDZUkQASolHChRvuZaqxqAYR"
    static let EXPO_PUBLIC_REVENUECAT_IOS_API_KEY = ProcessInfo.processInfo.environment["EXPO_PUBLIC_REVENUECAT_IOS_API_KEY"] ?? "appl_JnhLlSmfcOuBeKxFPYtfzETngXE"
    static let EXPO_PUBLIC_TOOLKIT_URL = ProcessInfo.processInfo.environment["EXPO_PUBLIC_TOOLKIT_URL"] ?? "https://toolkit.rork.com"
    static let EXPO_PUBLIC_PROJECT_ID = ProcessInfo.processInfo.environment["EXPO_PUBLIC_PROJECT_ID"] ?? "p3k501q3kjdgxwexppwhs"
    static let EXPO_PUBLIC_TEAM_ID = ProcessInfo.processInfo.environment["EXPO_PUBLIC_TEAM_ID"] ?? "0550613b-0cab-410f-a5fe-943e8341c6a4"
    static let EXPO_PUBLIC_RORK_API_BASE_URL = ProcessInfo.processInfo.environment["EXPO_PUBLIC_RORK_API_BASE_URL"] ?? ""
}
