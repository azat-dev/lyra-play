//
//  DefaultTextToSpeechConverter.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 08.08.22.
//

import Foundation
import AVFoundation

public final class DefaultTextToSpeechConverter: TextToSpeechConverter {
    
    let synthesizer = AVSpeechSynthesizer()
    
    // MARK: - Initializers
    
    public init() {}
    
    // MARK: - Methods
    
    private func getEnhancedVoice(language: String) -> AVSpeechSynthesisVoice? {
        
        let voices = AVSpeechSynthesisVoice.speechVoices()
        return voices.first { $0.language == language && $0.quality == .enhanced }
    }
    
    private static func getTempFilePath() -> URL {
        
        let fileName = "\(UUID().uuidString).caf"
        return FileManager.default.temporaryDirectory
            .appendingPathComponent(fileName, isDirectory: false)
    }
    
    public func convert(text: String, language: String) async -> Result<Data, TextToSpeechConverterError> {
        
        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = getEnhancedVoice(language: language) ?? AVSpeechSynthesisVoice(language: language)
        
        var isFailed = false
        return await withCheckedContinuation { continuation in
            
            let tempFilePath = Self.getTempFilePath()
            defer { try? FileManager.default.removeItem(at: tempFilePath) }
            
            var audioFile: AVAudioFile?
            
            synthesizer.write(utterance) { (buffer: AVAudioBuffer) in
                
                guard !isFailed else {
                    return
                }
                
                guard let pcmBuffer = buffer as? AVAudioPCMBuffer else {
                    
                    let error = NSError(domain: "Wrong buffer format \(buffer)", code: 0)
                    continuation.resume(returning: .failure(.internalError(error)))
                    return
                }
                
                guard pcmBuffer.frameLength > 0 else {
                    
                    guard let data = try? Data(contentsOf: tempFilePath) else {
                        
                        continuation.resume(returning: .failure(.internalError(nil)))
                        return
                    }
                    
                    continuation.resume(returning: .success(data))
                    return
                }
                
                do {
                 
                    if audioFile == nil {
                        
                        audioFile = try AVAudioFile(
                            forWriting: tempFilePath,
                            settings: buffer.format.settings,
                            commonFormat: .pcmFormatInt16,
                            interleaved: false
                        )
                    }
                    
                    try audioFile!.write(from: pcmBuffer)
                    
                } catch {
                    
                    isFailed = true
                    continuation.resume(returning: .failure(.internalError(error)))
                }
            }
        }
    }
}
