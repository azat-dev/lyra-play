//
//  ChooseDialogViewModelItem.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 19.09.2022.
//

import Foundation

public struct ChooseDialogViewModelItem {

    // MARK: - Properties

    public var id: String
    public var title: String

    // MARK: - Initializers

    public init(
        id: String,
        title: String
    ) {

        self.id = id
        self.title = title
    }
}