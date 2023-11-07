import UIKit

class AppDelegate: NSObject, UIApplicationDelegate {

    func application(_ application: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        guard url.isFileURL else { return false }

        let fileManager = FileManager.default
        guard let documentsPath = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else { return false }

        // Create a "VoiceMemos" folder if it doesn't exist
        let voiceMemosPath = documentsPath.appendingPathComponent("VoiceMemos")
        if !fileManager.fileExists(atPath: voiceMemosPath.path) {
            do {
                try fileManager.createDirectory(at: voiceMemosPath, withIntermediateDirectories: true, attributes: nil)
            } catch {
                print("Failed to create VoiceMemos directory: \(error)")
                return false
            }
        }

        // Save the file in the "VoiceMemos" folder
        let destinationURL = voiceMemosPath.appendingPathComponent(url.lastPathComponent)
        
        do {
            // If the file already exists at the destination, remove it first
            if fileManager.fileExists(atPath: destinationURL.path) {
                try fileManager.removeItem(at: destinationURL)
            }
            // Copy the file from the temporary location to the permanent location
            try fileManager.copyItem(at: url, to: destinationURL)
            
            // Now you can use `destinationURL` to access the file later on
            print("Saved audio file to: \(destinationURL.path)")
            
            // Here you can post a notification or use some other method to update your UI or model
            // NotificationCenter.default.post(name: .newAudioFileSaved, object: destinationURL)
            
            // ... or pass the URL to your transcription function, etc.

        } catch {
            print("Failed to save audio file: \(error)")
            return false
        }

        return true
    }
}




