//
//  ResumeBuilderView.swift
//  PortfolioApp
//

import MessageUI
import PhotosUI
import SwiftUI
import UIKit

struct ResumeBuilderView: View {
    @Environment(\.activeAccountId) private var activeAccountId
    @State private var store: ResumeRolodexStore?

    var body: some View {
        Group {
            if let store {
                ResumeBuilderLoaded(store: store)
            } else {
                ProgressView("Loading resume data…")
                    .frame(maxWidth: .infinity, minHeight: 200)
            }
        }
        .task(id: activeAccountId) {
            guard let id = activeAccountId else {
                store = nil
                return
            }
            store = ResumeRolodexStore(accountId: id)
        }
    }
}

private struct ResumeBuilderLoaded: View {
    @Bindable var store: ResumeRolodexStore
    @State private var selectedIndustry = "Technology"
    @State private var resumePhotoItem: PhotosPickerItem?
    @State private var coverPhotoItem: PhotosPickerItem?
    @State private var isRecognizingResume = false
    @State private var isRecognizingCover = false
    @State private var ocrErrorMessage: String?
    @State private var showAddTypeSheet = false
    @State private var newTypeName = ""
    @State private var showMail = false
    @State private var showShare = false

    private let industries = ["Technology", "Healthcare", "Finance", "Education", "Marketing", "Operations"]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                SectionHeader(
                    title: "Resume rolodex",
                    subtitle: "Scan photos to text, edit here, and flip between resume types. Built for developers with GitHub portfolios."
                )

                rolodexSection
                actionsRow
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
            .padding(.bottom, 28)
        }
        .scrollDismissesKeyboard(.interactively)
        .portfolioScreenBackground()
        .navigationTitle("Resume")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showAddTypeSheet) {
            addTypeSheet
        }
        .sheet(isPresented: $showMail) {
            if let card = store.card(id: store.selectedCardId) {
                MailComposeView(
                    subject: "Resume — \(card.title)",
                    body: ResumeSharing.formattedDocument(
                        title: card.title,
                        resume: card.resumeText,
                        coverLetter: card.coverLetterText,
                        tailoredResume: card.tailoredResumeText
                    )
                )
            }
        }
        .sheet(isPresented: $showShare) {
            if let card = store.card(id: store.selectedCardId) {
                ActivityShareView(items: [
                    ResumeSharing.formattedDocument(
                        title: card.title,
                        resume: card.resumeText,
                        coverLetter: card.coverLetterText,
                        tailoredResume: card.tailoredResumeText
                    )
                ])
            }
        }
        .alert("Could not read text", isPresented: .constant(ocrErrorMessage != nil), actions: {
            Button("OK") { ocrErrorMessage = nil }
        }, message: {
            Text(ocrErrorMessage ?? "")
        })
    }

    private var rolodexSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Resume types")
                .font(.caption.weight(.semibold))
                .foregroundStyle(.secondary)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(store.cards) { card in
                        let selected = card.id == store.selectedCardId
                        Button {
                            store.selectedCardId = card.id
                        } label: {
                            Text(card.title.isEmpty ? "Untitled" : card.title)
                                .font(.subheadline.weight(selected ? .semibold : .regular))
                                .lineLimit(1)
                                .padding(.horizontal, 14)
                                .padding(.vertical, 9)
                                .foregroundStyle(selected ? Color.white : AppTheme.ink)
                                .background {
                                    Capsule()
                                        .fill(selected ? AppTheme.crimson : AppTheme.mist.opacity(0.75))
                                }
                        }
                        .buttonStyle(.plain)
                        .accessibilityLabel("\(card.title.isEmpty ? "Untitled" : card.title) resume type")
                        .accessibilityAddTraits(selected ? [.isSelected] : [])
                    }
                }
                .padding(.vertical, 2)
            }

            if store.card(id: store.selectedCardId) != nil {
                cardPage(cardId: store.selectedCardId)
            }
        }
    }

    private func cardPage(cardId: UUID) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            if let card = store.card(id: cardId) {
                GlassCard {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("This card")
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(.secondary)

                        TextField("Type name (e.g. Tech, Healthcare)", text: Binding(
                            get: { card.title },
                            set: { store.updateCard(id: cardId, title: $0) }
                        ))
                        .font(.headline)
                        .foregroundStyle(AppTheme.ink)
                    }
                }

                scanCard(cardId: cardId)

                GlassCard {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Resume")
                            .font(.headline)
                            .foregroundStyle(AppTheme.ink)

                        TextEditor(text: Binding(
                            get: { store.card(id: cardId)?.resumeText ?? "" },
                            set: { store.updateCard(id: cardId, resumeText: $0) }
                        ))
                        .scrollContentBackground(.hidden)
                        .frame(minHeight: 220)
                        .padding(8)
                        .background(AppTheme.mist.opacity(0.55), in: RoundedRectangle(cornerRadius: 12, style: .continuous))
                        .overlay {
                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                .strokeBorder(Color.black.opacity(0.08), lineWidth: 1)
                        }
                    }
                }

                GlassCard {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Cover letter")
                            .font(.headline)
                            .foregroundStyle(AppTheme.ink)

                        TextEditor(text: Binding(
                            get: { store.card(id: cardId)?.coverLetterText ?? "" },
                            set: { store.updateCard(id: cardId, coverLetterText: $0) }
                        ))
                        .scrollContentBackground(.hidden)
                        .frame(minHeight: 180)
                        .padding(8)
                        .background(AppTheme.mist.opacity(0.55), in: RoundedRectangle(cornerRadius: 12, style: .continuous))
                        .overlay {
                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                .strokeBorder(Color.black.opacity(0.08), lineWidth: 1)
                        }
                    }
                }

                tailorCard(cardId: cardId)
                tailoredOutput(cardId: cardId)
            }
        }
    }

    private func scanCard(cardId: UUID) -> some View {
        GlassCard {
            VStack(alignment: .leading, spacing: 12) {
                Text("Scan from photo")
                    .font(.headline)
                    .foregroundStyle(AppTheme.ink)

                Text("Choose a clear photo of a printed page. Text is recognized on-device and fills the fields below.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)

                VStack(spacing: 10) {
                    PhotosPicker(selection: $resumePhotoItem, matching: .images, photoLibrary: .shared()) {
                        scanButtonLabel(title: "Resume photo", systemImage: "doc.viewfinder", busy: isRecognizingResume)
                    }
                    .disabled(isRecognizingResume || isRecognizingCover)
                    .onChange(of: resumePhotoItem) { _, new in
                        Task { await runOCR(item: new, cardId: cardId, target: .resume) }
                    }

                    PhotosPicker(selection: $coverPhotoItem, matching: .images, photoLibrary: .shared()) {
                        scanButtonLabel(title: "Cover letter photo", systemImage: "envelope.viewfinder", busy: isRecognizingCover)
                    }
                    .disabled(isRecognizingResume || isRecognizingCover)
                    .onChange(of: coverPhotoItem) { _, new in
                        Task { await runOCR(item: new, cardId: cardId, target: .coverLetter) }
                    }
                }
            }
        }
    }

    private enum OCRTarget {
        case resume
        case coverLetter
    }

    private func runOCR(item: PhotosPickerItem?, cardId: UUID, target: OCRTarget) async {
        guard let item else { return }
        await MainActor.run {
            switch target {
            case .resume: isRecognizingResume = true
            case .coverLetter: isRecognizingCover = true
            }
        }

        do {
            guard let data = try await item.loadTransferable(type: Data.self),
                  let image = UIImage(data: data) else {
                await MainActor.run { ocrErrorMessage = "Could not load that photo." }
                return
            }

            let text = try ImageTranscription.recognizeText(from: image)
            guard text.isEmpty == false else {
                await MainActor.run { ocrErrorMessage = "No text was found. Try better lighting or a sharper photo." }
                return
            }

            await MainActor.run {
                switch target {
                case .resume:
                    let existing = store.card(id: cardId)?.resumeText ?? ""
                    let combined = existing.isEmpty ? text : "\(existing)\n\n\(text)"
                    store.updateCard(id: cardId, resumeText: combined)
                case .coverLetter:
                    let existing = store.card(id: cardId)?.coverLetterText ?? ""
                    let combined = existing.isEmpty ? text : "\(existing)\n\n\(text)"
                    store.updateCard(id: cardId, coverLetterText: combined)
                }
            }
        } catch {
            await MainActor.run {
                ocrErrorMessage = "Could not read text from the image."
            }
        }

        await MainActor.run {
            switch target {
            case .resume:
                isRecognizingResume = false
                resumePhotoItem = nil
            case .coverLetter:
                isRecognizingCover = false
                coverPhotoItem = nil
            }
        }
    }

    private func scanButtonLabel(title: String, systemImage: String, busy: Bool) -> some View {
        Label(title, systemImage: systemImage)
            .font(.caption.weight(.semibold))
            .frame(maxWidth: .infinity)
            .padding(.vertical, 10)
            .background(AppTheme.mist.opacity(0.8), in: RoundedRectangle(cornerRadius: 10, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .strokeBorder(Color.black.opacity(0.06), lineWidth: 1)
            }
            .overlay {
                if busy {
                    ProgressView()
                        .scaleEffect(0.9)
                }
            }
            .foregroundStyle(AppTheme.ink)
    }

    private func tailorCard(cardId: UUID) -> some View {
        GlassCard {
            VStack(alignment: .leading, spacing: 12) {
                Text("Tailor to another type")
                    .font(.headline)
                    .foregroundStyle(AppTheme.ink)

                Picker("Target type", selection: $selectedIndustry) {
                    ForEach(industries, id: \.self) { industry in
                        Text(industry).tag(industry)
                    }
                }
                .pickerStyle(.menu)

                Button {
                    let source = store.card(id: cardId)?.resumeText ?? ""
                    let tailored = buildTailoredResume(from: source, industry: selectedIndustry)
                    store.updateCard(id: cardId, tailoredResumeText: tailored)
                } label: {
                    Label("Generate tailored resume", systemImage: "wand.and.stars")
                        .font(.subheadline.weight(.semibold))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .background(AppTheme.crimson, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
                        .foregroundStyle(.white)
                }
                .buttonStyle(.plain)
                .disabled((store.card(id: cardId)?.resumeText ?? "").trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                .opacity((store.card(id: cardId)?.resumeText ?? "").trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? 0.55 : 1)
            }
        }
    }

    private func tailoredOutput(cardId: UUID) -> some View {
        let tailored = store.card(id: cardId)?.tailoredResumeText ?? ""
        return GlassCard {
            VStack(alignment: .leading, spacing: 10) {
                Text("Tailored resume")
                    .font(.headline)
                    .foregroundStyle(AppTheme.ink)

                if tailored.isEmpty {
                    Text("Generate a tailored version from your resume text above.")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                } else {
                    Text(tailored)
                        .font(.footnote)
                        .foregroundStyle(AppTheme.ink)
                        .textSelection(.enabled)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
        }
    }

    private var actionsRow: some View {
        VStack(spacing: 10) {
            Button {
                newTypeName = ""
                showAddTypeSheet = true
            } label: {
                Label("Add another resume type", systemImage: "plus.circle.fill")
                    .font(.subheadline.weight(.semibold))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(AppTheme.bamboo.opacity(0.2), in: RoundedRectangle(cornerRadius: 12, style: .continuous))
                    .foregroundStyle(AppTheme.bamboo)
            }
            .buttonStyle(.plain)

            if store.cards.count > 1 {
                Button(role: .destructive) {
                    store.removeCard(id: store.selectedCardId)
                } label: {
                    Label("Remove this card", systemImage: "trash")
                        .font(.subheadline.weight(.medium))
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.plain)
            }

            VStack(spacing: 10) {
                Button {
                    let id = store.selectedCardId
                    guard let card = store.card(id: id) else { return }
                    ResumeSharing.printDocument(
                        title: card.title,
                        resume: card.resumeText,
                        coverLetter: card.coverLetterText,
                        tailoredResume: card.tailoredResumeText.isEmpty ? nil : card.tailoredResumeText
                    )
                } label: {
                    Label("Print", systemImage: "printer.fill")
                        .font(.subheadline.weight(.semibold))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(AppTheme.mist.opacity(0.9), in: RoundedRectangle(cornerRadius: 12, style: .continuous))
                }
                .buttonStyle(.plain)
                .foregroundStyle(AppTheme.ink)

                Button {
                    if MFMailComposeViewController.canSendMail() {
                        showMail = true
                    } else {
                        showShare = true
                    }
                } label: {
                    Label("Email / share", systemImage: "square.and.arrow.up")
                        .font(.subheadline.weight(.semibold))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(AppTheme.mist.opacity(0.9), in: RoundedRectangle(cornerRadius: 12, style: .continuous))
                }
                .buttonStyle(.plain)
                .foregroundStyle(AppTheme.ink)
            }
        }
    }

    private var addTypeSheet: some View {
        NavigationStack {
            Form {
                TextField("Name", text: $newTypeName)
            }
            .navigationTitle("New resume type")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { showAddTypeSheet = false }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") {
                        let name = newTypeName.trimmingCharacters(in: .whitespacesAndNewlines)
                        store.addCard(named: name.isEmpty ? "Untitled" : name)
                        showAddTypeSheet = false
                    }
                }
            }
        }
        .presentationDetents([.medium])
    }

    private func buildTailoredResume(from source: String, industry: String) -> String {
        let guidance = industryGuidance[industry] ?? "Emphasize measurable outcomes and language that fits this field."
        let normalized = source.trimmingCharacters(in: .whitespacesAndNewlines)
        guard normalized.isEmpty == false else { return "" }

        return """
        Tailored for \(industry)

        Focus:
        \(guidance)

        Draft (edit freely):
        \(normalized)
        """
    }

    private var industryGuidance: [String: String] {
        [
            "Technology": "Highlight shipping, code quality, systems thinking, and metrics (performance, reliability, scale).",
            "Healthcare": "Emphasize outcomes, safety, compliance, and collaboration across teams.",
            "Finance": "Stress analysis, risk, reporting accuracy, and business impact.",
            "Education": "Stress teaching impact, curriculum, and learner outcomes.",
            "Marketing": "Stress campaigns, audience, and measurable results.",
            "Operations": "Stress process improvement, execution, and KPIs."
        ]
    }
}

#Preview {
    let id = UUID()
    NavigationStack {
        ResumeBuilderView()
            .environment(\.activeAccountId, id)
            .environment(PortfolioAppearanceStore(accountId: id))
    }
}
