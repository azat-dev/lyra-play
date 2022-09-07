//
//  AudioFilesBrowserViewModel.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 01.09.2022.
//

import Foundation

public protocol AudioFilesBrowserViewModelDelegate {
    
    func runImportMediaFilesFlow(completion: @escaping (_ urls: [URL]?) -> Void)
    
    func runOpenLibraryItemFlow(mediaId: UUID)
}

public protocol AudioFilesBrowserUpdateDelegate: AnyObject {
    
    func filesDidUpdate(updatedFiles: [AudioFilesBrowserCellViewModel])
}

public protocol AudioFilesBrowserViewModelInput {
    
    func load() async -> Void
    
    func addNewItem() -> Void
}

public protocol AudioFilesBrowserViewModelOutput {
    
    var isLoading: Observable<Bool> { get }
    
    var filesDelegate: AudioFilesBrowserUpdateDelegate? { get set }
}

public protocol AudioFilesBrowserViewModel: AudioFilesBrowserViewModelOutput, AudioFilesBrowserViewModelInput {}
