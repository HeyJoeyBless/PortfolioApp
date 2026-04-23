//
//  MoreView.swift
//  PortfolioApp
//

import SwiftUI

struct MoreView: View {
    @Environment(AccountSessionStore.self) private var session

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                GlassCard {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Help")
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(.secondary)

                        Text("Walk through what each tab does — same tour as the first time you open the app for this profile.")
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                            .fixedSize(horizontal: false, vertical: true)

                        Button {
                            session.requestFeatureGuide()
                        } label: {
                            Label("Open feature guide", systemImage: "book.pages.fill")
                                .font(.headline)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 14)
                                .background(AppTheme.crimson, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
                                .foregroundStyle(.white)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
        }
        .portfolioScreenBackground()
        .navigationTitle("More")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    let id = UUID()
    NavigationStack {
        MoreView()
            .environment(AccountSessionStore())
            .environment(PortfolioAppearanceStore(accountId: id))
    }
}
