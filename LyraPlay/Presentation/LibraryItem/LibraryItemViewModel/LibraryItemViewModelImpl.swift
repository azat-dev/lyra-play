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
    private let playMediaUseCase: PlayMediaWithInfoUseCase
    
    public var isPlaying: Observable<Bool> = .init(false)
    public var isAttachingSubtitles = CurrentValueSubject<Bool, Never>(false)
    public var isPreparingToPlay = CurrentValueSubject<Bool, Never>(false)
    
    public var info: Observable<LibraryItemInfoPresentation?> = .init(nil)
    
    private var observers = Set<AnyCancellable>()
    
    private var playerStateObserver: AnyCancellable?
    private var loadStateObserver: AnyCancellable?
    
    
    // MARK: - Initializers
    
    public init(
        trackId: UUID,
        delegate: LibraryItemViewModelDelegate,
        showMediaInfoUseCase: ShowMediaInfoUseCase,
        playMediaUseCase: PlayMediaWithInfoUseCase
    ) {
        
        self.trackId = trackId
        self.delegate = delegate
        self.showMediaInfoUseCase = showMediaInfoUseCase
        self.playMediaUseCase = playMediaUseCase
        
        bind(to: playMediaUseCase)
    }
    
    deinit {
        observers.removeAll()
        playerStateObserver = nil
        loadStateObserver = nil
    }
    
    private func pipePlayerState(_ state: CurrentValueSubject<PlayMediaWithInfoUseCasePlayerState, Never>) {
        
        playerStateObserver = state.sink { [weak self] newState in

            guard let self = self else {
                return
            }
            
            switch newState {
                
            case .playing, .pronouncingTranslations:
                self.isPlaying.value = true
                
            default:
                self.isPlaying.value = false
            }
        }
    }
    
    private func pipeLoadState(_ state: CurrentValueSubject<PlayMediaWithInfoUseCaseLoadState, Never>) {
        
        loadStateObserver = state.sink { [weak self] newState in

            guard let self = self else {
                return
            }
            
            guard case .loaded(let playerState, _) = newState else {
                self.isPlaying.value = false
                return
            }
            
            self.pipePlayerState(playerState)
        }
    }
    
    private func updateState(_ state: PlayMediaWithInfoUseCaseState) {
        
        playerStateObserver = nil
        loadStateObserver = nil
        
        guard
            case .activeSession(let session, let loadState) = state,
            session.mediaId == trackId
        else {
            
            isPlaying.value = false
            return
        }
        
        pipeLoadState(loadState)
    }
    
    private func bind(to playMediaUseCase: PlayMediaWithInfoUseCase) {
        
        observers.removeAll()
        
        playMediaUseCase.state.sink { [weak self] state in
            
            self?.updateState(state)
            
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
        
        defer { isPreparingToPlay.value = false }
        isPreparingToPlay.value = true
        
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
        
        let _ = playMediaUseCase.resume()
    }
    
    public func togglePlay() async {
        
        guard
            case .activeSession(let session, _) = playMediaUseCase.state.value,
            session.mediaId == trackId
        else {
            
            await startNewSession()
            return
        }
        
        let _ = playMediaUseCase.togglePlay()
    }
    
    public func attachSubtitles(language: String) async {
        
        delegate?.runAttachSubtitlesFlow()
    }
    
    public func dispose() {
        
        delegate?.finish()
    }
}
