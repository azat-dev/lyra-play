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
    
    func chooseSubtitles(completion: @escaping (_ url: URL?) -> Void)
    func showImportSubtitlesError() -> Void
}

public protocol LibraryItemViewModelOutput {

    var isPlaying: Observable<Bool> { get }
    
    var info: Observable<LibraryItemInfoPresentation?> { get }
    
    var subtitlesPresenterViewModel: Observable<SubtitlesPresenterViewModel?> { get }
}

public protocol LibraryItemViewModelInput {
    
    func load() async
    
    func togglePlay() async
    
    func attachSubtitles(language: String) async
}

public protocol LibraryItemViewModel: LibraryItemViewModelOutput, LibraryItemViewModelInput {
}

// MARK: - Implementations

public final class DefaultLibraryItemViewModel: LibraryItemViewModel {
    
    private let trackId: UUID
    private let coordinator: LibraryItemCoordinator
    private let showMediaInfoUseCase: ShowMediaInfoUseCase
    private let playerControlUseCase: PlayerControlUseCase
    private let currentPlayerStateUseCase: CurrentPlayerStateUseCaseOutput
    private let importSubtitlesUseCase: ImportSubtitlesUseCase
    private let loadSubtitlesUseCase: LoadSubtitlesUseCase
    
    public var isPlaying: Observable<Bool> = Observable(false)
    public var info: Observable<LibraryItemInfoPresentation?> = Observable(nil)
    public var subtitlesPresenterViewModel: Observable<SubtitlesPresenterViewModel?> = Observable(nil)
    
    public init(
        trackId: UUID,
        coordinator: LibraryItemCoordinator,
        showMediaInfoUseCase: ShowMediaInfoUseCase,
        currentPlayerStateUseCase: CurrentPlayerStateUseCaseOutput,
        playerControlUseCase: PlayerControlUseCase,
        importSubtitlesUseCase: ImportSubtitlesUseCase,
        loadSubtitlesUseCase: LoadSubtitlesUseCase
    ) {
        
        self.trackId = trackId
        self.coordinator = coordinator
        self.showMediaInfoUseCase = showMediaInfoUseCase
        self.playerControlUseCase = playerControlUseCase
        self.currentPlayerStateUseCase = currentPlayerStateUseCase
        self.importSubtitlesUseCase = importSubtitlesUseCase
        self.loadSubtitlesUseCase = loadSubtitlesUseCase
        
        bind(to: currentPlayerStateUseCase)
    }
    
    private func updatePlayingState() {
        
        let currentTrackId = currentPlayerStateUseCase.info.value?.id
        let state = currentPlayerStateUseCase.state.value
        
        let isPlaying = (state == .playing && currentTrackId == trackId.uuidString)
        
        guard isPlaying != self.isPlaying.value else {
            return
        }

        self.isPlaying.value = isPlaying
    }
    
    private func bind(to currentPlayerStateUseCase: CurrentPlayerStateUseCaseOutput) {
        
        currentPlayerStateUseCase.state.observe(on: self) { [weak self] _ in
            self?.updatePlayingState()
        }
        
        currentPlayerStateUseCase.info.observe(on: self) { [weak self] _ in
            self?.updatePlayingState()
        }
    }
}

// MARK: - Input

extension DefaultLibraryItemViewModel {
    
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
    
    private func loadSubtitles() async {

        let result = await loadSubtitlesUseCase.load(for: trackId, language: "English")

        let subtitles = try! result.get()
        
        let timeSlotsParser = SubtitlesTimeSlotsParser()

        let subtitlesViewModel = DefaultSubtitlesPresenterViewModel(
            subtitles: subtitles,
            subtitlesTimeSlots: timeSlotsParser.parse(from: subtitles)
        )
        
        Task {
            
            await subtitlesViewModel.load()
            await subtitlesViewModel.play(at: 0.0)
        }
        subtitlesPresenterViewModel.value = subtitlesViewModel
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
            
            let _ = await playerControlUseCase.pause()
            return
        }
        
        let _ = await playerControlUseCase.play(trackId: trackId)
        await loadSubtitles()
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
            coordinator.showImportSubtitlesError()
            return
        }
        
        showImportSuccess()
    }
    
    public func attachSubtitles(language: String) async {
        
        coordinator.chooseSubtitles { [weak self] url in
            
            guard let attachSubtitles = self?.attachSubtitlesAfter else {
                return
            }
            
            Task {
                await attachSubtitles(language, url)
            }
        }
    }
}
