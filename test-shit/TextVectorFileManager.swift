//
//  TextVectorFileManager.swift
//  test-shit
//
//  Created by jackson mowatt gok on 7/11/2023.
//

import NaturalLanguage
import Foundation

class TextVectorFileManager {
    private let fileURL: URL
    private let sentenceEmbedding: NLEmbedding
    
    init?(fileName: String) {
        guard let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else { return nil }
        self.fileURL = url.appendingPathComponent(fileName)
        
        guard let embedding = NLEmbedding.sentenceEmbedding(for: .english) else {
            fatalError("Sentence embedding for English is not available")
        }
        self.sentenceEmbedding = embedding
    }
    
    func vectorizeAndStore(sentences: [String]) {
        var vectorsDictionary = readVectorsFromFile()
        
        for sentence in sentences {
            guard let vector = sentenceEmbedding.vector(for: sentence) else {
                print("No vector available for text: \(sentence)")
                continue
            }
            vectorsDictionary[sentence] = vector
        }
        
        writeVectorsToFile(vectorsDictionary: vectorsDictionary)
    }
    
    func findSimilarSentences(to inputSentence: String, maxCount: Int) -> [(String, Double)] {
        var similarSentences = [(String, Double)]()

        let vectorsDictionary = readVectorsFromFile()
        
        for (sentence, _) in vectorsDictionary {
            let distance = sentenceEmbedding.distance(between: inputSentence, and: sentence, distanceType: .cosine)
            similarSentences.append((sentence, distance))
        }
        
        similarSentences.sort { $0.1 < $1.1 }
        
        return Array(similarSentences.prefix(maxCount))
    }
    
    private func writeVectorsToFile(vectorsDictionary: [String: [Double]]) {
        do {
            let data = try JSONSerialization.data(withJSONObject: vectorsDictionary, options: [])
            try data.write(to: fileURL, options: [.atomicWrite])
        } catch {
            print("Failed to write vectors to file: \(error)")
        }
    }
    
    private func readVectorsFromFile() -> [String: [Double]] {
        do {
            let data = try Data(contentsOf: fileURL)
            if let vectorsDictionary = try JSONSerialization.jsonObject(with: data, options: []) as? [String: [Double]] {
                return vectorsDictionary
            } else {
                print("Could not interpret file contents as a vectors dictionary")
                return [:]
            }
        } catch {
            print("Failed to read vectors from file or file not found: \(error)")
            return [:]
        }
    }
}

