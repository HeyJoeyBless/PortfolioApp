//
//  OnboardingGuideView.swift
//  PortfolioApp
//

import SwiftUI

enum OnboardingGuideState {
    private static func storageKey(accountId: UUID) -> String {
        "portfolio.featureGuide.done.v1.\(accountId.uuidString)"
    }

    static func hasCompleted(accountId: UUID) -> Bool {
        UserDefaults.standard.bool(forKey: storageKey(accountId: accountId))
    }

    static func markCompleted(accountId: UUID) {
        UserDefaults.standard.set(true, forKey: storageKey(accountId: accountId))
    }
}

private struct GuidePage {
    let symbol: String
    let title: String
    let detail: String
}

struct OnboardingGuideView: View {
    let accountId: UUID
    var onFinished: () -> Void

    @State private var pageIndex = 0

    private let pages: [GuidePage] = [
        GuidePage(
            symbol: "sparkles.rectangle.stack",
            title: "Welcome",
            detail: "This app is your portfolio on the go — home story, skills, projects, journey, resume tools, and profile settings. Swipe through this short tour, or skip anytime."
        ),
        GuidePage(
            symbol: "house.fill",
            title: "Home",
            detail: "Your hero card, practice streak, focus areas, and a featured GitHub project help visitors understand you in one scroll."
        ),
        GuidePage(
            symbol: "square.grid.2x2.fill",
            title: "Skills",
            detail: "Each skill shows proficiency, rank, and Paul Hudson–style topics you can talk about in interviews. Tap through to related projects."
        ),
        GuidePage(
            symbol: "folder.fill",
            title: "Projects",
            detail: "A timeline of your repos and work, oldest to newest, with one-tap links to GitHub for demos and reviews."
        ),
        GuidePage(
            symbol: "map.fill",
            title: "Journey",
            detail: "Check off milestones as you grow — great for academy narratives and where you are headed next."
        ),
        GuidePage(
            symbol: "doc.text.fill",
            title: "Resume",
            detail: "Scan resume and cover pages from photos, edit text, flip between resume types, tailor drafts, then print or share."
        ),
        GuidePage(
            symbol: "ellipsis.circle.fill",
            title: "More & profile",
            detail: "Profile: customize accent and backdrop, import a background photo, switch people on this device, or sign out. More tab (next to Resume): reopen this feature guide anytime."
        )
    ]

    private var isLastPage: Bool { pageIndex >= pages.count - 1 }

    var body: some View {
        ZStack {
            AppTheme.heroGradient
                .ignoresSafeArea()

            VStack(spacing: 0) {
                HStack {
                    Button("Skip") {
                        finish()
                    }
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.white.opacity(0.92))

                    Spacer()

                    Text("\(pageIndex + 1) / \(pages.count)")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.white.opacity(0.75))
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)
                .padding(.bottom, 8)

                TabView(selection: $pageIndex) {
                    ForEach(Array(pages.enumerated()), id: \.offset) { index, page in
                        pageCard(page)
                            .tag(index)
                            .padding(.horizontal, 20)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .always))
                .indexViewStyle(.page(backgroundDisplayMode: .always))

                HStack(spacing: 14) {
                    if pageIndex > 0 {
                        Button {
                            withAnimation { pageIndex -= 1 }
                        } label: {
                            Text("Back")
                                .font(.headline)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 14)
                                .background(.white.opacity(0.18), in: RoundedRectangle(cornerRadius: 14, style: .continuous))
                        }
                        .foregroundStyle(.white)
                    }

                    Button {
                        if isLastPage {
                            finish()
                        } else {
                            withAnimation { pageIndex += 1 }
                        }
                    } label: {
                        Text(isLastPage ? "Get started" : "Next")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(.white, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
                            .foregroundStyle(AppTheme.ink)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 20)
            }
        }
        .interactiveDismissDisabled()
    }

    private func pageCard(_ page: GuidePage) -> some View {
        VStack(spacing: 20) {
            Spacer(minLength: 8)

            Image(systemName: page.symbol)
                .font(.system(size: 52, weight: .medium))
                .foregroundStyle(.white)
                .symbolRenderingMode(.hierarchical)
                .padding(28)
                .background(.white.opacity(0.12), in: Circle())
                .accessibilityHidden(true)

            Text(page.title)
                .font(.title.weight(.bold))
                .foregroundStyle(.white)
                .multilineTextAlignment(.center)

            Text(page.detail)
                .font(.body)
                .foregroundStyle(.white.opacity(0.88))
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.horizontal, 4)

            Spacer(minLength: 8)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private func finish() {
        OnboardingGuideState.markCompleted(accountId: accountId)
        onFinished()
    }
}

#Preview {
    OnboardingGuideView(accountId: UUID(), onFinished: {})
}
