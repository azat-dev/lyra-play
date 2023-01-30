//
//  AttachSubtitlesFlowModelImpl.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 10.09.2022.
//

import Foundation
import Combine

public final class AttachSubtitlesFlowModelImpl: AttachSubtitlesFlowModel {
    
    // MARK: - Properties

    private let mediaId: UUID
    private let allowedDocumentTypes: [String]

    private let subtitlesPickerViewModelFactory: FilesPickerViewModelFactory
    private let attachingSubtitlesProgressViewModelFactory: AttachingSubtitlesProgressViewModelFactory

    private weak var delegate: AttachSubtitlesFlowModelDelegate?
    
    public lazy var subtitlesPickerViewModel: FilesPickerViewModel = {
        
        subtitlesPickerViewModelFactory.create(
            documentTypes: allowedDocumentTypes,
            allowsMultipleSelection: false,
            delegate: self
        )
    } ()
    
    public var progressViewModel = CurrentValueSubject<AttachingSubtitlesProgressViewModel?, Never>(nil)
    
    public var importSubtitlesUseCaseFactory: ImportSubtitlesUseCaseFactory
    
    private var attachingTask: Task<Void, Never>?

    // MARK: - Initializers

    public init(
        mediaId: UUID,
        delegate: AttachSubtitlesFlowModelDelegate,
        allowedDocumentTypes: [String],
        subtitlesPickerViewModelFactory: FilesPickerViewModelFactory,
        attachingSubtitlesProgressViewModelFactory: AttachingSubtitlesProgressViewModelFactory,
        importSubtitlesUseCaseFactory: ImportSubtitlesUseCaseFactory
    ) {

        self.mediaId = mediaId
        self.delegate = delegate
        self.allowedDocumentTypes = allowedDocumentTypes
        self.subtitlesPickerViewModelFactory = subtitlesPickerViewModelFactory
        self.attachingSubtitlesProgressViewModelFactory = attachingSubtitlesProgressViewModelFactory
        self.importSubtitlesUseCaseFactory = importSubtitlesUseCaseFactory
    }
}

// MARK: - Input Methods

extension AttachSubtitlesFlowModelImpl {

}

// MARK: - SubtitlesPickerViewModelDelegate

extension AttachSubtitlesFlowModelImpl: FilesPickerViewModelDelegate {

    public func filesPickerDidCancel() {
        
        delegate?.attachSubtitlesFlowDidCancel()
    }
    
    private func attachSubtitles(url: URL) async {
        
        let progressViewModel = attachingSubtitlesProgressViewModelFactory.create(delegate: self)
        progressViewModel.state.value = .processing
        
        self.progressViewModel.value = progressViewModel
        
        url.startAccessingSecurityScopedResource()

        guard let fileData = try? Data(contentsOf: url) else {
            return
        }

        let fileName = url.lastPathComponent
        let importSubtitlesUseCase = importSubtitlesUseCaseFactory.create()

        let importResult = await importSubtitlesUseCase.importFile(
            trackId: mediaId,
            language: "English",
            fileName: fileName,
            data: fileData
        )

        guard case .success = importResult else {

            delegate?.attachSubtitlesFlowDidFinish()
            return
        }

        progressViewModel.showSuccess(completion: {

            self.delegate?.attachSubtitlesFlowDidAttach()
        })
    }
    
    public func filesPickerDidChoose(urls: [URL]) {

        guard let url = urls.first else {
            return
        }
        
        attachingTask = Task {
            await self.attachSubtitles(url: url)
        }
    }
    
    public func filesPickerDidDispose() {
        
        delegate?.attachSubtitlesFlowDidFinish()
    }
}

// MARK: - AttachSubtitlesFlowModelDelegate

extension AttachSubtitlesFlowModelImpl: AttachingSubtitlesProgressViewModelDelegate {
    
    public func attachingSubtitlesProgressViewModelDidFinish() {
        
        progressViewModel.value = nil
    }
    
    public func attachingSubtitlesProgressViewModelDidCancel() {
        
        attachingTask?.cancel()
        progressViewModel.value = nil
    }
}
