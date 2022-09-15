//
//  SubtitlesRepositoryMockDeprecated.swift
//  LyraPlayTests
//
//  Created by Azat Kaiumov on 09.07.22.
//

import Foundation
import LyraPlay

class SubtitlesRepositoryMockDeprecated: SubtitlesRepository {
   
   public var items = [SubtitlesInfo]()
   
   func put(info item: SubtitlesInfo) async -> Result<SubtitlesInfo, SubtitlesRepositoryError> {
       
       let index = items.firstIndex { $0.mediaFileId == item.mediaFileId && $0.language == item.language }
       
       guard let index = index else {
           items.append(item)
           return .success(item)
       }
       
       items[index] = item
       return .success(item)
   }
   
   func fetch(mediaFileId: UUID, language: String) async -> Result<SubtitlesInfo, SubtitlesRepositoryError> {
       
       let item = items.first { $0.mediaFileId == mediaFileId && $0.language == language }
       
       guard let item = item else {
           return .failure(.itemNotFound)
       }
       
       return .success(item)
   }
   
   func list() async -> Result<[SubtitlesInfo], SubtitlesRepositoryError> {
       return .success(items)
   }
   
   func list(mediaFileId: UUID) async -> Result<[SubtitlesInfo], SubtitlesRepositoryError> {
       return .success(items.filter { $0.mediaFileId == mediaFileId })
   }
   
   func delete(mediaFileId: UUID, language: String) async -> Result<Void, SubtitlesRepositoryError> {
       
       let index = items.firstIndex { $0.mediaFileId == mediaFileId && $0.language == language }
       
       guard let index = index else {
           return .failure(.itemNotFound)
       }

       items.remove(at: index)
       return .success(())
   }
}
