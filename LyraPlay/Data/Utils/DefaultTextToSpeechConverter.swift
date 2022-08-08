//
//  DefaultTextToSpeechConverter.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 08.08.22.
//

import Foundation
import AVFoundation

public final class DefaultTextToSpeechConverter: TextToSpeechConverter {
    
    // MARK: - Initializers
    
    public init() {}
    
    // MARK: - Methods
    
    private func getEnhancedVoice(language: String) -> AVSpeechSynthesisVoice? {
        
        let voices = AVSpeechSynthesisVoice.speechVoices()
        dump(voices.filter { $0.language == language})
        return voices.first { $0.language == language && $0.quality == .enhanced }
    }
    
    private static func save(buffer: AVAudioPCMBuffer, pathUrl: URL) throws {
        
        let audioFile = try AVAudioFile(
            forWriting: pathUrl,
            settings: buffer.format.settings,
            commonFormat: .pcmFormatInt16,
            interleaved: false
        )
        
        try audioFile.write(from: buffer)
    }
    
    private static func convertBufferToData(buffer: AVAudioPCMBuffer) throws -> Data {
        
        let fileName = "\(UUID().uuidString).caf"

        let tempFileUrl = FileManager.default.temporaryDirectory
            .appendingPathComponent(fileName, isDirectory: false)
        
        try save(buffer: buffer, pathUrl: tempFileUrl)
        
        let data = try Data(contentsOf: tempFileUrl)
        
        try FileManager.default.removeItem(at: tempFileUrl)
        
        return data
    }
    
    public func convert(text: String, language: String) async -> Result<Data, TextToSpeechConverterError> {
        
        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = getEnhancedVoice(language: language) ?? AVSpeechSynthesisVoice(language: language)
        
        let synthesizer = AVSpeechSynthesizer()
        
        return await withCheckedContinuation { continuation in
            
            synthesizer.write(utterance) { (buffer: AVAudioBuffer) in
                
               guard let pcmBuffer = buffer as? AVAudioPCMBuffer else {
                   
                   let error = NSError(domain: "Wrong buffer format \(buffer)", code: 0)
                   continuation.resume(returning: .failure(.internalError(error)))
                   return
               }
                
                guard pcmBuffer.frameLength > 0 else {
                    
                    let error = NSError(domain: "Buffer is empty \(buffer)", code: 0)
                    continuation.resume(returning: .failure(.internalError(error)))
                    return
                }
                
                do {
                    
                    let data = try Self.convertBufferToData(buffer: pcmBuffer)
                    continuation.resume(returning: .success(data))
                } catch {
                    
                    continuation.resume(returning: .failure(.internalError(error)))
                    return
                }
            }
        }
    }
}
