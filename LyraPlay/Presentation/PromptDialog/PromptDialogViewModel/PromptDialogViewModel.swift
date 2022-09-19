//
//  PromptDialogViewModel.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 19.09.2022.
//

import Foundation
import Combine

public protocol PromptDialogViewModelDelegate: AnyObject {
    
    func promptDialogViewModelDidCancel()
    
    func promptDialogViewModelDidDispose()
    
    func promptDialogViewModelDidSubmit(value: String)
}

public protocol PromptDialogViewModelInput: AnyObject {

    func cancel()

    func dispose()

    func submit(value: String)

    func setErrorText(_ text: String?)
}

public protocol PromptDialogViewModelOutput: AnyObject {

    var messageText: String { get }

    var submitText: String { get }

    var cancelText: String { get }

    var errorText: CurrentValueSubject<String?, Never> { get }
}

public protocol PromptDialogViewModel: PromptDialogViewModelOutput, PromptDialogViewModelInput {}
