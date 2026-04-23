//
//  PortfolioAppearanceStore.swift
//  PortfolioApp
//

import Observation
import SwiftUI
import UIKit

private struct PortfolioAppearancePayload: Codable {
    var usesDefaultAccent: Bool
    var accentR: Double
    var accentG: Double
    var accentB: Double
    var usesDefaultPaper: Bool
    var paperR: Double
    var paperG: Double
    var paperB: Double
    var backgroundImageJPEGData: Data?
    var scrimOpacity: Double
    var backgroundBlur: Double
}

@Observable
final class PortfolioAppearanceStore {
    let accountId: UUID

    var usesDefaultAccent: Bool
    var accentR: Double
    var accentG: Double
    var accentB: Double

    var usesDefaultPaper: Bool
    var paperR: Double
    var paperG: Double
    var paperB: Double

    var backgroundImageJPEGData: Data?
    /// Dark overlay on top of a custom photo (0.15–0.75).
    var scrimOpacity: Double
    /// Blur applied to the background photo (0–28).
    var backgroundBlur: Double

    init(accountId: UUID) {
        self.accountId = accountId
        let key = Self.storageKey(accountId)
        if let data = UserDefaults.standard.data(forKey: key),
           let p = try? JSONDecoder().decode(PortfolioAppearancePayload.self, from: data) {
            usesDefaultAccent = p.usesDefaultAccent
            accentR = p.accentR
            accentG = p.accentG
            accentB = p.accentB
            usesDefaultPaper = p.usesDefaultPaper
            paperR = p.paperR
            paperG = p.paperG
            paperB = p.paperB
            backgroundImageJPEGData = p.backgroundImageJPEGData
            scrimOpacity = p.scrimOpacity.clamped(to: 0.12...0.78)
            backgroundBlur = p.backgroundBlur.clamped(to: 0...28)
        } else {
            usesDefaultAccent = true
            accentR = 0.72
            accentG = 0.18
            accentB = 0.22
            usesDefaultPaper = true
            paperR = 0.97
            paperG = 0.96
            paperB = 0.93
            backgroundImageJPEGData = nil
            scrimOpacity = 0.42
            backgroundBlur = 12
        }
    }

    var accentColor: Color {
        usesDefaultAccent ? AppTheme.crimson : Color(red: accentR, green: accentG, blue: accentB)
    }

    var paperColor: Color {
        usesDefaultPaper ? AppTheme.paper : Color(red: paperR, green: paperG, blue: paperB)
    }

    func persist() {
        let p = PortfolioAppearancePayload(
            usesDefaultAccent: usesDefaultAccent,
            accentR: accentR,
            accentG: accentG,
            accentB: accentB,
            usesDefaultPaper: usesDefaultPaper,
            paperR: paperR,
            paperG: paperG,
            paperB: paperB,
            backgroundImageJPEGData: backgroundImageJPEGData,
            scrimOpacity: scrimOpacity,
            backgroundBlur: backgroundBlur
        )
        guard let data = try? JSONEncoder().encode(p) else { return }
        UserDefaults.standard.set(data, forKey: Self.storageKey(accountId))
    }

    func resetToAppDefaults() {
        usesDefaultAccent = true
        accentR = 0.72
        accentG = 0.18
        accentB = 0.22
        usesDefaultPaper = true
        paperR = 0.97
        paperG = 0.96
        paperB = 0.93
        backgroundImageJPEGData = nil
        scrimOpacity = 0.42
        backgroundBlur = 12
        persist()
    }

    func setBackgroundPhoto(_ image: UIImage) {
        let scaled = image.portfolioScaled(maxSide: 960)
        backgroundImageJPEGData = scaled.jpegData(compressionQuality: 0.68)
        persist()
    }

    func clearBackgroundPhoto() {
        backgroundImageJPEGData = nil
        persist()
    }

    private static func storageKey(_ accountId: UUID) -> String {
        "portfolio.appearance.v1.\(accountId.uuidString)"
    }
}

// MARK: - Screen background

struct PortfolioBackdropView: View {
    var appearance: PortfolioAppearanceStore

    var body: some View {
        ZStack {
            if let data = appearance.backgroundImageJPEGData,
               let ui = UIImage(data: data) {
                Image(uiImage: ui)
                    .resizable()
                    .scaledToFill()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .clipped()
                    .blur(radius: appearance.backgroundBlur)
                    .ignoresSafeArea()
                Color.black.opacity(appearance.scrimOpacity)
                    .ignoresSafeArea()
                appearance.paperColor.opacity(0.18)
                    .ignoresSafeArea()
            } else {
                appearance.paperColor
                    .ignoresSafeArea()
            }
        }
    }
}

private struct PortfolioScreenBackgroundModifier: ViewModifier {
    @Environment(PortfolioAppearanceStore.self) private var appearance

    func body(content: Content) -> some View {
        content
            .background {
                PortfolioBackdropView(appearance: appearance)
            }
    }
}

extension View {
    /// Full-screen backdrop from `PortfolioAppearanceStore` in the environment.
    func portfolioScreenBackground() -> some View {
        modifier(PortfolioScreenBackgroundModifier())
    }
}

// MARK: - Color helpers

extension Color {
    var portfolioRGBComponents: (r: Double, g: Double, b: Double) {
        let ui = UIColor(self)
        var r: CGFloat = 0
        var g: CGFloat = 0
        var b: CGFloat = 0
        var a: CGFloat = 0
        ui.getRed(&r, green: &g, blue: &b, alpha: &a)
        return (Double(r), Double(g), Double(b))
    }
}

private extension Comparable {
    func clamped(to range: ClosedRange<Self>) -> Self {
        min(max(self, range.lowerBound), range.upperBound)
    }
}

private extension UIImage {
    func portfolioScaled(maxSide: CGFloat) -> UIImage {
        let w = size.width
        let h = size.height
        let longest = max(w, h)
        guard longest > maxSide, longest > 0 else { return self }
        let scale = maxSide / longest
        let newSize = CGSize(width: w * scale, height: h * scale)
        let format = UIGraphicsImageRendererFormat.default()
        format.scale = 1
        let renderer = UIGraphicsImageRenderer(size: newSize, format: format)
        return renderer.image { _ in
            draw(in: CGRect(origin: .zero, size: newSize))
        }
    }
}
