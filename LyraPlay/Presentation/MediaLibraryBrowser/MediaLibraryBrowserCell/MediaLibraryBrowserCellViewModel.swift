//
//  MediaLibraryBrowserCellViewModel.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 27.06.22.
//

import Foundation
import UIKit

public protocol MediaLibraryBrowserCellViewModelDelegate: AnyObject {

    func mediaLibraryBrowserCellViewModelDidOpen(itemId: UUID)
}

// MARK: - Implementations

public struct MediaLibraryBrowserCellViewModel {
    
    public var isFolder: Bool
    public var id: UUID
    public var title: String
    public var description: String
    public var image: UIImage

    private weak var delegate: MediaLibraryBrowserCellViewModelDelegate?
    
    public init(
        id: UUID,
        isFolder: Bool,
        title: String,
        description: String,
        image: UIImage,
        delegate: MediaLibraryBrowserCellViewModelDelegate
    ) {
        
        self.id = id
        self.isFolder = isFolder
        self.title = title
        self.description = description
        self.image = image
        self.delegate = delegate
    }
    
    public func open() {
        
        self.delegate?.mediaLibraryBrowserCellViewModelDidOpen(itemId: id)
    }
}
