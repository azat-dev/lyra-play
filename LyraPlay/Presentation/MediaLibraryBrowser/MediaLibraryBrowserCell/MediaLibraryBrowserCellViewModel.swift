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
    
    public var id: UUID
    public var title: String
    public var description: String
    public var image: UIImage

    private weak var delegate: MediaLibraryBrowserCellViewModelDelegate?
    
    public init(
        id: UUID,
        title: String,
        description: String,
        image: UIImage,
        delegate: MediaLibraryBrowserCellViewModelDelegate
    ) {
        
        self.id = id
        self.title = title
        self.description = description
        self.image = image
        self.delegate = delegate
    }
    
    public func open() {
        
        self.delegate?.mediaLibraryBrowserCellViewModelDidOpen(itemId: id)
    }
}

// MARK: - Hashable

extension MediaLibraryBrowserCellViewModel: Hashable {
    
    public static func == (lhs: MediaLibraryBrowserCellViewModel, rhs: MediaLibraryBrowserCellViewModel) -> Bool {
        return lhs.id == rhs.id
    }
    
    public func hash(into hasher: inout Hasher) {
     
        hasher.combine(id)
        hasher.combine(title)
        hasher.combine(description)
    }
}
