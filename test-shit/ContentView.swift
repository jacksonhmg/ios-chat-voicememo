//
//  ContentView.swift
//  test-shit
//
//  Created by jackson mowatt gok on 4/11/2023.
//

import SwiftUI
import AVKit
import Speech
import Foundation
import NaturalLanguage


struct Transcription: Codable {
    let text: String
}

extension String {
    // Function to chunk the string into sentences.
    func chunkedIntoSentences() -> [String] {
        var sentences = [String]()
        let tokenizer = NLTokenizer(unit: .sentence)
        tokenizer.string = self
        
        tokenizer.enumerateTokens(in: self.startIndex..<self.endIndex) { sentenceRange, _ in
            let sentence = String(self[sentenceRange])
            sentences.append(sentence)
            return true
        }
        
        return sentences
    }
}

struct ContentView: View {
    @State var audioPlayer: AVAudioPlayer!
    @State private var hasTranscriptionPermission: Bool = false
    @State var transcribedText: String = "empty"

        var body: some View {
                VStack {
                        Text("play").font(.system(size: 45)).font(.largeTitle)
                    HStack {
                        Spacer()
                        Button(action: {
                            self.audioPlayer.play()
                        }) {
                            Image(systemName: "play.circle.fill").resizable()
                                .frame(width: 50, height: 50)
                                .aspectRatio(contentMode: .fit)
                        }
                        Spacer()
                        Button(action: {
                            self.audioPlayer.pause()
                        }) {
                            Image(systemName: "pause.circle.fill").resizable()
                                .frame(width: 50, height: 50)
                                .aspectRatio(contentMode: .fit)
                        }
                        Spacer()
                    }
                    Button("Request Transcription Permission") {
                        self.requestTranscribePermissions()
                    }
                    .disabled(hasTranscriptionPermission)
                    Button("Transcribe Audio") {
                        guard let soundURL = Bundle.main.url(forResource: "audio", withExtension: "m4a") else {
                            print("Audio resource not found.")
                            return
                        }
                        self.transcribeAudio(withApiKey: "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") { result in
                            DispatchQueue.main.async { // Ensure you're on the main thread when updating the UI or handling the result
                                switch result {
                                case .success(let data):
                                    do {
                                        let decoder = JSONDecoder()
                                        let transcriptionResult = try decoder.decode(Transcription.self, from: data)
                                        print("Transcription: \(transcriptionResult.text)")
                                        self.transcribedText = transcriptionResult.text
                                    } catch {
                                        print("Error decoding transcription: \(error)")
                                    }
                                case .failure(let error):
                                    // Handle the error case
                                    print("Error transcribing audio: \(error.localizedDescription)")
                                    // Here you can show the error to the user or update your state to indicate the error
                                }
                            }
                        }

                    }
                    Text(self.transcribedText)
                }
                .onAppear {
                    preparePlayer()
                }
        }
    
    

    func transcribeAudio(withApiKey apiKey: String, completion: @escaping (Result<Data, Error>) -> Void) {
        // Assuming `audio.m4a` is in the main bundle
        guard let audioURL = Bundle.main.url(forResource: "audio", withExtension: "m4a") else {
            print("Audio file not found in bundle.")
            return
        }

        // Create the url for the API request
        let url = URL(string: "https://api.openai.com/v1/audio/transcriptions")!

        // Set up the request
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")

        let boundary = "Boundary-\(UUID().uuidString)"
        request.addValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")

        // Create the body of the request
        var data = Data()
        data.append("--\(boundary)\r\n".data(using: .utf8)!)
        data.append("Content-Disposition: form-data; name=\"model\"\r\n\r\n".data(using: .utf8)!)
        data.append("whisper-1\r\n".data(using: .utf8)!)
        data.append("--\(boundary)\r\n".data(using: .utf8)!)
        data.append("Content-Disposition: form-data; name=\"file\"; filename=\"\(audioURL.lastPathComponent)\"\r\n".data(using: .utf8)!)
        data.append("Content-Type: audio/m4a\r\n\r\n".data(using: .utf8)!)
        if let audioData = try? Data(contentsOf: audioURL) {
            data.append(audioData)
        }
        data.append("\r\n".data(using: .utf8)!)
        data.append("--\(boundary)--\r\n".data(using: .utf8)!)

        // Set the body of the request to the multipart form data
        request.httpBody = data

        // Start the upload task
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            if let data = data {
                completion(.success(data))
            } else {
                let error = NSError(domain: "TranscriptionError", code: 0, userInfo: [NSLocalizedDescriptionKey: "Data was not retrieved from request"])
                completion(.failure(error))
            }
        }
        task.resume()
    }


    
    
//    func transcribeAudio(url: URL) {
//        // create a new recognizer and point it at our audio
//        let recognizer = SFSpeechRecognizer()
//        let request = SFSpeechURLRecognitionRequest(url: url)
//
//        // start recognition!
//        recognizer?.recognitionTask(with: request) { (result, error) in
//            // abort if we didn't get any transcription back
//            guard let result = result else {
//                print("There was an error: \(error!)")
//                return
//            }
//
//            // if we got the final transcription back, print it
//            if result.isFinal {
//                // pull out the best transcription...
////                print(result.bestTranscription.formattedString)
//                self.transcribedText = result.bestTranscription.formattedString
//            }
//        }
//    }
    
    func preparePlayer() {
        guard let soundURL = Bundle.main.url(forResource: "audio", withExtension: "m4a") else {
            print("Audio resource not found.")
            return
        }
        
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: soundURL)
            audioPlayer?.prepareToPlay()
        } catch {
            print("Failed to initialize the audio player: \(error)")
        }
    }
    
    func requestTranscribePermissions() {
        SFSpeechRecognizer.requestAuthorization { authStatus in
            DispatchQueue.main.async {
                switch authStatus {
                case .authorized:
                    print("Good to go!")
                    self.hasTranscriptionPermission = true
                case .denied:
                    print("User denied access to speech recognition")
                    self.hasTranscriptionPermission = false
                case .restricted:
                    print("Speech recognition restricted on this device")
                    self.hasTranscriptionPermission = false
                case .notDetermined:
                    print("Speech recognition not yet authorized")
                    self.hasTranscriptionPermission = false
                @unknown default:
                    print("Unknown authorization status")
                    self.hasTranscriptionPermission = false
                }
            }
        }
    }
}
//
//func requestTranscribePermissions() {
//    SFSpeechRecognizer.requestAuthorization { [unowned self] authStatus in
//        DispatchQueue.main.async {
//            if authStatus == .authorized {
//                print("Good to go!")
//            } else {
//                print("Transcription permission was declined.")
//            }
//        }
//    }
//}

#Preview {
    ContentView()
}
