//
//  EditDictionaryItemViewModelImpl.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 12.09.2022.
//

import Foundation
import Combine

public final class EditDictionaryItemViewModelImpl: EditDictionaryItemViewModel {

    // MARK: - Properties

    private let params: EditDictionaryItemParams
    private let delegate: EditDictionaryItemViewModelDelegate
    private let loadDictionaryItemUseCase: LoadDictionaryItemUseCase
    private let editDictionaryItemUseCase: EditDictionaryItemUseCase
    
    public var state = CurrentValueSubject<EditDictionaryItemViewModelState, Never>(.loading)

    // MARK: - Initializers

    public init(
        params: EditDictionaryItemParams,
        delegate: EditDictionaryItemViewModelDelegate,
        loadDictionaryItemUseCase: LoadDictionaryItemUseCase,
        editDictionaryItemUseCase: EditDictionaryItemUseCase
    ) {

        self.params = params
        self.delegate = delegate
        self.loadDictionaryItemUseCase = loadDictionaryItemUseCase
        self.editDictionaryItemUseCase = editDictionaryItemUseCase
        
        initPresentationData()
    }
    
    private func initPresentationData() {
        
        switch params {
        case .existingItem(let itemId):
            Task {
                await self.initPresentationData(itemId: itemId)
            }
            
        case .newItem(let originalText):
            initPresentationData(originalText: originalText)
        }
    }
    
    private func initPresentationData(originalText: String) {
        
        state.value = .editing(
            data: .init(
                title: "Add a new word",
                originalText: originalText,
                translation: "",
                originalTextLanguage: "English",
                translationTextLanguage: "Russian"
            )
        )
    }
    
    private func initPresentationData(itemId: UUID) async {
        
        state.value = .loading
        
        let loadResult = await loadDictionaryItemUseCase.load(itemId: itemId)
        
        guard case .success(let item) = loadResult else {
            return
        }
        
        state.value = .editing(
            data: .init(
                title: "Editing",
                originalText: item.originalText,
                translation: item.translations.first?.text ?? "",
                originalTextLanguage: "English",
                translationTextLanguage: "Russian"
            )
        )
    }
}

// MARK: - Input Methods

extension EditDictionaryItemViewModelImpl {

    public func cancel() {

        delegate.editDictionaryItemViewModelDidCancel()
    }

    public func save() {

        fatalError()
    }

    public func setOriginalText(value: String) {

        fatalError()
    }

    public func setTranslationText(value: String) {

        fatalError()
    }
}

// MARK: - Output Methods

extension EditDictionaryItemViewModelImpl {

}
