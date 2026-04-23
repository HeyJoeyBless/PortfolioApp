//
//  ProfileAccountViews.swift
//  PortfolioApp
//

import PhotosUI
import SwiftUI
import UIKit

struct AccountGateView: View {
    @Environment(AccountSessionStore.self) private var session
    @State private var newPersonName = ""
    @State private var showAddSheet = false

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 20) {
                Text("Who is using the app?")
                    .font(.title2.weight(.bold))
                    .foregroundStyle(AppTheme.ink)

                Text("Each person gets their own portfolio snapshot and resume cards on this device. This is not cloud sign-in — it keeps demos and roommates separate.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)

                List {
                    Section("Profiles on this device") {
                        ForEach(session.accounts) { account in
                            Button {
                                session.signIn(accountId: account.id)
                            } label: {
                                HStack {
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(account.displayName)
                                            .font(.headline)
                                            .foregroundStyle(AppTheme.ink)
                                        if account.usesShowcaseSeed {
                                            Text("Bundled showcase portfolio")
                                                .font(.caption)
                                                .foregroundStyle(.secondary)
                                        } else {
                                            Text("Personal starter template")
                                                .font(.caption)
                                                .foregroundStyle(.secondary)
                                        }
                                    }
                                    Spacer()
                                    Image(systemName: "chevron.right")
                                        .font(.caption.weight(.semibold))
                                        .foregroundStyle(.tertiary)
                                }
                            }
                        }
                    }
                }
                .scrollContentBackground(.hidden)
                .listStyle(.insetGrouped)

                Button {
                    newPersonName = ""
                    showAddSheet = true
                } label: {
                    Label("Add another person", systemImage: "person.badge.plus")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(AppTheme.crimson, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
                        .foregroundStyle(.white)
                }
                .buttonStyle(.plain)
                .padding(.horizontal, 20)
                .padding(.bottom, 24)
            }
            .padding(.top, 12)
            .background(AppTheme.paper.ignoresSafeArea())
            .navigationTitle("Sign in")
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $showAddSheet) {
                addPersonSheet
            }
        }
    }

    private var addPersonSheet: some View {
        NavigationStack {
            Form {
                TextField("Display name", text: $newPersonName)
                    .textContentType(.name)
            }
            .navigationTitle("New profile")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { showAddSheet = false }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add & open") {
                        let account = session.addAccount(displayName: newPersonName)
                        session.signIn(accountId: account.id)
                        showAddSheet = false
                    }
                }
            }
        }
        .presentationDetents([.medium])
    }
}

struct ProfileView: View {
    @Environment(AccountSessionStore.self) private var session
    @Environment(PortfolioStore.self) private var store
    @Environment(PortfolioAppearanceStore.self) private var appearanceStore

    @State private var showAddSheet = false
    @State private var newPersonName = ""
    @State private var renameText = ""
    @State private var showRename = false

    var body: some View {
        @Bindable var appearance = appearanceStore
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                if let account = session.currentAccount {
                    LookBackgroundSection(appearance: appearance)

                    GlassCard(cornerRadius: 20) {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Signed in as")
                                .font(.caption.weight(.semibold))
                                .foregroundStyle(.secondary)
                            Text(account.displayName)
                                .font(.title2.weight(.bold))
                                .foregroundStyle(AppTheme.ink)
                            Text("Portfolio matches \(store.profile.name) in the Home tab.")
                                .font(.footnote)
                                .foregroundStyle(.secondary)
                        }
                    }

                    Button {
                        renameText = account.displayName
                        showRename = true
                    } label: {
                        Label("Rename this device profile", systemImage: "pencil")
                            .font(.subheadline.weight(.semibold))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(AppTheme.mist.opacity(0.75), in: RoundedRectangle(cornerRadius: 12, style: .continuous))
                    }
                    .buttonStyle(.plain)
                    .foregroundStyle(AppTheme.ink)

                    if session.accounts.count > 1 {
                        GlassCard {
                            VStack(alignment: .leading, spacing: 12) {
                                Text("Switch person")
                                    .font(.caption.weight(.semibold))
                                    .foregroundStyle(.secondary)
                                ForEach(session.accounts.filter { $0.id != session.currentAccountId }) { other in
                                    Button {
                                        store.saveSnapshot()
                                        session.signIn(accountId: other.id)
                                    } label: {
                                        HStack {
                                            Text(other.displayName)
                                                .foregroundStyle(AppTheme.ink)
                                            Spacer()
                                            Image(systemName: "arrow.triangle.2.circlepath")
                                                .foregroundStyle(AppTheme.crimson)
                                        }
                                        .font(.subheadline.weight(.medium))
                                    }
                                }
                            }
                        }
                    }

                    Button {
                        newPersonName = ""
                        showAddSheet = true
                    } label: {
                        Label("Add someone else on this device", systemImage: "person.badge.plus")
                            .font(.subheadline.weight(.semibold))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(AppTheme.bamboo.opacity(0.18), in: RoundedRectangle(cornerRadius: 12, style: .continuous))
                    }
                    .buttonStyle(.plain)
                    .foregroundStyle(AppTheme.bamboo)

                    Button(role: .destructive) {
                        store.saveSnapshot()
                        session.signOut()
                    } label: {
                        Label("Sign out", systemImage: "rectangle.portrait.and.arrow.right")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                    }
                    .buttonStyle(.plain)
                    .padding(.top, 8)
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
        }
        .portfolioScreenBackground()
        .navigationTitle("Profile")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showAddSheet) {
            addPersonSheet
        }
        .sheet(isPresented: $showRename) {
            NavigationStack {
                Form {
                    TextField("Profile label", text: $renameText)
                    Text("This label is for picking who is on the device. Your public name on Home still comes from portfolio data.")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
                .navigationTitle("Rename profile")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Cancel") { showRename = false }
                    }
                    ToolbarItem(placement: .confirmationAction) {
                        Button("Save") {
                            if let id = session.currentAccountId {
                                session.renameAccount(id: id, to: renameText)
                            }
                            showRename = false
                        }
                    }
                }
            }
            .presentationDetents([.medium])
        }
    }

    private var addPersonSheet: some View {
        NavigationStack {
            Form {
                TextField("Display name", text: $newPersonName)
            }
            .navigationTitle("New profile")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { showAddSheet = false }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Create") {
                        store.saveSnapshot()
                        let account = session.addAccount(displayName: newPersonName)
                        session.signIn(accountId: account.id)
                        showAddSheet = false
                    }
                }
            }
        }
        .presentationDetents([.medium])
    }
}

// MARK: - Look & background

private struct LookBackgroundSection: View {
    @Bindable var appearance: PortfolioAppearanceStore
    @State private var bgPhotoItem: PhotosPickerItem?

    var body: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: 16) {
                Text("Look & background")
                    .font(.headline)
                    .foregroundStyle(AppTheme.ink)

                Text("Tab tint and screen backdrop are saved for this profile on this device.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)

                Toggle("Use built-in accent (crimson)", isOn: $appearance.usesDefaultAccent)
                    .font(.subheadline.weight(.medium))
                    .onChange(of: appearance.usesDefaultAccent) { _, _ in appearance.persist() }

                ColorPicker(
                    "Accent color",
                    selection: Binding(
                        get: {
                            appearance.usesDefaultAccent
                                ? AppTheme.crimson
                                : Color(red: appearance.accentR, green: appearance.accentG, blue: appearance.accentB)
                        },
                        set: { newColor in
                            appearance.usesDefaultAccent = false
                            let c = newColor.portfolioRGBComponents
                            appearance.accentR = c.r
                            appearance.accentG = c.g
                            appearance.accentB = c.b
                            appearance.persist()
                        }
                    ),
                    supportsOpacity: false
                )
                .disabled(appearance.usesDefaultAccent)
                .opacity(appearance.usesDefaultAccent ? 0.45 : 1)

                Divider().opacity(0.35)

                Toggle("Use built-in paper tone", isOn: $appearance.usesDefaultPaper)
                    .font(.subheadline.weight(.medium))
                    .onChange(of: appearance.usesDefaultPaper) { _, _ in appearance.persist() }

                ColorPicker(
                    "Backdrop color",
                    selection: Binding(
                        get: {
                            appearance.usesDefaultPaper
                                ? AppTheme.paper
                                : Color(red: appearance.paperR, green: appearance.paperG, blue: appearance.paperB)
                        },
                        set: { newColor in
                            appearance.usesDefaultPaper = false
                            let c = newColor.portfolioRGBComponents
                            appearance.paperR = c.r
                            appearance.paperG = c.g
                            appearance.paperB = c.b
                            appearance.persist()
                        }
                    ),
                    supportsOpacity: false
                )
                .disabled(appearance.usesDefaultPaper)
                .opacity(appearance.usesDefaultPaper ? 0.45 : 1)

                PhotosPicker(selection: $bgPhotoItem, matching: .images, photoLibrary: .shared()) {
                    Label("Import backdrop photo", systemImage: "photo.on.rectangle.angled")
                        .font(.subheadline.weight(.semibold))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(AppTheme.mist.opacity(0.75), in: RoundedRectangle(cornerRadius: 12, style: .continuous))
                }
                .buttonStyle(.plain)
                .foregroundStyle(AppTheme.ink)
                .onChange(of: bgPhotoItem) { _, item in
                    guard let item else { return }
                    Task {
                        await loadBackdropPhoto(item: item)
                    }
                }

                if appearance.backgroundImageJPEGData != nil {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Photo backdrop")
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(.secondary)
                        Slider(value: $appearance.scrimOpacity, in: 0.15...0.72, step: 0.01) {
                            Text("Dimming")
                        } minimumValueLabel: {
                            Text("Lighter").font(.caption2)
                        } maximumValueLabel: {
                            Text("Darker").font(.caption2)
                        }
                        .onChange(of: appearance.scrimOpacity) { _, _ in appearance.persist() }

                        Slider(value: $appearance.backgroundBlur, in: 0...26, step: 0.5) {
                            Text("Blur")
                        } minimumValueLabel: {
                            Text("Sharp").font(.caption2)
                        } maximumValueLabel: {
                            Text("Soft").font(.caption2)
                        }
                        .onChange(of: appearance.backgroundBlur) { _, _ in appearance.persist() }
                    }

                    Button(role: .destructive) {
                        appearance.clearBackgroundPhoto()
                        bgPhotoItem = nil
                    } label: {
                        Label("Remove backdrop photo", systemImage: "trash")
                            .font(.subheadline.weight(.semibold))
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.plain)
                }

                Button {
                    appearance.resetToAppDefaults()
                    bgPhotoItem = nil
                } label: {
                    Label("Reset look to app defaults", systemImage: "arrow.counterclockwise")
                        .font(.subheadline.weight(.semibold))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                }
                .buttonStyle(.plain)
                .foregroundStyle(AppTheme.crimson)
            }
        }
    }

    private func loadBackdropPhoto(item: PhotosPickerItem) async {
        do {
            guard let data = try await item.loadTransferable(type: Data.self),
                  let image = UIImage(data: data) else {
                await MainActor.run { bgPhotoItem = nil }
                return
            }
            await MainActor.run {
                appearance.setBackgroundPhoto(image)
                bgPhotoItem = nil
            }
        } catch {
            await MainActor.run { bgPhotoItem = nil }
        }
    }
}
