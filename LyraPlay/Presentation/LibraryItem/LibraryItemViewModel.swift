//
//  LibraryItemViewModel.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 02.07.22.
//

import Foundation

// MARK: - Interfaces

public struct LibraryItemInfoPresentation {
    
    public var title: String
    public var artist: String
    public var coverImage: Data
    public var duration: String
}

public protocol LibraryItemCoordinator {
    
    func chooseSubtitles() async -> Result<URL?, Error>
}

public protocol LibraryItemViewModelOutput {

    var isPlaying: Observable<Bool> { get }
    var info: Observable<LibraryItemInfoPresentation?> { get }
}

public protocol LibraryItemViewModelInput {
    
    func load() async -> Result<Void, Error>
    
    func play() async -> Result<Void, Error>
}

public protocol LibraryItemViewModel: LibraryItemViewModelOutput, LibraryItemViewModelInput {
}

// MARK: - Implementations

public final class DefaultLibraryItemViewModel: LibraryItemViewModel {
    
    private let trackId: UUID
    private let coordinator: LibraryItemCoordinator
    private let showMediaInfoUseCase: ShowMediaInfoUseCase
    
    public var isPlaying: Observable<Bool> = Observable(false)
    public var info: Observable<LibraryItemInfoPresentation?> = Observable(nil)
    
    public init(
        trackId: UUID,
        coordinator: LibraryItemCoordinator,
        showMediaInfoUseCase: ShowMediaInfoUseCase
    ) {
        
        self.trackId = trackId
        self.coordinator = coordinator
        self.showMediaInfoUseCase = showMediaInfoUseCase
    }
}

// MARK: - Input

extension DefaultLibraryItemViewModel {
    
    private func formatDuration(_ value: Double) -> String {
        return "\(value)"
    }
    
    private func mapInfo(_ info: MediaInfo) -> LibraryItemInfoPresentation {
        
        return LibraryItemInfoPresentation(
            title: info.title ?? "",
            artist: info.artist ?? "",
            coverImage: info.coverImage,
            duration: formatDuration(info.duration)
        )
    }
    
    public func load() async -> Result<Void, Error> {
        
        let resultMediaInfo = await showMediaInfoUseCase.fetchInfo(trackId: trackId)
        
        guard case .success(let mediaInfo) = resultMediaInfo else {
            let error = NSError(domain: "", code: 0)
            return .failure(error)
        }

        
        self.info.value = mapInfo(mediaInfo)
        return .success(())
    }
    
    public func play() async -> Result<Void, Error> {
        
        return .success(())
    }
}
