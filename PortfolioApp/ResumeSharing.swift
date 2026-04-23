//
//  ResumeSharing.swift
//  PortfolioApp
//

import MessageUI
import SwiftUI
import UIKit

enum ResumeSharing {
    static func printDocument(title: String, resume: String, coverLetter: String, tailoredResume: String? = nil) {
        let body = formattedDocument(title: title, resume: resume, coverLetter: coverLetter, tailoredResume: tailoredResume)
        let printInfo = UIPrintInfo(dictionary: nil)
        printInfo.jobName = title
        printInfo.outputType = .general
        let formatter = UISimpleTextPrintFormatter(text: body)
        formatter.perPageContentInsets = UIEdgeInsets(top: 36, left: 36, bottom: 36, right: 36)
        let controller = UIPrintInteractionController.shared
        controller.printInfo = printInfo
        controller.printFormatter = formatter
        controller.present(animated: true, completionHandler: nil)
    }

    static func formattedDocument(title: String, resume: String, coverLetter: String, tailoredResume: String? = nil) -> String {
        var parts = """
        \(title)

        — Resume —

        \(resume)

        — Cover letter —

        \(coverLetter)
        """
        if let tailored = tailoredResume?.trimmingCharacters(in: .whitespacesAndNewlines), tailored.isEmpty == false {
            parts += """

            — Tailored resume (draft) —

            \(tailored)
            """
        }
        return parts
    }
}

struct MailComposeView: UIViewControllerRepresentable {
    @Environment(\.dismiss) private var dismiss

    var subject: String
    var body: String

    func makeCoordinator() -> Coordinator {
        Coordinator(dismiss: dismiss)
    }

    func makeUIViewController(context: Context) -> MFMailComposeViewController {
        let mail = MFMailComposeViewController()
        mail.mailComposeDelegate = context.coordinator
        mail.setSubject(subject)
        mail.setMessageBody(body, isHTML: false)
        return mail
    }

    func updateUIViewController(_ uiViewController: MFMailComposeViewController, context: Context) {}

    final class Coordinator: NSObject, MFMailComposeViewControllerDelegate {
        var dismiss: DismissAction

        init(dismiss: DismissAction) {
            self.dismiss = dismiss
        }

        func mailComposeController(
            _ controller: MFMailComposeViewController,
            didFinishWith result: MFMailComposeResult,
            error: Error?
        ) {
            dismiss()
        }
    }
}

struct ActivityShareView: UIViewControllerRepresentable {
    var items: [Any]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: items, applicationActivities: nil)
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}
