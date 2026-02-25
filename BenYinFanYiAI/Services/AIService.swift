import Foundation

nonisolated struct AIResponse: Codable, Sendable {
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

    private let toolkitURL: String = {
        ProcessInfo.processInfo.environment["EXPO_PUBLIC_TOOLKIT_URL"] ?? ""
    }()

    func analyzeMessage(_ text: String, relationship: RelationshipType) async -> TranslationResult? {
        isAnalyzing = true
        errorMessage = nil
        defer { isAnalyzing = false }

        let systemPrompt = """
        あなたは人間関係の専門家であり、心理カウンセラーです。
        ユーザーが送ってきたメッセージや会話文を分析し、以下の形式でJSON形式で回答してください。

        関係性: \(relationship.displayName)

        必ず以下のJSON形式で回答してください。他のテキストは一切含めないでください：
        {
            "honne": "相手の本音（本当に言いたいこと、隠された感情）を詳しく説明",
            "psychologicalState": "相手の心理状態を詳しく分析（不安、怒り、寂しさ、期待など）",
            "suggestedResponse": "この状況で最適な返答の例を具体的に提案",
            "emotionLevel": 1〜5の数字（1=穏やか、5=非常に感情的）
        }
        """

        let userMessage = "以下のメッセージを分析してください：\n\n\(text)"

        do {
            guard !toolkitURL.isEmpty else {
                errorMessage = "AIサービスのURLが設定されていません。"
                return nil
            }

            guard let url = URL(string: "\(toolkitURL)/agent/chat") else {
                errorMessage = "AIサービスに接続できません。"
                return nil
            }

            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.timeoutInterval = 60

            let body: [String: Any] = [
                "messages": [
                    ["role": "system", "content": systemPrompt],
                    ["role": "user", "content": userMessage]
                ]
            ]

            request.httpBody = try JSONSerialization.data(withJSONObject: body)

            let (data, response) = try await URLSession.shared.data(for: request)

            guard let httpResponse = response as? HTTPURLResponse else {
                errorMessage = "サーバーからの応答が無効です。もう一度お試しください。"
                return nil
            }

            let responseText = String(data: data, encoding: .utf8) ?? ""

            guard (200...299).contains(httpResponse.statusCode) else {
                print("[AIService] HTTP \(httpResponse.statusCode): \(responseText)")
                if httpResponse.statusCode == 500 {
                    errorMessage = "AI分析サーバーでエラーが発生しました。しばらくしてからもう一度お試しください。"
                } else {
                    errorMessage = "サーバーエラー(\(httpResponse.statusCode))が発生しました。もう一度お試しください。"
                }
                return nil
            }

            let extractedText = parseDataStreamResponse(responseText)
            let jsonString = extractJSON(from: extractedText)

            guard let jsonData = jsonString.data(using: .utf8) else {
                errorMessage = "応答の解析に失敗しました。もう一度お試しください。"
                return nil
            }

            let aiResponse = try JSONDecoder().decode(AIResponse.self, from: jsonData)

            return TranslationResult(
                originalText: text,
                relationship: relationship,
                honne: aiResponse.honne,
                psychologicalState: aiResponse.psychologicalState,
                suggestedResponse: aiResponse.suggestedResponse,
                emotionLevel: min(5, max(1, aiResponse.emotionLevel))
            )
        } catch {
            print("[AIService] Error: \(error)")
            errorMessage = "分析中にエラーが発生しました。もう一度お試しください。"
            return nil
        }
    }

    private func parseDataStreamResponse(_ raw: String) -> String {
        var result = ""
        let lines = raw.components(separatedBy: "\n")
        for line in lines {
            let trimmed = line.trimmingCharacters(in: .whitespaces)
            if trimmed.hasPrefix("0:") {
                let jsonPart = String(trimmed.dropFirst(2))
                if let partData = jsonPart.data(using: .utf8),
                   let text = try? JSONDecoder().decode(String.self, from: partData) {
                    result += text
                }
            }
        }
        if result.isEmpty {
            return raw
        }
        return result
    }

    private func extractJSON(from text: String) -> String {
        if let start = text.firstIndex(of: "{"),
           let end = text.lastIndex(of: "}") {
            return String(text[start...end])
        }
        return text
    }
}
