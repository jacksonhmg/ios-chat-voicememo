//
//  ContentView.swift
//  test-shit
//
//  Created by jackson mowatt gok on 4/11/2023.
//

import SwiftUI
import AVKit


struct ContentView: View {
    @State var audioPlayer: AVAudioPlayer!
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
                }
                .onAppear {
                    if let sound = Bundle.main.path(forResource: "audio", ofType: "m4a") {
                        do {
                            self.audioPlayer = try AVAudioPlayer(contentsOf: URL(fileURLWithPath: sound))
                        } catch {
                            print("Failed to initialize the audio player: \(error)")
                        }
                    } else {
                        print("Audio resource not found.")
                    }
                }
        }
}

#Preview {
    ContentView()
}
