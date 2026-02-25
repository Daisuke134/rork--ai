import SwiftUI

struct OnboardingView: View {
    @State private var currentPage = 0
    @State private var showPaywall = false
    let onComplete: () -> Void

    private let pages: [OnboardingPage] = [
        OnboardingPage(
            icon: "brain.head.profile.fill",
            iconColor: .purple,
            title: "本音を見抜く",
            subtitle: "LINEや会話文を入力するだけで\nAIが相手の隠された本音を分析します",
            gradient: [.purple.opacity(0.2), .indigo.opacity(0.15)]
        ),
        OnboardingPage(
            icon: "heart.text.clipboard.fill",
            iconColor: .orange,
            title: "心理状態を把握",
            subtitle: "怒り・不安・寂しさ・期待…\n相手の感情を深く理解できます",
            gradient: [.orange.opacity(0.2), .red.opacity(0.1)]
        ),
        OnboardingPage(
            icon: "bubble.left.and.text.bubble.right.fill",
            iconColor: .green,
            title: "最適な返答を提案",
            subtitle: "関係を壊さない返し方を\nAIが具体的にアドバイスします",
            gradient: [.green.opacity(0.2), .teal.opacity(0.1)]
        )
    ]

    var body: some View {
        VStack(spacing: 0) {
            TabView(selection: $currentPage) {
                ForEach(Array(pages.enumerated()), id: \.offset) { index, page in
                    pageView(page)
                        .tag(index)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .animation(.easeInOut(duration: 0.3), value: currentPage)

            bottomSection
        }
        .ignoresSafeArea(edges: .top)
        .sheet(isPresented: $showPaywall, onDismiss: {
            onComplete()
        }) {
            PaywallView()
        }
    }

    private func pageView(_ page: OnboardingPage) -> some View {
        VStack(spacing: 0) {
            Spacer()

            ZStack {
                RoundedRectangle(cornerRadius: 32)
                    .fill(
                        LinearGradient(
                            colors: page.gradient,
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 160, height: 160)

                Image(systemName: page.icon)
                    .font(.system(size: 64))
                    .foregroundStyle(page.iconColor)
                    .symbolEffect(.pulse, options: .repeating)
            }
            .padding(.bottom, 40)

            Text(page.title)
                .font(.largeTitle.bold())
                .multilineTextAlignment(.center)
                .padding(.bottom, 16)

            Text(page.subtitle)
                .font(.body)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .lineSpacing(4)
                .padding(.horizontal, 32)

            Spacer()
            Spacer()
        }
    }

    private var bottomSection: some View {
        VStack(spacing: 20) {
            HStack(spacing: 8) {
                ForEach(0..<pages.count, id: \.self) { index in
                    Capsule()
                        .fill(index == currentPage ? Color.accentColor : Color(.tertiaryLabel))
                        .frame(width: index == currentPage ? 24 : 8, height: 8)
                        .animation(.spring(response: 0.3), value: currentPage)
                }
            }

            Button {
                if currentPage < pages.count - 1 {
                    withAnimation { currentPage += 1 }
                } else {
                    showPaywall = true
                }
            } label: {
                Text(currentPage < pages.count - 1 ? "次へ" : "はじめる")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
            }
            .buttonStyle(.borderedProminent)
            .clipShape(.rect(cornerRadius: 14))
            .padding(.horizontal, 24)

            if currentPage < pages.count - 1 {
                Button {
                    showPaywall = true
                } label: {
                    Text("スキップ")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            } else {
                Color.clear.frame(height: 20)
            }
        }
        .padding(.bottom, 16)
    }
}

nonisolated struct OnboardingPage: Sendable {
    let icon: String
    let iconColor: Color
    let title: String
    let subtitle: String
    let gradient: [Color]
}
