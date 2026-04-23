//
//  ProjectsView.swift
//  PortfolioApp
//

import SwiftUI

struct ProjectsView: View {
    @Environment(PortfolioStore.self) private var store

    var body: some View {
        List {
            Section {
                ForEach(store.projectsTimeline) { project in
                    NavigationLink(value: project) {
                        HStack(alignment: .top, spacing: 14) {
                            VStack(spacing: 4) {
                                Text("\(project.timelineOrder + 1)")
                                    .font(.caption2.weight(.bold))
                                    .foregroundStyle(.white)
                                    .frame(width: 26, height: 26)
                                    .background(AppTheme.crimson.opacity(0.9), in: Circle())
                                Spacer(minLength: 0)
                            }
                            .accessibilityHidden(true)

                            Image(systemName: project.symbolName)
                                .font(.title3)
                                .foregroundStyle(AppTheme.crimson)
                                .frame(width: 44, height: 44)
                                .background(AppTheme.crimson.opacity(0.12), in: RoundedRectangle(cornerRadius: 12, style: .continuous))

                            VStack(alignment: .leading, spacing: 4) {
                                Text(project.name)
                                    .font(.headline)
                                Text(project.timelineCaption)
                                    .font(.caption.weight(.semibold))
                                    .foregroundStyle(AppTheme.crimson.opacity(0.9))
                                Text(project.tagline)
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                                    .lineLimit(3)
                            }

                            if project.repositoryURL != nil {
                                Image(systemName: "arrow.up.right.square")
                                    .font(.caption.weight(.semibold))
                                    .foregroundStyle(AppTheme.crimson.opacity(0.85))
                                    .accessibilityLabel("Has GitHub link")
                            }
                        }
                        .padding(.vertical, 4)
                    }
                    .accessibilityElement(children: .combine)
                    .accessibilityLabel("\(project.name). \(project.timelineCaption). \(project.tagline)")
                }
            } header: {
                Text("Academy timeline")
            } footer: {
                Text("Oldest at the top — how your projects unfolded on the way to graduation.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
        }
        .scrollContentBackground(.hidden)
        .portfolioScreenBackground()
        .navigationTitle("Projects")
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Link(destination: store.profile.githubProfileURL) {
                    Image(systemName: "chevron.left.forwardslash.chevron.right")
                }
                .accessibilityLabel("Open GitHub profile HeyJoeyBless")
            }
        }
    }
}

struct ProjectDetailView: View {
    var project: PortfolioProject

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                GlassCard {
                    HStack(alignment: .top, spacing: 16) {
                        Image(systemName: project.symbolName)
                            .font(.largeTitle)
                            .foregroundStyle(AppTheme.crimson)
                            .frame(width: 56, height: 56)
                            .background(AppTheme.crimson.opacity(0.12), in: RoundedRectangle(cornerRadius: 16, style: .continuous))
                        VStack(alignment: .leading, spacing: 6) {
                            HStack(spacing: 8) {
                                Text(project.name)
                                    .font(.title2.weight(.bold))
                                    .foregroundStyle(AppTheme.ink)
                                if project.isFork {
                                    Text("Fork")
                                        .font(.caption2.weight(.bold))
                                        .padding(.horizontal, 8)
                                        .padding(.vertical, 4)
                                        .background(AppTheme.mist, in: Capsule())
                                        .foregroundStyle(.secondary)
                                }
                            }
                            Text(project.role)
                                .font(.subheadline.weight(.semibold))
                                .foregroundStyle(.secondary)
                            Text(project.timelineCaption)
                                .font(.caption.weight(.semibold))
                                .foregroundStyle(AppTheme.crimson.opacity(0.95))
                            Text(project.tagline)
                                .font(.subheadline)
                                .foregroundStyle(AppTheme.ink.opacity(0.85))
                        }
                    }
                }

                if let url = project.repositoryURL {
                    Link(destination: url) {
                        GlassCard(cornerRadius: 18) {
                            HStack(spacing: 14) {
                                Image(systemName: "chevron.left.forwardslash.chevron.right")
                                    .font(.title3.weight(.semibold))
                                    .foregroundStyle(AppTheme.crimson)
                                    .frame(width: 44, height: 44)
                                    .background(AppTheme.crimson.opacity(0.12), in: RoundedRectangle(cornerRadius: 12, style: .continuous))
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("View on GitHub")
                                        .font(.headline)
                                        .foregroundStyle(AppTheme.ink)
                                    Text(url.absoluteString)
                                        .font(.caption2)
                                        .foregroundStyle(.secondary)
                                        .lineLimit(2)
                                }
                                Spacer(minLength: 0)
                                Image(systemName: "arrow.up.right.square")
                                    .font(.body.weight(.semibold))
                                    .foregroundStyle(AppTheme.crimson)
                            }
                        }
                    }
                    .buttonStyle(.plain)
                    .accessibilityHint("Opens repository in Safari")
                } else {
                    GlassCard(cornerRadius: 18) {
                        VStack(alignment: .leading, spacing: 6) {
                            Text("GitHub link")
                                .font(.headline)
                                .foregroundStyle(AppTheme.ink)
                            Text("Push this app to a public repo, then add its URL in PortfolioStore next to Portfolio (this app).")
                                .font(.footnote)
                                .foregroundStyle(.secondary)
                        }
                    }
                }

                SectionHeader(title: "Highlights", subtitle: "Concrete outcomes, not buzzwords.")

                VStack(alignment: .leading, spacing: 12) {
                    ForEach(project.highlights, id: \.self) { line in
                        HStack(alignment: .top, spacing: 10) {
                            Image(systemName: "sparkle")
                                .foregroundStyle(AppTheme.gold)
                            Text(line)
                                .font(.body)
                                .foregroundStyle(AppTheme.ink)
                        }
                    }
                }
                .padding(16)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(AppTheme.mist.opacity(0.45), in: RoundedRectangle(cornerRadius: 18, style: .continuous))

                SectionHeader(title: "Stack", subtitle: "Technologies and frameworks.")

                FlowLayout(spacing: 8) {
                    ForEach(project.techStack, id: \.self) { tech in
                        Text(tech)
                            .font(.caption.weight(.semibold))
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(Color.white.opacity(0.75), in: Capsule())
                            .overlay {
                                Capsule()
                                    .strokeBorder(Color.black.opacity(0.06), lineWidth: 1)
                            }
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 28)
        }
        .portfolioScreenBackground()
        .navigationTitle("Project")
        .navigationBarTitleDisplayMode(.inline)
    }
}
