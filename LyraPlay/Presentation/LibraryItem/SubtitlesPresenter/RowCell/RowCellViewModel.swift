//
//  RowCellViewModel.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 13.07.22.
//

import Foundation

public typealias RowId = Int

public typealias ToggleWordCallback = (_ rowId: RowId, _ range: Range<String.Index>) -> Void

// MARK: - Interfaces

public protocol RowCellViewModel {
    
    var id: RowId { get }
    
    var isActive: Bool { get }
    
    var text: String { get }
    
    var toggleWord: ToggleWordCallback { get }
    
    var activeRange: Range<String.Index>? { get }
}

// MARK: - Implementations

public struct DefaultRowCellViewModel: RowCellViewModel {
    
    public var id: RowId
    
    public var isActive: Bool
    
    public var text: String
    
    public var toggleWord: (_ rowId: RowId, _ range: Range<String.Index>) -> Void
    
    public var activeRange: Range<String.Index>?
}
