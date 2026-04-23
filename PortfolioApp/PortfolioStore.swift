//
//  PortfolioStore.swift
//  PortfolioApp
//

import Foundation
import Observation

private struct PortfolioPersistedPayload: Codable {
    var profile: PortfolioProfile
    var skills: [PortfolioSkill]
    var projects: [PortfolioProject]
    var journeySteps: [JourneyStep]
    var practiceStreak: Int
    var lastPracticeDayEpoch: Double?
}

@Observable
final class PortfolioStore {
    let accountId: UUID

    var profile: PortfolioProfile
    var skills: [PortfolioSkill]
    var projects: [PortfolioProject]
    var journeySteps: [JourneyStep]

    var practiceStreak: Int

    private var lastPracticeDayStart: Date?

    init(accountId: UUID, seedShowcase: Bool, starterDisplayName: String) {
        self.accountId = accountId
        let snapshotKey = Self.snapshotStorageKey(accountId)

        if let data = UserDefaults.standard.data(forKey: snapshotKey),
           let payload = try? JSONDecoder().decode(PortfolioPersistedPayload.self, from: data) {
            profile = payload.profile
            skills = payload.skills
            projects = payload.projects
            journeySteps = payload.journeySteps.sorted { $0.order < $1.order }
            practiceStreak = payload.practiceStreak
            lastPracticeDayStart = payload.lastPracticeDayEpoch.map { Date(timeIntervalSince1970: $0) }
            return
        }

        if seedShowcase {
            let payload = Self.makeShowcasePayload()
            profile = payload.profile
            skills = payload.skills
            projects = payload.projects
            journeySteps = payload.journeySteps.sorted { $0.order < $1.order }
            practiceStreak = Self.migrateLegacyStreakIfNeeded(fallback: payload.practiceStreak)
            lastPracticeDayStart = Self.migrateLegacyLastDayIfNeeded()
        } else {
            let payload = Self.makeStarterPayload(displayName: starterDisplayName)
            profile = payload.profile
            skills = payload.skills
            projects = payload.projects
            journeySteps = payload.journeySteps.sorted { $0.order < $1.order }
            practiceStreak = payload.practiceStreak
            lastPracticeDayStart = nil
        }
        saveSnapshot()
    }

    func saveSnapshot() {
        let payload = PortfolioPersistedPayload(
            profile: profile,
            skills: skills,
            projects: projects,
            journeySteps: journeySteps,
            practiceStreak: practiceStreak,
            lastPracticeDayEpoch: lastPracticeDayStart?.timeIntervalSince1970
        )
        guard let data = try? JSONEncoder().encode(payload) else { return }
        UserDefaults.standard.set(data, forKey: Self.snapshotStorageKey(accountId))
    }

    private static func snapshotStorageKey(_ accountId: UUID) -> String {
        "portfolio.snapshot.v1.\(accountId.uuidString)"
    }

    private static func migrateLegacyStreakIfNeeded(fallback: Int) -> Int {
        let legacy = UserDefaults.standard.integer(forKey: "portfolio.practiceStreak")
        if legacy > 0, fallback == 0 {
            return legacy
        }
        return fallback
    }

    private static func migrateLegacyLastDayIfNeeded() -> Date? {
        let t = UserDefaults.standard.double(forKey: "portfolio.lastPracticeDay")
        guard t > 0 else { return nil }
        return Date(timeIntervalSince1970: t)
    }

    func refreshPracticeStreakIfNeeded() {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        guard let last = lastPracticeDayStart else {
            lastPracticeDayStart = today
            if practiceStreak < 1 { practiceStreak = 1 }
            saveSnapshot()
            return
        }

        if calendar.isDate(last, inSameDayAs: today) {
            return
        }

        if let yesterday = calendar.date(byAdding: .day, value: -1, to: today),
           calendar.isDate(last, inSameDayAs: yesterday) {
            practiceStreak += 1
        } else {
            practiceStreak = 1
        }
        lastPracticeDayStart = today
        saveSnapshot()
    }

    func averageProficiency() -> Double {
        guard !skills.isEmpty else { return 0 }
        return skills.map(\.proficiency).reduce(0, +) / Double(skills.count)
    }

    func journeyProgress() -> Double {
        guard !journeySteps.isEmpty else { return 0 }
        let done = journeySteps.filter(\.isComplete).count
        return Double(done) / Double(journeySteps.count)
    }

    func projects(for skill: PortfolioSkill) -> [PortfolioProject] {
        projects
            .filter { skill.relatedProjectIDs.contains($0.id) }
            .sorted { $0.timelineOrder < $1.timelineOrder }
    }

    /// Academy & profile work, oldest → newest.
    var projectsTimeline: [PortfolioProject] {
        projects.sorted { $0.timelineOrder < $1.timelineOrder }
    }

    /// Home spotlight: strong demo repo (tvOS gallery), else latest timeline project with a URL.
    var featuredGitHubProject: PortfolioProject? {
        if let atelier = projectsTimeline.first(where: { $0.name == "AtelierArchive" }) {
            return atelier
        }
        return projectsTimeline.reversed().first { $0.repositoryURL != nil && $0.name != "HeyJoeyBless" }
    }

    func toggleJourneyStep(_ step: JourneyStep) {
        guard let i = journeySteps.firstIndex(where: { $0.id == step.id }) else { return }
        journeySteps[i].isComplete.toggle()
        saveSnapshot()
    }

    // MARK: - Seeds

    private static func makeStarterPayload(displayName: String) -> PortfolioPersistedPayload {
        let projectId = UUID()
        let profile = PortfolioProfile(
            name: displayName,
            title: "Your role or focus",
            tagline: "This is a fresh portfolio on this device — customize your story in code or future editor tools.",
            academyLine: "Add projects and skills that match how you build.",
            focusAreas: ["Swift", "SwiftUI", "Your stack"],
            location: nil,
            githubProfileURL: URL(string: "https://github.com")!,
            linkedInURL: nil,
            blogURL: nil,
            blogTitle: nil
        )
        let project = PortfolioProject(
            id: projectId,
            name: "Your first repo",
            tagline: "Link a public GitHub project when you are ready.",
            role: "Author",
            highlights: [
                "Replace this card with a real repository from the Projects area in code"
            ],
            symbolName: "shippingbox.fill",
            techStack: ["Swift"],
            repositoryURL: nil,
            isFork: false,
            timelineOrder: 0,
            timelineCaption: "Start here"
        )
        let skill = PortfolioSkill(
            id: UUID(),
            title: "Building in public",
            summary: "Ship small, iterate, and keep a trail recruiters can follow.",
            proficiency: 0.5,
            rank: .novice,
            symbolName: "sparkles",
            paulHudsonTopics: [
                "NavigationStack",
                "Lists & forms",
                "Previews"
            ],
            relatedProjectIDs: [projectId]
        )
        let steps = [
            JourneyStep(id: UUID(), title: "Set up GitHub", caption: "Point the profile URL and first project to real repos.", isComplete: false, order: 0),
            JourneyStep(id: UUID(), title: "Tell your story", caption: "Skills and journey steps are yours to extend.", isComplete: false, order: 1)
        ]
        return PortfolioPersistedPayload(
            profile: profile,
            skills: [skill],
            projects: [project],
            journeySteps: steps,
            practiceStreak: 0,
            lastPracticeDayEpoch: nil
        )
    }

    private static func makeShowcasePayload() -> PortfolioPersistedPayload {
        let gh = URL(string: "https://github.com/HeyJoeyBless")!

        let profile = PortfolioProfile(
            name: "Joseph A. Blessman",
            title: "Junior developer · iPhone & Apple TV",
            tagline: "Student in the Apple Developer Academy — Swift in production, plus Python & C++ in progress.",
            academyLine: "Projects in the order I built them at the Academy — this app is the graduation piece.",
            focusAreas: ["Swift & SwiftUI", "tvOS", "Academy challenges", "Python", "C++"],
            location: "Detroit, MI",
            githubProfileURL: gh,
            linkedInURL: URL(string: "https://www.linkedin.com/in/jabonpurpose/"),
            blogURL: URL(string: "https://joeyb14.wordpress.com"),
            blogTitle: "The Perspective"
        )

        let projectPortfolio = UUID()
        let projectAtelier = UUID()
        let projectNowThen = UUID()
        let projectMoneyMan = UUID()
        let projectTicTac = UUID()
        let projectChallenge1 = UUID()
        let projectReadme = UUID()

        func repo(_ name: String) -> URL {
            URL(string: "https://github.com/HeyJoeyBless/\(name)")!
        }

        let projects: [PortfolioProject] = [
            PortfolioProject(
                id: projectChallenge1,
                name: "challenge-1",
                tagline: "Your first challenge in the Apple Developer Academy.",
                role: "Academy",
                highlights: [
                    "Foundation milestone in the ADA curriculum",
                    "Anchor for how far you’ve come in the journey tab"
                ],
                symbolName: "flag.checkered",
                techStack: ["Swift"],
                repositoryURL: repo("challenge-1"),
                isFork: false,
                timelineOrder: 0,
                timelineCaption: "Where it started · Academy Challenge 1"
            ),
            PortfolioProject(
                id: projectAtelier,
                name: "AtelierArchive",
                tagline: "A tvOS app that showcases portfolios in a digital gallery immersive experience.",
                role: "Contributor (fork)",
                highlights: [
                    "Swift · Apple TV experience",
                    "Forked from hamzacrichlow/AtelierArchive — extended for academy work"
                ],
                symbolName: "tv.fill",
                techStack: ["Swift", "tvOS"],
                repositoryURL: repo("AtelierArchive"),
                isFork: true,
                timelineOrder: 1,
                timelineCaption: "tvOS · immersive portfolio gallery"
            ),
            PortfolioProject(
                id: projectTicTac,
                name: "TICTACTOE-Completed-",
                tagline: "The Domination squad’s tic-tac-toe game in command-line Swift.",
                role: "Team project",
                highlights: [
                    "Command-line Swift logic and squad delivery",
                    "Shows fundamentals and squad shipping"
                ],
                symbolName: "square.grid.3x3.fill",
                techStack: ["Swift"],
                repositoryURL: repo("TICTACTOE-Completed-"),
                isFork: false,
                timelineOrder: 2,
                timelineCaption: "Team sprint · command-line Swift"
            ),
            PortfolioProject(
                id: projectNowThen,
                name: "Now-Then",
                tagline: "Swift project on GitHub — part of your public portfolio.",
                role: "Author",
                highlights: [
                    "Public Swift repository under HeyJoeyBless",
                    "Pairs well with a journaling or reflection narrative in interviews"
                ],
                symbolName: "clock.arrow.circlepath",
                techStack: ["Swift"],
                repositoryURL: repo("Now-Then"),
                isFork: false,
                timelineOrder: 3,
                timelineCaption: "Then · Now-Then in Swift"
            ),
            PortfolioProject(
                id: projectMoneyMan,
                name: "Money-manGame-Incomplete-",
                tagline: "ADA Challenge #5 — a Pac-Man–style game built in Swift.",
                role: "Team / academy challenge",
                highlights: [
                    "Game loop and movement challenges in Swift",
                    "Great talking point for collaboration and iteration under deadlines"
                ],
                symbolName: "gamecontroller.fill",
                techStack: ["Swift"],
                repositoryURL: repo("Money-manGame-Incomplete-"),
                isFork: false,
                timelineOrder: 4,
                timelineCaption: "Academy Challenge #5 · arcade-style game"
            ),
            PortfolioProject(
                id: projectPortfolio,
                name: "Portfolio (this app)",
                tagline: "A living resume with journey, skills, and GitHub-backed projects.",
                role: "Graduation showcase",
                highlights: [
                    "Tabbed NavigationStack app with @Observable state",
                    "Timeline of Academy work with links to every public repo",
                    "Glass UI, streaks, and skill ranks for a memorable demo"
                ],
                symbolName: "sparkles.rectangle.stack",
                techStack: ["SwiftUI", "Observation", "UserDefaults"],
                repositoryURL: nil,
                isFork: false,
                timelineOrder: 5,
                timelineCaption: "Graduating the Academy · this app"
            ),
            PortfolioProject(
                id: projectReadme,
                name: "HeyJoeyBless",
                tagline: "GitHub profile README — pins, bio, and the story you show visitors first.",
                role: "Profile",
                highlights: [
                    "Public landing page for recruiters on GitHub",
                    "Links to LinkedIn, blog, and popular repositories"
                ],
                symbolName: "person.text.rectangle",
                techStack: ["Markdown"],
                repositoryURL: repo("HeyJoeyBless"),
                isFork: false,
                timelineOrder: 6,
                timelineCaption: "Always on · GitHub home"
            )
        ]

        let skills: [PortfolioSkill] = [
            PortfolioSkill(
                id: UUID(),
                title: "SwiftUI composition",
                summary: "Stacks, grids, and adaptive layouts across iPhone, iPad, and showcase apps.",
                proficiency: 0.88,
                rank: .adept,
                symbolName: "rectangle.3.group.fill",
                paulHudsonTopics: [
                    "VStack / HStack / ZStack",
                    "NavigationStack & navigationDestination",
                    "Lists, Forms, searchable"
                ],
                relatedProjectIDs: [projectPortfolio, projectAtelier, projectNowThen]
            ),
            PortfolioSkill(
                id: UUID(),
                title: "State & data flow",
                summary: "Observable models, environment injection, and predictable UI updates.",
                proficiency: 0.82,
                rank: .adept,
                symbolName: "arrow.triangle.branch",
                paulHudsonTopics: [
                    "@Observable macro",
                    "@Environment & @Bindable",
                    "UserDefaults / lightweight persistence"
                ],
                relatedProjectIDs: [projectPortfolio, projectNowThen]
            ),
            PortfolioSkill(
                id: UUID(),
                title: "Motion & games",
                summary: "Animation basics plus gameplay-adjacent Swift from academy challenges.",
                proficiency: 0.74,
                rank: .disciple,
                symbolName: "wind",
                paulHudsonTopics: [
                    "withAnimation & springs",
                    "Gameplay timing and feedback loops",
                    "SF Symbols motion where it fits"
                ],
                relatedProjectIDs: [projectMoneyMan, projectChallenge1]
            ),
            PortfolioSkill(
                id: UUID(),
                title: "Quality & shipping",
                summary: "Previews, accessibility, and habits from academy sprints.",
                proficiency: 0.7,
                rank: .disciple,
                symbolName: "checkmark.shield.fill",
                paulHudsonTopics: [
                    "#Preview macros",
                    "VoiceOver labels & Dynamic Type",
                    "XCTest & UITest mindset"
                ],
                relatedProjectIDs: [projectChallenge1, projectTicTac]
            )
        ]

        let journeySteps: [JourneyStep] = [
            JourneyStep(
                id: UUID(),
                title: "Foundations",
                caption: "Swift syntax, optionals, and thinking in types.",
                isComplete: true,
                order: 0
            ),
            JourneyStep(
                id: UUID(),
                title: "SwiftUI mental model",
                caption: "Declarative UI, state ownership, and preview-driven iteration.",
                isComplete: true,
                order: 1
            ),
            JourneyStep(
                id: UUID(),
                title: "Academy intensity",
                caption: "Team rituals, critiques, and shipping under real constraints.",
                isComplete: true,
                order: 2
            ),
            JourneyStep(
                id: UUID(),
                title: "Showcase portfolio",
                caption: "One polished surface that explains how you build.",
                isComplete: false,
                order: 3
            ),
            JourneyStep(
                id: UUID(),
                title: "Next chapter",
                caption: "Internship, indie app, or product team — keep the streak alive.",
                isComplete: false,
                order: 4
            )
        ]

        return PortfolioPersistedPayload(
            profile: profile,
            skills: skills,
            projects: projects,
            journeySteps: journeySteps,
            practiceStreak: 0,
            lastPracticeDayEpoch: nil
        )
    }
}
