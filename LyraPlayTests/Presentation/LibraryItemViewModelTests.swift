////
////  LibraryItemViewModel.swift
////  LyraPlayTests
////
////  Created by Azat Kaiumov on 02.07.22.
////
//
import Foundation
import LyraPlay
import XCTest
//
//class LibraryItemViewModelTests: XCTestCase {
//    
//    fileprivate typealias SUT = (
//        coordinator: LibraryItemCoordinatorMock,
//        showMediaInfoUseCase: ShowMediaInfoUseCaseMock,
//        playMediaUseCase: PlayMediaUseCaseMock,
//        currentPlayerStateUseCase: CurrentPlayerStateUseCaseMock,
//        importSubtitlesUseCase: ImportSubtitlesUseCaseMock
//    )
//    
//    fileprivate func createSUT() -> SUT {
//        
//        let coordinator = LibraryItemCoordinatorMock()
//        
//        let showMediaInfoUseCase = ShowMediaInfoUseCaseMock()
//        let currentPlayerStateUseCase = CurrentPlayerStateUseCaseMock(showMediaInfoUseCase: showMediaInfoUseCase)
//        let playMediaUseCase = PlayMediaUseCaseMock(currentPlayerStateUseCase: currentPlayerStateUseCase)
//        
//        let importSubtitlesUseCase = ImportSubtitlesUseCaseMock()
//        
//        return (
//            coordinator,
//            showMediaInfoUseCase,
//            playMediaUseCase,
//            currentPlayerStateUseCase,
//            importSubtitlesUseCase
//        )
//    }
//    
//    fileprivate func createViewModel(trackId: UUID, sut: SUT) -> LibraryItemViewModel {
//        
//        let viewModel = LibraryItemViewModelImpl(
//            trackId: trackId,
//            coordinator: sut.coordinator,
//            showMediaInfoUseCase: sut.showMediaInfoUseCase,
//            currentPlayerStateUseCase: sut.currentPlayerStateUseCase,
//            playMediaUseCase: sut.playMediaUseCase,
//            importSubtitlesUseCase: sut.importSubtitlesUseCase
//        )
//        
//        detectMemoryLeak(instance: viewModel)
//        return viewModel
//    }
//    
//    func testLoadNotExistingTrack() async throws {
//        
//        let sut = createSUT()
//        let viewModel = createViewModel(trackId: UUID(), sut: sut)
//        
//        await viewModel.load()
//        // TODO: Implement "doesn't exist" logic
//    }
//    
//    private func setUpTestTrack(trackId: UUID, sut: SUT) {
//        
//        sut.showMediaInfoUseCase.tracks[trackId] = MediaInfo(
//            id: trackId.uuidString,
//            coverImage: Data(),
//            title: "Test \(trackId)",
//            duration: 20,
//            artist: "Artist \(trackId)"
//        )
//    }
//    
//    func testLoad() async throws {
//        
//        let sut = createSUT()
//        let trackId = UUID()
//        
//        let viewModel = createViewModel(trackId: trackId, sut: sut)
//        setUpTestTrack(trackId: trackId, sut: sut)
//        
//        let mediaInfoSequence = self.expectSequence([false, true])
//        let playingSequence = self.expectSequence([false])
//        
//        mediaInfoSequence.observe(viewModel.info, mapper: { $0 != nil })
//        playingSequence.observe(viewModel.isPlaying)
//        
//        await viewModel.load()
//        
//        playingSequence.wait(timeout: 3, enforceOrder: true)
//        mediaInfoSequence.wait(timeout: 3, enforceOrder: true)
//        
//        let isPlaying = viewModel.isPlaying.value
//        XCTAssertEqual(isPlaying, false)
//    }
//    
//    func testTogglePlay() async throws {
//        
//        let sut = createSUT()
//        let trackId = UUID()
//        
//        let viewModel = createViewModel(trackId: trackId, sut: sut)
//        setUpTestTrack(trackId: trackId, sut: sut)
//        
//        let playingSequence = self.expectSequence([false, true, false, true])
//        playingSequence.observe(viewModel.isPlaying)
//        
//        let _ = await viewModel.load()
//        
//        await viewModel.togglePlay()
//        await viewModel.togglePlay()
//        await viewModel.togglePlay()
//        
//        playingSequence.wait(timeout: 3, enforceOrder: true)
//    }
//    
//    func testTogglePlayDifferentTrack() async throws {
//        
//        let sut = createSUT()
//        
//        let trackId1 = UUID()
//        
//        let viewModel1 = createViewModel(trackId: trackId1, sut: sut)
//        setUpTestTrack(trackId: trackId1, sut: sut)
//        
//        let trackId2 = UUID()
//        
//        let viewModel2 = createViewModel(trackId: trackId2, sut: sut)
//        setUpTestTrack(trackId: trackId2, sut: sut)
//        
//        
//        let playingSequence1 = self.expectSequence([false, true, false])
//        playingSequence1.observe(viewModel1.isPlaying)
//        
//        let playingSequence2 = self.expectSequence([false, true])
//        playingSequence2.observe(viewModel2.isPlaying)
//        
//        
//        let _ = await viewModel1.load()
//        await viewModel1.togglePlay()
//        
//        let _ = await viewModel2.load()
//        await viewModel2.togglePlay()
//        
//        playingSequence1.wait(timeout: 3, enforceOrder: true)
//        playingSequence2.wait(timeout: 3, enforceOrder: true)
//    }
//
//    func testAttachSubtitlesCancel() async throws {
//        
//        let expectation = expectation(description: "Shouldn't be called")
//        expectation.isInverted = true
//        
//        let trackId = UUID()
//        let language = "English"
//        
//        let sut = createSUT()
//        let viewModel = createViewModel(trackId: trackId, sut: sut)
//    
//        sut.coordinator.resolveChooseSubtitles = { nil }
//        sut.importSubtitlesUseCase.resolveImportFile = { _, _, _, _ in
//            expectation.fulfill()
//            return .success(())
//        }
//        
//        await viewModel.attachSubtitles(language: language)
//        
//        wait(for: [expectation], timeout: 1)
//    }
//    
//    func testAttachSubtitlesResolvedWithBrokenFile() async throws {
//        
//        let trackId = UUID()
//        let language = "English"
//        
//        let showImportErrorSequence = self.expectSequence([true])
//        let sut = createSUT()
//        let viewModel = createViewModel(trackId: trackId, sut: sut)
//
//        
//        sut.coordinator.resolveChooseSubtitles = {
//            
//            let bundle = Bundle(for: type(of: self ))
//            let url = bundle.url(forResource: "test_cover_image", withExtension: "png")!
//            
//            return url
//        }
//        
//        sut.coordinator.resolveShowImportSubtitlesError = {
//            showImportErrorSequence.fulfill(with: true)
//        }
//        
//        sut.importSubtitlesUseCase.resolveImportFile = { _, _, _, _ in
//            return .failure(.wrongData)
//        }
//        
//        await viewModel.attachSubtitles(language: language)
//        showImportErrorSequence.wait(timeout: 1, enforceOrder: true)
//        
//        // TODO: How to show to the user?
//    }
//    
//    func testAttachSubtitlesResolvedWithGoodFile() async throws {
//        
//        let trackId = UUID()
//        let language = "English"
//        
//        let showImportErrorExpectation = expectation(description: "Shouldn't be called")
//        showImportErrorExpectation.isInverted = true
//        let sut = createSUT()
//        let viewModel = createViewModel(trackId: trackId, sut: sut)
//
//        sut.coordinator.resolveChooseSubtitles = {
//            
//            let bundle = Bundle(for: type(of: self ))
//            let url = bundle.url(forResource: "test_subtitles", withExtension: "lrc")!
//            
//            return url
//        }
//        
//        sut.coordinator.resolveShowImportSubtitlesError = {
//            showImportErrorExpectation.fulfill()
//        }
//
//        await viewModel.attachSubtitles(language: language)
//        
//        // TODO: How to show to the user?
//        wait(for: [showImportErrorExpectation], timeout: 1)
//    }
//}
//
// MARK: - Mocks

private final class LibraryItemCoordinatorMock: LibraryItemCoordinator {

    typealias ChooseSubtitlesCallback = () -> URL?
    typealias ShowImportSubttitlesErrorCallback = () -> Void?
    
    public var resolveChooseSubtitles: ChooseSubtitlesCallback?
    public var resolveShowImportSubtitlesError: ShowImportSubttitlesErrorCallback?
    
    public func chooseSubtitles(completion: @escaping (_ urls: URL?) -> Void) {

        guard let resolveChooseSubtitles = resolveChooseSubtitles else {
            XCTFail("No implementation")
            completion(nil)
            return
        }
        
        completion(resolveChooseSubtitles())
    }
    
    public func showImportSubtitlesError() -> Void {
        
        guard let resolveShowImportSubtitlesError = resolveShowImportSubtitlesError else {
            XCTFail("No implementation")
            return
        }
        
        resolveShowImportSubtitlesError()
    }
}

final class CurrentPlayerStateUseCaseMock: CurrentPlayerStateUseCase {
    
    var info: Observable<MediaInfo?> = Observable(nil)
    
    var state: Observable<PlayerState> = Observable(.stopped)
    
    var currentTime: Observable<Double> = Observable(0.0)
    
    var volume: Observable<Double> = Observable(0.0)
    
    private var showMediaInfoUseCase: ShowMediaInfoUseCaseMock
    
    init(showMediaInfoUseCase: ShowMediaInfoUseCaseMock) {
        self.showMediaInfoUseCase = showMediaInfoUseCase
    }
    
    public func setTrack(trackId: UUID?) async {
        
        guard let trackId = trackId else {
            info.value = nil
            return
        }
        
        let result = await showMediaInfoUseCase.fetchInfo(trackId: trackId)
        guard case .success(let data) = result else {
            return
        }
        
        info.value = data
    }
}

final class ImportSubtitlesUseCaseMock: ImportSubtitlesUseCase {
    
    typealias ImportFileCallback = (_ trackId: UUID, _ language: String, _ fileName: String, _ data: Data) -> Result<Void, ImportSubtitlesUseCaseError>
    
    public var resolveImportFile: ImportFileCallback? = nil
    
    
    func importFile(trackId: UUID, language: String, fileName: String, data: Data) async -> Result<Void, ImportSubtitlesUseCaseError> {
        
        return resolveImportFile?(trackId, language, fileName, data) ?? .success(())
    }
}
