//
//  ImageTranscription.swift
//  PortfolioApp
//

import UIKit
import Vision

enum ImageTranscriptionError: Error {
    case couldNotReadImage
    case recognitionFailed
}

enum ImageTranscription {
    /// On-device OCR using Vision (no network).
    static func recognizeText(from image: UIImage) throws -> String {
        guard let cgImage = image.cgImage else {
            throw ImageTranscriptionError.couldNotReadImage
        }

        let request = VNRecognizeTextRequest()
        request.recognitionLevel = .accurate
        request.usesLanguageCorrection = true

        let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
        try handler.perform([request])

        guard let observations = request.results, observations.isEmpty == false else {
            throw ImageTranscriptionError.recognitionFailed
        }

        let lines = observations.compactMap { observation -> String? in
            observation.topCandidates(1).first?.string
        }
        return lines.joined(separator: "\n").trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
