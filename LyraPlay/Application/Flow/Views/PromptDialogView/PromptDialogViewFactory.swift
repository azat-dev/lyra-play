//
//  PromptDialogViewFactory.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 19.09.2022.
//

public protocol PromptDialogViewFactory {

    func create(viewModel: PromptDialogViewModel) -> PromptDialogViewController
}
