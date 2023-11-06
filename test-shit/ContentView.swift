//
//  ContentView.swift
//  test-shit
//
//  Created by jackson mowatt gok on 4/11/2023.
//

import SwiftUI
import AVKit
import Speech


struct ContentView: View {
    @State var audioPlayer: AVAudioPlayer!
    @State private var hasTranscriptionPermission: Bool = false

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
                }
                .onAppear {
                    preparePlayer()
                }
        }
    
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
