//
//  ContentView.swift
//  PortfolioApp
//
//  Created by Joseph Allen Blessman on 4/13/26.
//

import SwiftUI

struct ContentView: View {
    @State private var session: AccountSessionStore
    @State private var portfolioStore: PortfolioStore?
    @State private var appearanceStore: PortfolioAppearanceStore?
    @State private var showFeatureGuide = false

    init() {
        let session = AccountSessionStore()
        _session = State(initialValue: session)
        if let id = session.currentAccountId, let account = session.account(id: id) {
            if account.usesShowcaseSeed {
                ResumeRolodexStore.migrateLegacyPayloadIfNeeded(accountId: account.id)
            }
            _portfolioStore = State(
                initialValue: PortfolioStore(
                    accountId: account.id,
                    seedShowcase: account.usesShowcaseSeed,
                    starterDisplayName: account.displayName
                )
            )
            _appearanceStore = State(initialValue: PortfolioAppearanceStore(accountId: account.id))
        } else {
            _portfolioStore = State(initialValue: nil)
            _appearanceStore = State(initialValue: nil)
        }
    }

    var body: some View {
        Group {
            if session.isSignedIn, let portfolioStore, let appearanceStore {
                MainTabView()
                    .environment(session)
                    .environment(portfolioStore)
                    .environment(appearanceStore)
                    .environment(\.activeAccountId, session.currentAccountId)
                    .id(session.currentAccountId)
                    .fullScreenCover(isPresented: $showFeatureGuide) {
                        if let accountId = session.currentAccountId {
                            OnboardingGuideView(accountId: accountId) {
                                showFeatureGuide = false
                            }
                        }
                    }
                    .onAppear {
                        presentFeatureGuideIfNeededForCurrentAccount()
                    }
                    .onChange(of: session.featureGuidePresentationTrigger) { _, _ in
                        if session.isSignedIn {
                            showFeatureGuide = true
                        }
                    }
            } else {
                AccountGateView()
                    .environment(session)
            }
        }
        .onChange(of: session.currentAccountId) { _, newId in
            guard let newId, let account = session.account(id: newId) else {
                portfolioStore = nil
                appearanceStore = nil
                return
            }
            if account.usesShowcaseSeed {
                ResumeRolodexStore.migrateLegacyPayloadIfNeeded(accountId: account.id)
            }
            portfolioStore = PortfolioStore(
                accountId: account.id,
                seedShowcase: account.usesShowcaseSeed,
                starterDisplayName: account.displayName
            )
            appearanceStore = PortfolioAppearanceStore(accountId: account.id)
            presentFeatureGuideIfNeededForCurrentAccount()
        }
    }

    private func presentFeatureGuideIfNeededForCurrentAccount() {
        guard let id = session.currentAccountId else { return }
        if OnboardingGuideState.hasCompleted(accountId: id) == false {
            showFeatureGuide = true
        }
    }
}

#Preview {
    ContentView()
}
