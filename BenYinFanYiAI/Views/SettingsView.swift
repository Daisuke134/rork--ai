import SwiftUI

struct SettingsView: View {
    @Environment(SubscriptionService.self) private var subscriptionService
    @State private var showPaywall = false

    var body: some View {
        NavigationStack {
            List {
                subscriptionSection
                aboutSection
                legalSection
            }
            .listStyle(.insetGrouped)
            .navigationTitle("設定")
            .navigationBarTitleDisplayMode(.large)
            .sheet(isPresented: $showPaywall) {
                PaywallView()
            }
        }
    }

    private var subscriptionSection: some View {
        Section {
            if subscriptionService.isPremium {
                HStack(spacing: 12) {
                    Image(systemName: "crown.fill")
                        .font(.title3)
                        .foregroundStyle(.yellow)
                    VStack(alignment: .leading, spacing: 2) {
                        Text("プレミアム会員")
                            .font(.headline)
                        Text("全ての機能が利用可能です")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
                .padding(.vertical, 4)
            } else {
                Button {
                    showPaywall = true
                } label: {
                    HStack(spacing: 12) {
                        Image(systemName: "crown.fill")
                            .font(.title3)
                            .foregroundStyle(.purple)
                        VStack(alignment: .leading, spacing: 2) {
                            Text("プレミアムにアップグレード")
                                .font(.headline)
                            Text("無制限の翻訳と詳細分析")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        Spacer()
                        Image(systemName: "chevron.right")
                            .font(.caption)
                            .foregroundStyle(.tertiary)
                    }
                }
                .padding(.vertical, 4)
            }

            Button {
                Task { await subscriptionService.restorePurchases() }
            } label: {
                Label("購入を復元", systemImage: "arrow.clockwise")
            }
        } header: {
            Text("サブスクリプション")
        }
    }

    private var aboutSection: some View {
        Section {
            HStack {
                Text("バージョン")
                Spacer()
                Text("1.0.0")
                    .foregroundStyle(.secondary)
            }
        } header: {
            Text("アプリ情報")
        }
    }

    private var legalSection: some View {
        Section {
            Link(destination: URL(string: "https://www.apple.com/legal/internet-services/itunes/dev/stdeula/")!) {
                Label("利用規約", systemImage: "doc.text")
            }
            Link(destination: URL(string: "https://www.apple.com/legal/privacy/")!) {
                Label("プライバシーポリシー", systemImage: "hand.raised")
            }
        } header: {
            Text("法的情報")
        }
    }
}
