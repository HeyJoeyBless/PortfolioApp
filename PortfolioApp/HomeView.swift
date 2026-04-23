//
//  HomeView.swift
//  PortfolioApp
//

import SwiftUI

struct HomeView: View {
    @Environment(PortfolioStore.self) private var store

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 22) {
                hero
                socialStrip
                streakCard
                statsRow
                focusChips
                featuredProject
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 28)
        }
        .portfolioScreenBackground()
        .navigationTitle("Home")
        .navigationBarTitleDisplayMode(.inline)
    }

    private var hero: some View {
        ZStack(alignment: .bottomLeading) {
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .fill(AppTheme.heroGradient)
                .frame(height: 200)
                .overlay {
                    LinearGradient(
                        colors: [.clear, .black.opacity(0.35)],
                        startPoint: .center,
                        endPoint: .bottom
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
                }

            VStack(alignment: .leading, spacing: 8) {
                Text(store.profile.name)
                    .font(.title2.weight(.bold))
                    .foregroundStyle(.white)
                Text(store.profile.title)
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(.white.opacity(0.88))
                if let location = store.profile.location {
                    Text(location)
                        .font(.caption.weight(.medium))
                        .foregroundStyle(.white.opacity(0.72))
                }
                Text(store.profile.tagline)
                    .font(.footnote)
                    .foregroundStyle(.white.opacity(0.78))
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(20)
        }
        .padding(.top, 8)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(store.profile.name). \(store.profile.title). \(store.profile.tagline)")
    }

    private var socialStrip: some View {
        GlassCard(cornerRadius: 18) {
            VStack(alignment: .leading, spacing: 12) {
                Text("Connect")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.secondary)
                HStack(spacing: 10) {
                    socialButton(
                        title: "GitHub",
                        systemImage: "chevron.left.forwardslash.chevron.right",
                        url: store.profile.githubProfileURL,
                        accessibilityDescription: nil
                    )
                    if let url = store.profile.linkedInURL {
                        socialButton(title: "LinkedIn", systemImage: "link", url: url, accessibilityDescription: nil)
                    }
                    if let url = store.profile.blogURL {
                        socialButton(
                            title: store.profile.blogTitle ?? "Blog",
                            systemImage: "safari.fill",
                            url: url,
                            accessibilityDescription: "The Perspective, \(url.absoluteString.replacingOccurrences(of: "https://", with: ""))"
                        )
                    }
                }
            }
        }
    }

    private func socialButton(title: String, systemImage: String, url: URL, accessibilityDescription: String?) -> some View {
        Link(destination: url) {
            Label(title, systemImage: systemImage)
                .font(.caption.weight(.semibold))
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .minimumScaleFactor(0.72)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 10)
                .padding(.horizontal, 4)
                .background(AppTheme.mist.opacity(0.65), in: RoundedRectangle(cornerRadius: 12, style: .continuous))
                .overlay {
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .strokeBorder(Color.black.opacity(0.06), lineWidth: 1)
                }
        }
        .buttonStyle(.plain)
        .foregroundStyle(AppTheme.ink)
        .accessibilityLabel(accessibilityDescription ?? title)
        .accessibilityHint("Opens in Safari")
    }

    private var streakCard: some View {
        GlassCard {
            HStack(alignment: .center, spacing: 16) {
                ZStack {
                    SkillProgressRing(progress: min(Double(store.practiceStreak) / 14.0, 1), lineWidth: 10, accent: AppTheme.gold)
                        .frame(width: 72, height: 72)
                    Text("\(store.practiceStreak)")
                        .font(.title2.weight(.heavy))
                        .monospacedDigit()
                        .foregroundStyle(AppTheme.ink)
                }
                .accessibilityElement(children: .ignore)
                .accessibilityLabel("Practice streak \(store.practiceStreak) days")

                VStack(alignment: .leading, spacing: 6) {
                    Text("Training streak")
                        .font(.headline)
                        .foregroundStyle(AppTheme.ink)
                    Text("Open the app daily to grow your streak — discipline beats motivation.")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
        }
    }

    private var statsRow: some View {
        HStack(spacing: 14) {
            statTile(
                title: "Avg. craft",
                value: Int(store.averageProficiency() * 100),
                suffix: "%",
                ring: store.averageProficiency(),
                tint: AppTheme.crimson
            )
            statTile(
                title: "Path",
                value: Int(store.journeyProgress() * 100),
                suffix: "%",
                ring: store.journeyProgress(),
                tint: AppTheme.bamboo
            )
        }
    }

    private func statTile(title: String, value: Int, suffix: String, ring: Double, tint: Color) -> some View {
        GlassCard(cornerRadius: 18) {
            HStack(spacing: 12) {
                SkillProgressRing(progress: ring, lineWidth: 8, accent: tint)
                    .frame(width: 52, height: 52)
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.secondary)
                    Text("\(value)\(suffix)")
                        .font(.title3.weight(.bold))
                        .foregroundStyle(AppTheme.ink)
                        .monospacedDigit()
                }
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(title) \(value) percent")
    }

    private var focusChips: some View {
        VStack(alignment: .leading, spacing: 10) {
            SectionHeader(title: "Focus", subtitle: "What reviewers should remember.")
            FlowLayout(spacing: 8) {
                ForEach(store.profile.focusAreas, id: \.self) { area in
                    Text(area)
                        .font(.caption.weight(.semibold))
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(AppTheme.mist.opacity(0.85), in: Capsule())
                        .overlay {
                            Capsule()
                                .strokeBorder(Color.black.opacity(0.06), lineWidth: 1)
                        }
                }
            }
        }
    }

    private var featuredProject: some View {
        VStack(alignment: .leading, spacing: 10) {
            SectionHeader(title: "GitHub spotlight", subtitle: store.profile.academyLine)
            if let project = store.featuredGitHubProject {
                NavigationLink(value: project) {
                    GlassCard {
                        HStack(spacing: 14) {
                            Image(systemName: project.symbolName)
                                .font(.title2)
                                .foregroundStyle(AppTheme.crimson)
                                .frame(width: 44, height: 44)
                                .background(AppTheme.crimson.opacity(0.12), in: RoundedRectangle(cornerRadius: 12, style: .continuous))
                            VStack(alignment: .leading, spacing: 4) {
                                Text(project.name)
                                    .font(.headline)
                                    .foregroundStyle(AppTheme.ink)
                                Text(project.tagline)
                                    .font(.footnote)
                                    .foregroundStyle(.secondary)
                                    .multilineTextAlignment(.leading)
                            }
                            Spacer(minLength: 0)
                            Image(systemName: "chevron.right")
                                .font(.footnote.weight(.semibold))
                                .foregroundStyle(.tertiary)
                        }
                    }
                }
                .buttonStyle(.plain)
            }

            Link(destination: store.profile.githubProfileURL) {
                GlassCard(cornerRadius: 16) {
                    HStack(spacing: 12) {
                        Image(systemName: "arrow.up.right.circle.fill")
                            .font(.title2)
                            .foregroundStyle(AppTheme.crimson)
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Open full GitHub profile")
                                .font(.subheadline.weight(.semibold))
                                .foregroundStyle(AppTheme.ink)
                            Text(store.profile.githubProfileURL.absoluteString.replacingOccurrences(of: "https://", with: ""))
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        Spacer(minLength: 0)
                    }
                }
            }
            .buttonStyle(.plain)
            .accessibilityHint("Opens in Safari")
        }
    }
}
