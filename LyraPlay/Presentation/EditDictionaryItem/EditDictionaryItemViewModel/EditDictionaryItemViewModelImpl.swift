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
    
    private func updateExistingItem(itemId: UUID, newData: EditDictionaryItemPresentationData) async {
        
        let loadResult = await loadDictionaryItemUseCase.load(itemId: itemId)
        
        guard case .success(let existingItem) = loadResult else {
            return
        }
        
        var updatedItem = existingItem
        updatedItem.originalText = newData.originalText
        
        if let existingTranslation = updatedItem.translations.first {
            
            var updatedTranslation = existingTranslation
            updatedTranslation.text = newData.translation
            
            updatedItem.translations[0] = updatedTranslation
        }
        
        let saveResult = await editDictionaryItemUseCase.putItem(item: updatedItem)
        
        guard case .success = saveResult else {
            // TODO: Handle error
            return
        }
        
        delegate.editDictionaryItemViewModelDidUpdate()
        state.value = .saved
    }
    
    private func createNewItem(newData: EditDictionaryItemPresentationData) async {
        
        let updatedItem = DictionaryItem(
            id: nil,
            createdAt: nil,
            updatedAt: nil,
            originalText: newData.originalText,
            lemma: "",
            language: "English",
            translations: [
                .init(id: UUID(), text: newData.translation)
            ]
        )

        let saveResult = await editDictionaryItemUseCase.putItem(item: updatedItem)
        
        guard case .success = saveResult else {
            // TODO: Handle error
            return
        }
        
        delegate.editDictionaryItemViewModelDidUpdate()
        state.value = .saved
        
    }
    
    private func savePresentationData() async {
        
        guard case .editing(let data) = state.value else {
            return
        }
        
        state.value = .saving(data: data)
        switch params {
            
        case .existingItem(let itemId):
            await updateExistingItem(itemId: itemId, newData: data)
            
        case .newItem:
            await createNewItem(newData: data)
        }
    }

    public func save() {

        Task {
            await savePresentationData()
        }
    }
    
    private func updateData(_ update: (_ prevData: EditDictionaryItemPresentationData) -> EditDictionaryItemPresentationData) {
        
        guard case .editing(let data) = state.value else {
            return
        }
        
        state.value = .editing(data: update(data))
    }

    public func setOriginalText(value: String) {

        updateData { prevData in
            
            var newData = prevData
            newData.originalText = value
            
            return newData
        }
    }

    public func setTranslationText(value: String) {
        
        updateData { prevData in
            
            var newData = prevData
            newData.translation = value
            
            return newData
        }
    }
}
