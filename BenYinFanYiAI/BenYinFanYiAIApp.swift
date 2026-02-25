import SwiftUI
import RevenueCat

@main
struct BenYinFanYiAIApp: App {
    @State private var aiService = AIService()
    @State private var subscriptionService = SubscriptionService()
    @State private var historyService = HistoryService()

    init() {
        #if DEBUG
        Purchases.logLevel = .debug
        Purchases.configure(withAPIKey: Config.EXPO_PUBLIC_REVENUECAT_TEST_API_KEY)
        #else
        Purchases.configure(withAPIKey: Config.EXPO_PUBLIC_REVENUECAT_IOS_API_KEY)
        #endif
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(aiService)
                .environment(subscriptionService)
                .environment(historyService)
                .task {
                    await subscriptionService.checkSubscriptionStatus()
                }
        }
    }
}
