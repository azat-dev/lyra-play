//
//  ChooseDialogViewModel.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 19.09.2022.
//

import Foundation

public protocol ChooseDialogViewModelDelegate: AnyObject {
    
    func chooseDialogViewModelDidChoose(itemId: String)
    
    func chooseDialogViewModelDidCancel()
    
    func chooseDialogViewModelDidDispose()
}

public protocol ChooseDialogViewModelInput: AnyObject {

    func choose(itemId: String)

    func cancel()

    func dispose()
}

public protocol ChooseDialogViewModelOutput: AnyObject {

    var items: [ChooseDialogViewModelItem] { get }
}

public protocol ChooseDialogViewModel: ChooseDialogViewModelOutput, ChooseDialogViewModelInput {}
