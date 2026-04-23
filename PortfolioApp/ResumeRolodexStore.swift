//
//  ResumeRolodexStore.swift
//  PortfolioApp
//

import Foundation
import Observation

struct ResumeCard: Identifiable, Codable, Equatable {
    var id: UUID
    var title: String
    var resumeText: String
    var coverLetterText: String
    var tailoredResumeText: String
}

private struct ResumeRolodexPayload: Codable {
    var cards: [ResumeCard]
    var selectedCardId: UUID
}

@Observable
@MainActor
final class ResumeRolodexStore {
    let accountId: UUID
    private let storageKey: String

    /// Moves pre–multi-user `UserDefaults` data into this account’s key once.
    static func migrateLegacyPayloadIfNeeded(accountId: UUID) {
        let legacyKey = "resumeRolodex.payload.v1"
        let newKey = "resumeRolodex.payload.v1.\(accountId.uuidString)"
        guard UserDefaults.standard.data(forKey: newKey) == nil,
              let data = UserDefaults.standard.data(forKey: legacyKey) else { return }
        UserDefaults.standard.set(data, forKey: newKey)
        UserDefaults.standard.removeObject(forKey: legacyKey)
    }

    var cards: [ResumeCard] {
        didSet { persist() }
    }

    var selectedCardId: UUID {
        didSet { persist() }
    }

    init(accountId: UUID) {
        self.accountId = accountId
        storageKey = "resumeRolodex.payload.v1.\(accountId.uuidString)"
        let loadedCards: [ResumeCard]
        let loadedSelected: UUID

        if let data = UserDefaults.standard.data(forKey: storageKey),
           let payload = try? JSONDecoder().decode(ResumeRolodexPayload.self, from: data),
           payload.cards.isEmpty == false {
            loadedCards = payload.cards
            loadedSelected = payload.cards.contains(where: { $0.id == payload.selectedCardId })
                ? payload.selectedCardId
                : payload.cards[0].id
        } else {
            let first = ResumeCard(
                id: UUID(),
                title: "General",
                resumeText: "",
                coverLetterText: "",
                tailoredResumeText: ""
            )
            loadedCards = [first]
            loadedSelected = first.id
        }

        cards = loadedCards
        selectedCardId = loadedSelected
    }

    func card(id: UUID) -> ResumeCard? {
        cards.first { $0.id == id }
    }

    func updateCard(id: UUID, resumeText: String? = nil, coverLetterText: String? = nil, tailoredResumeText: String? = nil, title: String? = nil) {
        guard let idx = cards.firstIndex(where: { $0.id == id }) else { return }
        if let resumeText { cards[idx].resumeText = resumeText }
        if let coverLetterText { cards[idx].coverLetterText = coverLetterText }
        if let tailoredResumeText { cards[idx].tailoredResumeText = tailoredResumeText }
        if let title { cards[idx].title = title }
    }

    func addCard(named title: String) {
        let card = ResumeCard(
            id: UUID(),
            title: title,
            resumeText: "",
            coverLetterText: "",
            tailoredResumeText: ""
        )
        cards.append(card)
        selectedCardId = card.id
    }

    func removeCard(id: UUID) {
        guard cards.count > 1 else { return }
        cards.removeAll { $0.id == id }
        if selectedCardId == id {
            selectedCardId = cards[0].id
        }
    }

    private func persist() {
        let payload = ResumeRolodexPayload(cards: cards, selectedCardId: selectedCardId)
        if let data = try? JSONEncoder().encode(payload) {
            UserDefaults.standard.set(data, forKey: storageKey)
        }
    }
}
