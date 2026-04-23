//
//  PortfolioData.swift
//  PortfolioApp
//

import Foundation

enum SkillRank: String, CaseIterable, Codable, Comparable, Sendable {
    case novice = "Novice"
    case disciple = "Disciple"
    case adept = "Adept"
    case master = "Master"

    static func < (lhs: SkillRank, rhs: SkillRank) -> Bool {
        lhs.sortOrder < rhs.sortOrder
    }

    private var sortOrder: Int {
        switch self {
        case .novice: 0
        case .disciple: 1
        case .adept: 2
        case .master: 3
        }
    }

    var systemImage: String {
        switch self {
        case .novice: "leaf"
        case .disciple: "figure.martial.arts"
        case .adept: "flame"
        case .master: "seal.fill"
        }
    }
}

struct PortfolioProfile: Codable, Sendable, Equatable {
    var name: String
    var title: String
    var tagline: String
    var academyLine: String
    var focusAreas: [String]
    var location: String?
    var githubProfileURL: URL
    var linkedInURL: URL?
    var blogURL: URL?
    /// Shown on the Connect button (e.g. your WordPress site title).
    var blogTitle: String?
}

struct PortfolioSkill: Identifiable, Hashable, Codable, Sendable {
    let id: UUID
    var title: String
    var summary: String
    var proficiency: Double
    var rank: SkillRank
    var symbolName: String
    var paulHudsonTopics: [String]
    var relatedProjectIDs: [UUID]

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    static func == (lhs: PortfolioSkill, rhs: PortfolioSkill) -> Bool {
        lhs.id == rhs.id
    }
}

struct PortfolioProject: Identifiable, Hashable, Codable, Sendable {
    let id: UUID
    var name: String
    var tagline: String
    var role: String
    var highlights: [String]
    var symbolName: String
    var techStack: [String]
    /// Public GitHub repository; opens in Safari when set.
    var repositoryURL: URL?
    var isFork: Bool
    /// Ascending order: oldest work first (timeline in the Projects tab).
    var timelineOrder: Int
    /// Short label for the timeline (e.g. academy phase).
    var timelineCaption: String

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    static func == (lhs: PortfolioProject, rhs: PortfolioProject) -> Bool {
        lhs.id == rhs.id
    }
}

struct JourneyStep: Identifiable, Hashable, Codable, Sendable {
    let id: UUID
    var title: String
    var caption: String
    var isComplete: Bool
    var order: Int

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    static func == (lhs: JourneyStep, rhs: JourneyStep) -> Bool {
        lhs.id == rhs.id
    }
}
