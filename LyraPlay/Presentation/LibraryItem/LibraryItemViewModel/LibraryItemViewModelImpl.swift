//
//  LibraryItemViewModelImpl.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 05.09.2022.
//

import Foundation
import Combine

public protocol LibraryItemViewModelDelegate: AnyObject {
    
    func runAttachSubtitlesFlow()
    
    func finish()
}

public final class LibraryItemViewModelImpl: LibraryItemViewModel {

    // MARK: - Properties

    private let trackId: UUID
    private weak var delegate: LibraryItemViewModelDelegate?
    
    private let showMediaInfoUseCase: ShowMediaInfoUseCase
    private let playMediaUseCase: PlayMediaWithTranslationsUseCase
    
    public var isPlaying: Observable<Bool> = .init(false)
    public var info: Observable<LibraryItemInfoPresentation?> = .init(nil)
    
    private var observers = Set<AnyCancellable>()

    // MARK: - Initializers

    public init(
        trackId: UUID,
        delegate: LibraryItemViewModelDelegate,
        showMediaInfoUseCase: ShowMediaInfoUseCase,
        playMediaUseCase: PlayMediaWithTranslationsUseCase
    ) {

        self.trackId = trackId
        self.delegate = delegate
        self.showMediaInfoUseCase = showMediaInfoUseCase
        self.playMediaUseCase = playMediaUseCase
        
        bind(to: playMediaUseCase)
    }
    
    deinit {
        observers.removeAll()
    }
    
    private func bind(to: PlayMediaWithTranslationsUseCase) {
        
        playMediaUseCase.state.publisher.sink { [weak self] state in
         
            guard let self = self else {
                return
            }
            
            let currentPlayingMediaId = state.session?.mediaId
            var isPlaying = false
            
            if
                case .playing = state,
                currentPlayingMediaId == self.trackId
            {
                isPlaying = true
            }
            
            guard isPlaying != self.isPlaying.value else {
                return
            }

            self.isPlaying.value = isPlaying
        }.store(in: &observers)
    }
}

// MARK: - Input Methods

extension LibraryItemViewModelImpl {

    private func formatDuration(_ value: Double) -> String {
        return "\(value)"
    }
    
    private func mapInfo(_ info: MediaInfo) -> LibraryItemInfoPresentation {
        
        return LibraryItemInfoPresentation(
            title: info.title,
            artist: info.artist ?? "",
            coverImage: info.coverImage,
            duration: formatDuration(info.duration)
        )
    }
    
    public func load() async {
        
        let resultMediaInfo = await showMediaInfoUseCase.fetchInfo(trackId: trackId)
        
        guard case .success(let mediaInfo) = resultMediaInfo else {
            return
        }
        
        self.info.value = mapInfo(mediaInfo)
    }
    
    private func startNewSession() async {
        
        let prepareResult = await playMediaUseCase.prepare(
            session: .init(
                mediaId: trackId,
                learningLanguage: "English",
                nativeLanguage: "English"
            )
        )
        
        guard case .success = prepareResult else {
            return
        }
        
        let _ = playMediaUseCase.play()
    }
    
    public func togglePlay() async {
     
        if
            let session = playMediaUseCase.state.value.session,
            session.mediaId == trackId
        {
           
            let _ = playMediaUseCase.togglePlay()
            return
        }
        
        await startNewSession()
    }
    
    
    private func showImportSuccess() {
        
        // TODO:
        print("Import success")
    }
    
    public func attachSubtitles(language: String) async {
        
        delegate?.runAttachSubtitlesFlow()
    }
    
    public func dispose() {
        
        delegate?.finish()
    }
}
