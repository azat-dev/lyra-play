//
//  TextToSpeechConverterImpl.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 08.08.22.
//

import Foundation
import AVFoundation

public final class TextToSpeechConverterImpl: TextToSpeechConverter {
    
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
    
    private func writeSpeechToFile(utterance: AVSpeechUtterance) async -> Result<URL, Error>{
        
        var isFailed = false
        
        let tempFilePath = Self.getTempFilePath()
        
        
        var audioFile: AVAudioFile?
        
        return await withCheckedContinuation { continuation in
            
            synthesizer.write(utterance) { (buffer: AVAudioBuffer) in
                
                guard !isFailed else {
                    return
                }
                
                guard let pcmBuffer = buffer as? AVAudioPCMBuffer else {
                    
                    let error = NSError(domain: "Wrong buffer format \(buffer)", code: 0)
                    continuation.resume(returning: .failure(error))
                    return
                }
                
                guard pcmBuffer.frameLength > 0 else {
                    continuation.resume(returning: .success(tempFilePath))
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
                    continuation.resume(returning: .failure(error))
                }
            }
        }
    }
    
    public func convert(text: String, language: String) async -> Result<Data, TextToSpeechConverterError> {
        
        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = getEnhancedVoice(language: language) ?? AVSpeechSynthesisVoice(language: language)
        
        let result = await writeSpeechToFile(utterance: utterance)
        
        guard case .success(let url) = result else {

            return .failure(.internalError(result.error))
        }
        
        defer { try? FileManager.default.removeItem(at: url) }

        guard let data = try? Data(contentsOf: url) else {
            return .failure(.internalError(nil))
        }
        
        return .success(data)
    }
}
