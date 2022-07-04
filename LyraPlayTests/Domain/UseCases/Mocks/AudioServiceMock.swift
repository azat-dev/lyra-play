//
//  AudioServiceMock.swift
//  LyraPlayTests
//
//  Created by Azat Kaiumov on 05.07.22.
//

import Foundation
import LyraPlay

class AudioServiceMock: AudioService {
    
    public var fileId: Observable<String?> = Observable(nil)
    
    public var isPlaying = Observable(false)
    
    public var currentTime = Observable(0.0)
    
    public var volume = Observable(0.0)

    
    func play(fileId: String, data: Data) async -> Result<Void, Error> {
    
        self.fileId.value = fileId
        isPlaying.value = true
        
        DispatchQueue.global(qos: .background).asyncAfter(deadline: .now() + 0.1) { [weak self] in
            
            guard
                let self = self,
                self.isPlaying.value
            else {
                return
            }
            
            
            self.currentTime.value += 1
        }
        
        return .success(())
    }
    
    func pause() async -> Result<Void, Error> {
        
        isPlaying.value = false
        
        return .success(())
    }
    
    func stop() async -> Result<Void, Error> {
        
        fileId.value = nil
        isPlaying.value = false
        
        return .success(())
    }
    
    func seek(time: Double) async -> Result<Void, Error> {
        
        currentTime.value = time
        return .success(())
    }
    
    func setVolume(value: Double) async -> Result<Void, Error> {
        
        volume.value = value
        return .success(())
    }
}
