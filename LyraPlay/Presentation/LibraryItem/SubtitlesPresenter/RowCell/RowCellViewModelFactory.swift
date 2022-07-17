//
//  RowCellViewModelFactory.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 17.07.22.
//

import Foundation

final class RowCellViewModelFactory {
    
    func create(
        id: RowId,
        isActive: Bool,
        text: String,
        toggleWord: @escaping ToggleWordCallback,
        activeRange: Range<String.Index>? = nil
    ) -> RowCellViewModel {
        
        return DefaultRowCellViewModel(
            id: id,
            isActive: isActive,
            text: text,
            toggleWord: toggleWord,
            activeRange: activeRange
        )
    }
}
