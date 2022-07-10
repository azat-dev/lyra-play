//
//  LoadSubtitlesUseCaseMock.swift
//  LyraPlayTests
//
//  Created by Azat Kaiumov on 10.07.22.
//

import Foundation
import LyraPlay

class LoadSubtitlesUseCaseMock: LoadSubtitlesUseCase {

    typealias LoadSubtitlesCallback = (_ mediaFileId: UUID, _ language: String) async -> Result<Subtitles, LoadSubtitlesUseCaseError>
    
    public var resolveLoad: LoadSubtitlesCallback? = nil
    
    func load(for mediaFileId: UUID, language: String) async -> Result<Subtitles, LoadSubtitlesUseCaseError> {
        
        guard let resolveLoad = resolveLoad else {
            fatalError("Not implemented")
        }
        
        return await resolveLoad(mediaFileId, language)
    }
}
