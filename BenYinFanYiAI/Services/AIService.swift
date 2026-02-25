import Foundation

nonisolated struct AIBackendResponse: Codable, Sendable {
    let success: Bool
    let data: AIResponseData?
    let error: String?
}

nonisolated struct AIResponseData: Codable, Sendable {
    let honne: String
    let psychologicalState: String
    let suggestedResponse: String
    let emotionLevel: Int
}

@Observable
@MainActor
class AIService {
    var isAnalyzing = false
    var errorMessage: String?

    private let apiBaseURL: String = Config.EXPO_PUBLIC_RORK_API_BASE_URL

    func analyzeMessage(_ text: String, relationship: RelationshipType) async -> TranslationResult? {
        isAnalyzing = true
        errorMessage = nil
        defer { isAnalyzing = false }

        do {
            guard !apiBaseURL.isEmpty else {
                errorMessage = "APIのURLが設定されていません。"
                return nil
            }

            guard let url = URL(string: "\(apiBaseURL)/api/translate") else {
                errorMessage = "APIに接続できません。"
                return nil
            }

            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.timeoutInterval = 60

            let body: [String: String] = [
                "text": text,
                "relationship": relationship.displayName
            ]

            request.httpBody = try JSONSerialization.data(withJSONObject: body)

            let (data, response) = try await URLSession.shared.data(for: request)

            guard let httpResponse = response as? HTTPURLResponse else {
                errorMessage = "サーバーからの応答が無効です。もう一度お試しください。"
                return nil
            }

            guard (200...299).contains(httpResponse.statusCode) else {
                let responseText = String(data: data, encoding: .utf8) ?? ""
                print("[AIService] HTTP \(httpResponse.statusCode): \(responseText)")
                errorMessage = "AI分析中にエラーが発生しました（\(httpResponse.statusCode)）。もう一度お試しください。"
                return nil
            }

            let backendResponse = try JSONDecoder().decode(AIBackendResponse.self, from: data)

            guard backendResponse.success, let aiData = backendResponse.data else {
                errorMessage = backendResponse.error ?? "分析結果の取得に失敗しました。"
                return nil
            }

            return TranslationResult(
                originalText: text,
                relationship: relationship,
                honne: aiData.honne,
                psychologicalState: aiData.psychologicalState,
                suggestedResponse: aiData.suggestedResponse,
                emotionLevel: min(5, max(1, aiData.emotionLevel))
            )
        } catch {
            print("[AIService] Error: \(error)")
            errorMessage = "分析中にエラーが発生しました。もう一度お試しください。"
            return nil
        }
    }
}
