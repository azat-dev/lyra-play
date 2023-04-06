//
//  EditDictionaryItemViewModel.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 12.09.2022.
//

import Foundation
import Combine

public protocol EditDictionaryItemViewModelDelegate: AnyObject {
    
    func editDictionaryItemViewModelDidCancel()
    
    func editDictionaryItemViewModelDidUpdate()
    
    func editDictionaryItemViewModelDidFinish()
}

public enum EditDictionaryItemParams: Equatable {

    case existingItem(itemId: UUID)
    case newItem(originalText: String)
}

public enum EditDictionaryItemViewModelState {

    case loading
    case editing(data: EditDictionaryItemPresentationData)
    case saving(data: EditDictionaryItemPresentationData)
    case saved
}

public protocol EditDictionaryItemViewModelInput: AnyObject {

    func cancel()

    func save()

    func setOriginalText(value: String)

    func setTranslationText(value: String)
}

public protocol EditDictionaryItemViewModelOutput: AnyObject {

    var title: String { get }
    
    var state: CurrentValueSubject<EditDictionaryItemViewModelState, Never> { get }
}

public protocol EditDictionaryItemViewModel: EditDictionaryItemViewModelOutput, EditDictionaryItemViewModelInput {

}
