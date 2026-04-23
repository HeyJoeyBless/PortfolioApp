//
//  JourneyView.swift
//  PortfolioApp
//

import SwiftUI

struct JourneyView: View {
    @Environment(PortfolioStore.self) private var store

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 22) {
                pathHeader

                VStack(alignment: .leading, spacing: 0) {
                    ForEach(Array(store.journeySteps.enumerated()), id: \.element.id) { index, step in
                        JourneyTimelineRow(
                            step: step,
                            isFirst: index == 0,
                            isLast: index == store.journeySteps.count - 1
                        ) {
                            withAnimation(.spring(response: 0.45, dampingFraction: 0.82)) {
                                store.toggleJourneyStep(step)
                            }
                        }
                    }
                }

                quoteCard
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 28)
        }
        .portfolioScreenBackground()
        .navigationTitle("Journey")
        .navigationBarTitleDisplayMode(.large)
    }

    private var pathHeader: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: 14) {
                HStack {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("The path")
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(.secondary)
                        Text("Academy → craft → ship")
                            .font(.title3.weight(.bold))
                            .foregroundStyle(AppTheme.ink)
                    }
                    Spacer()
                    SkillProgressRing(progress: store.journeyProgress(), lineWidth: 10, accent: AppTheme.bamboo)
                        .frame(width: 64, height: 64)
                }
                Text("Tap a milestone to reflect what is done — like a training log, not a todo list.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }

    private var quoteCard: some View {
        GlassCard(cornerRadius: 20) {
            VStack(alignment: .leading, spacing: 10) {
                Label("Dojo note", systemImage: "quote.opening")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(AppTheme.crimson)
                Text("Small, consistent reps beat rare heroic sessions. Let the app be proof of your discipline.")
                    .font(.subheadline)
                    .foregroundStyle(AppTheme.ink)
            }
        }
        .accessibilityElement(children: .combine)
    }
}

private struct JourneyTimelineRow: View {
    var step: JourneyStep
    var isFirst: Bool
    var isLast: Bool
    var onToggle: () -> Void

    var body: some View {
        HStack(alignment: .top, spacing: 14) {
            VStack(spacing: 0) {
                if !isFirst {
                    Rectangle()
                        .fill(AppTheme.journeyTrack)
                        .frame(width: 3, height: 18)
                }
                ZStack {
                    Circle()
                        .fill(step.isComplete ? AppTheme.bamboo : AppTheme.mist)
                        .frame(width: 18, height: 18)
                    if step.isComplete {
                        Image(systemName: "checkmark")
                            .font(.caption2.weight(.bold))
                            .foregroundStyle(.white)
                    }
                }
                .accessibilityHidden(true)
                if !isLast {
                    Rectangle()
                        .fill(AppTheme.journeyTrack)
                        .frame(width: 3, height: 18)
                }
            }
            .frame(width: 18)

            Button(action: onToggle) {
                GlassCard(cornerRadius: 18) {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text(step.title)
                                .font(.headline)
                                .foregroundStyle(AppTheme.ink)
                            Spacer()
                            Image(systemName: step.isComplete ? "checkmark.circle.fill" : "circle")
                                .foregroundStyle(step.isComplete ? AppTheme.bamboo : .secondary)
                                .imageScale(.large)
                                .accessibilityLabel(step.isComplete ? "Completed" : "Not completed")
                        }
                        Text(step.caption)
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.leading)
                    }
                }
            }
            .buttonStyle(.plain)
        }
        .padding(.bottom, isLast ? 0 : 6)
        .accessibilityElement(children: .combine)
        .accessibilityHint("Double tap to toggle completion.")
    }
}
