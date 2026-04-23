//
//  MainTabView.swift
//  PortfolioApp
//

import SwiftUI

struct MainTabView: View {
    @Environment(PortfolioStore.self) private var store
    @Environment(PortfolioAppearanceStore.self) private var appearance

    var body: some View {
        TabView {
            NavigationStack {
                HomeView()
                    .navigationDestination(for: PortfolioProject.self) { project in
                        ProjectDetailView(project: project)
                    }
            }
            .tabItem { Label("Home", systemImage: "house.fill") }

            NavigationStack {
                SkillsView()
                    .navigationDestination(for: PortfolioSkill.self) { skill in
                        SkillDetailView(skill: skill)
                    }
                    .navigationDestination(for: PortfolioProject.self) { project in
                        ProjectDetailView(project: project)
                    }
            }
            .tabItem { Label("Skills", systemImage: "square.grid.2x2.fill") }

            NavigationStack {
                ProjectsView()
                    .navigationDestination(for: PortfolioProject.self) { project in
                        ProjectDetailView(project: project)
                    }
            }
            .tabItem { Label("Projects", systemImage: "folder.fill") }

            NavigationStack {
                JourneyView()
            }
            .tabItem { Label("Journey", systemImage: "map.fill") }

            NavigationStack {
                ProfileView()
            }
            .tabItem { Label("Profile", systemImage: "person.crop.circle.fill") }

            NavigationStack {
                ResumeBuilderView()
            }
            .tabItem { Label("Resume", systemImage: "doc.text.fill") }

            NavigationStack {
                MoreView()
            }
            .tabItem { Label("More", systemImage: "ellipsis.circle.fill") }
        }
        .tint(appearance.accentColor)
        .onAppear {
            store.refreshPracticeStreakIfNeeded()
        }
    }
}
