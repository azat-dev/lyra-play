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
        
        subtitlesPickerViewModelFactory.make(
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
        
        delegate?.attachSubtitlesFlowDidStart(for: mediaId)
        
        let progressViewModel = attachingSubtitlesProgressViewModelFactory.make(delegate: self)
        progressViewModel.state.value = .processing
        
        self.progressViewModel.value = progressViewModel
        
        url.startAccessingSecurityScopedResource()

        guard let fileData = try? Data(contentsOf: url) else {
            return
        }

        let fileName = url.lastPathComponent
        let importSubtitlesUseCase = importSubtitlesUseCaseFactory.make()

        let importResult = await importSubtitlesUseCase.importFile(
            trackId: mediaId,
            language: "English",
            fileName: fileName,
            data: fileData
        )

        guard case .success = importResult else {

            delegate?.attachSubtitlesFlowDidFinish(for: mediaId)
            return
        }

        progressViewModel.showSuccess(completion: { [weak self] in

            guard let self = self else {
                return
            }
            
            self.delegate?.attachSubtitlesFlowDidAttach(for: self.mediaId)
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
        
        delegate?.attachSubtitlesFlowDidFinish(for: mediaId)
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
