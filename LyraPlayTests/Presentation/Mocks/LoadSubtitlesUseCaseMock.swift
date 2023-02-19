//
//  LoadSubtitlesUseCaseMock.swift
//  LyraPlayTests
//
//  Created by Azat Kaiumov on 10.07.22.
//

import Foundation
import LyraPlay

class LoadSubtitlesUseCaseMockDeprecated: LoadSubtitlesUseCase {

    typealias LoadSubtitlesCallback = (_ mediaFileId: UUID, _ language: String) async -> Result<Subtitles, LoadSubtitlesUseCaseError>
    
    public var willReturn: LoadSubtitlesCallback? = nil
    
    func load(for mediaFileId: UUID, language: String) async -> Result<Subtitles, LoadSubtitlesUseCaseError> {
        
        guard let willReturn = willReturn else {
            fatalError("Not implemented")
        }
        
        return await willReturn(mediaFileId, language)
    }
}
