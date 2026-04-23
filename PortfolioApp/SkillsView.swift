//
//  SkillsView.swift
//  PortfolioApp
//

import SwiftUI

struct SkillsView: View {
    @Environment(PortfolioStore.self) private var store

    private let columns = [
        GridItem(.flexible(), spacing: 14),
        GridItem(.flexible(), spacing: 14)
    ]

    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 14) {
                ForEach(store.skills) { skill in
                    NavigationLink(value: skill) {
                        skillCell(skill)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 24)
        }
        .portfolioScreenBackground()
        .navigationTitle("Skills")
        .navigationBarTitleDisplayMode(.large)
    }

    private func skillCell(_ skill: PortfolioSkill) -> some View {
        GlassCard(cornerRadius: 20) {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Image(systemName: skill.symbolName)
                        .font(.title3)
                        .foregroundStyle(AppTheme.dawn)
                        .frame(width: 40, height: 40)
                        .background(AppTheme.dawn.opacity(0.15), in: RoundedRectangle(cornerRadius: 12, style: .continuous))
                    Spacer()
                    RankPill(rank: skill.rank)
                }

                Text(skill.title)
                    .font(.headline)
                    .foregroundStyle(AppTheme.ink)
                    .multilineTextAlignment(.leading)

                Text(skill.summary)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(3)
                    .multilineTextAlignment(.leading)

                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(Color.black.opacity(0.06))
                    Capsule()
                        .fill(
                            LinearGradient(
                                colors: [AppTheme.crimson.opacity(0.85), AppTheme.gold.opacity(0.9)],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(maxWidth: .infinity)
                        .scaleEffect(x: CGFloat(min(max(skill.proficiency, 0), 1)), y: 1, anchor: .leading)
                        .animation(.easeOut(duration: 0.45), value: skill.proficiency)
                }
                .frame(height: 8)
                .frame(maxWidth: .infinity)
                .accessibilityLabel("Proficiency \(Int(skill.proficiency * 100)) percent")
            }
        }
    }
}

struct SkillDetailView: View {
    @Environment(PortfolioStore.self) private var store
    var skill: PortfolioSkill

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                GlassCard {
                    HStack(alignment: .top, spacing: 16) {
                        ZStack {
                            SkillProgressRing(progress: skill.proficiency, lineWidth: 12)
                                .frame(width: 96, height: 96)
                            Image(systemName: skill.symbolName)
                                .font(.title2)
                                .foregroundStyle(AppTheme.crimson)
                        }
                        VStack(alignment: .leading, spacing: 8) {
                            Text(skill.title)
                                .font(.title3.weight(.bold))
                                .foregroundStyle(AppTheme.ink)
                            RankPill(rank: skill.rank)
                            Text(skill.summary)
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                    }
                }

                SectionHeader(
                    title: "Paul Hudson curriculum",
                    subtitle: "Topics you can speak to in interviews and critiques."
                )

                VStack(alignment: .leading, spacing: 10) {
                    ForEach(skill.paulHudsonTopics, id: \.self) { topic in
                        HStack(alignment: .top, spacing: 10) {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundStyle(AppTheme.bamboo)
                            Text(topic)
                                .font(.subheadline)
                                .foregroundStyle(AppTheme.ink)
                        }
                    }
                }
                .padding(16)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(AppTheme.mist.opacity(0.45), in: RoundedRectangle(cornerRadius: 18, style: .continuous))

                let linked = store.projects(for: skill)
                if !linked.isEmpty {
                    SectionHeader(title: "Related work", subtitle: "Projects where this skill shows up.")
                    ForEach(linked) { project in
                        NavigationLink(value: project) {
                            GlassCard(cornerRadius: 18) {
                                HStack {
                                    Image(systemName: project.symbolName)
                                        .foregroundStyle(AppTheme.crimson)
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text(project.name)
                                            .font(.headline)
                                            .foregroundStyle(AppTheme.ink)
                                        Text(project.tagline)
                                            .font(.caption)
                                            .foregroundStyle(.secondary)
                                    }
                                    Spacer()
                                    Image(systemName: "chevron.right")
                                        .font(.caption.weight(.bold))
                                        .foregroundStyle(.tertiary)
                                }
                            }
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 28)
        }
        .portfolioScreenBackground()
        .navigationTitle("Skill")
        .navigationBarTitleDisplayMode(.inline)
    }
}
