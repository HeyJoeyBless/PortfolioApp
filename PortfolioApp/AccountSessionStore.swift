//
//  AccountSessionStore.swift
//  PortfolioApp
//

import Foundation
import Observation
import SwiftUI

struct DeviceAccount: Identifiable, Codable, Equatable, Sendable {
    var id: UUID
    var displayName: String
    /// First device owner gets the bundled academy portfolio; additional people start from a blank template.
    var usesShowcaseSeed: Bool
}

private struct SessionPayload: Codable {
    var accounts: [DeviceAccount]
    var currentAccountId: UUID?
}

@Observable
@MainActor
final class AccountSessionStore {
    private static let storageKey = "portfolio.deviceAccounts.v1"

    private(set) var accounts: [DeviceAccount]
    private(set) var currentAccountId: UUID?

    /// Incremented from Profile → More to reopen the feature guide anytime.
    private(set) var featureGuidePresentationTrigger: UInt = 0

    var isSignedIn: Bool { currentAccountId != nil }

    var currentAccount: DeviceAccount? {
        guard let currentAccountId else { return nil }
        return accounts.first { $0.id == currentAccountId }
    }

    init() {
        if let data = UserDefaults.standard.data(forKey: Self.storageKey),
           let decoded = try? JSONDecoder().decode(SessionPayload.self, from: data) {
            accounts = decoded.accounts
            currentAccountId = decoded.currentAccountId
            if let id = currentAccountId, accounts.contains(where: { $0.id == id }) == false {
                currentAccountId = nil
            }
        } else {
            let primary = DeviceAccount(
                id: UUID(),
                displayName: "Joseph A. Blessman",
                usesShowcaseSeed: true
            )
            accounts = [primary]
            currentAccountId = primary.id
            persist()
        }
    }

    func account(id: UUID) -> DeviceAccount? {
        accounts.first { $0.id == id }
    }

    func signIn(accountId: UUID) {
        guard accounts.contains(where: { $0.id == accountId }) else { return }
        currentAccountId = accountId
        persist()
    }

    func signOut() {
        currentAccountId = nil
        persist()
    }

    @discardableResult
    func addAccount(displayName: String) -> DeviceAccount {
        let trimmed = displayName.trimmingCharacters(in: .whitespacesAndNewlines)
        let name = trimmed.isEmpty ? "Guest" : trimmed
        let account = DeviceAccount(id: UUID(), displayName: name, usesShowcaseSeed: false)
        accounts.append(account)
        persist()
        return account
    }

    func removeAccount(id: UUID) {
        guard accounts.count > 1 else { return }
        accounts.removeAll { $0.id == id }
        if currentAccountId == id {
            currentAccountId = accounts.first?.id
        }
        persist()
    }

    func renameAccount(id: UUID, to displayName: String) {
        let trimmed = displayName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard let i = accounts.firstIndex(where: { $0.id == id }) else { return }
        accounts[i].displayName = trimmed.isEmpty ? accounts[i].displayName : trimmed
        persist()
    }

    func requestFeatureGuide() {
        featureGuidePresentationTrigger += 1
    }

    private func persist() {
        let payload = SessionPayload(accounts: accounts, currentAccountId: currentAccountId)
        if let data = try? JSONEncoder().encode(payload) {
            UserDefaults.standard.set(data, forKey: Self.storageKey)
        }
    }
}

// MARK: - Active account for scoped stores (e.g. Resume rolodex)

private struct ActiveAccountIdKey: EnvironmentKey {
    static var defaultValue: UUID? { nil }
}

extension EnvironmentValues {
    var activeAccountId: UUID? {
        get { self[ActiveAccountIdKey.self] }
        set { self[ActiveAccountIdKey.self] = newValue }
    }
}
