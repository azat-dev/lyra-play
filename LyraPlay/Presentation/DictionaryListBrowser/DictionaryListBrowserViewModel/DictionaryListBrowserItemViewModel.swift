//
//  DictionaryListBrowserItemViewModel.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 05.09.22.
//

import Foundation

public struct DictionaryListBrowserItemViewModel: Equatable, Hashable {
    
    public var id: UUID
    public var title: String
    public var description: String
    
    public init(
        id: UUID,
        title: String,
        description: String
    ) {
        
        self.id = id
        self.title = title
        self.description = description
    }
}
