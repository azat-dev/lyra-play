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
    private let importSubtitlesUseCase: ImportSubtitlesUseCase
    private let loadSubtitlesUseCase: LoadSubtitlesUseCase
    
    public var isPlaying: Observable<Bool> = .init(false)
    public var info: Observable<LibraryItemInfoPresentation?> = .init(nil)
    public var subtitlesPresenterViewModel: Observable<SubtitlesPresenterViewModel?> = .init(nil)
    
    private var subtitlesObserver: AnyCancellable?
    private var observers = Set<AnyCancellable>()

    // MARK: - Initializers

    public init(
        trackId: UUID,
        delegate: LibraryItemViewModelDelegate,
        showMediaInfoUseCase: ShowMediaInfoUseCase,
        playMediaUseCase: PlayMediaWithTranslationsUseCase,
        importSubtitlesUseCase: ImportSubtitlesUseCase,
        loadSubtitlesUseCase: LoadSubtitlesUseCase
    ) {

        self.trackId = trackId
        self.delegate = delegate
        self.showMediaInfoUseCase = showMediaInfoUseCase
        self.playMediaUseCase = playMediaUseCase
        self.importSubtitlesUseCase = importSubtitlesUseCase
        self.loadSubtitlesUseCase = loadSubtitlesUseCase
        
        bind(to: playMediaUseCase)
    }
    
    deinit {
        
        subtitlesObserver?.cancel()
        observers.removeAll()
    }
    
    private func bind(to: PlayMediaWithTranslationsUseCase) {
        
        playMediaUseCase.state.publisher.sink { [weak self] state in
         
            guard let self = self else {
                return
            }
            
            var isPlaying = false
            
            if case .playing = state {
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
    
    public func togglePlay() async {
     
        if self.isPlaying.value {
            
            let _ = playMediaUseCase.pause()
            return
        }
        
        let _ = await playMediaUseCase.prepare(
            session: .init(
                mediaId: trackId,
                learningLanguage: "English",
                nativeLanguage: "English"
            )
        )
        
        subtitlesPresenterViewModel.value = SubtitlesPresenterViewModelImpl()
        
        subtitlesObserver = playMediaUseCase.state.publisher.sink { state in
            self.subtitlesPresenterViewModel.value?.update(with: state.subtitlesState)
        }
        
        let _ = playMediaUseCase.play()
    }
    
    
    private func showImportSuccess() {
        
        // TODO:
        print("Import success")
    }
    
    private func attachSubtitlesAfter(language: String, url: URL?) async {
        
        guard let url = url else {
            return
        }
        
        url.startAccessingSecurityScopedResource()
        
        guard let fileData = try? Data(contentsOf: url) else {
            return
        }
        
        let fileName = url.lastPathComponent
        
        let importResult = await importSubtitlesUseCase.importFile(
            trackId: trackId,
            language: language,
            fileName: fileName,
            data: fileData
        )
        
        guard case .success() = importResult else {
            return
        }
        
        showImportSuccess()
    }
    
    public func attachSubtitles(language: String) async {
        
        delegate?.runAttachSubtitlesFlow()
    }
    
    public func finish() {
        
        delegate?.finish()
    }
}
