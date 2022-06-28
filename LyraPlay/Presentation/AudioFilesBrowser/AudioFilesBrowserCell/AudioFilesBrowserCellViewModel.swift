//
//  AudioFilesBrowserCellViewModel.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 27.06.22.
//

import Foundation
import UIKit


// MARK: - Implementations

public struct AudioFilesBrowserCellViewModel: Hashable {
    
    public var id: UUID
    public var title: String
    public var description: String
    public var image: UIImage
    
    private var onOpen: (_ id: UUID) -> Void
    
    public init(
        id: UUID,
        title: String,
        description: String,
        image: UIImage,
        onOpen: @escaping (_ id: UUID) -> Void
    ) {
        
        self.id = id
        self.title = title
        self.description = description
        self.onOpen = onOpen
        self.image = image
    }
    
    public func open() {
        self.onOpen(id)
    }
    
    public static func == (lhs: AudioFilesBrowserCellViewModel, rhs: AudioFilesBrowserCellViewModel) -> Bool {
        return lhs.id == rhs.id
    }
    
    public func hash(into hasher: inout Hasher) {
     
        hasher.combine(id)
        hasher.combine(title)
        hasher.combine(description)
    }
}
