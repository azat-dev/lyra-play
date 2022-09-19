//
//  FilesPickerViewModel.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 09.09.2022.
//

import Foundation

public protocol FilesPickerViewModelDelegate: AnyObject {

    func filesPickerDidChoose(urls: [URL])
    
    func filesPickerDidCancel()
    
    func filesPickerDidDispose()
}

public protocol FilesPickerViewModelInput: AnyObject {

    func choose(urls: [URL])

    func cancel()
    
    func dispose()
}

public protocol FilesPickerViewModelOutput: AnyObject {

    var documentTypes: [String] { get }
    
    var allowsMultipleSelection: Bool { get }
    
    var delegate: FilesPickerViewModelDelegate? { get set }
}

public protocol FilesPickerViewModel: FilesPickerViewModelOutput, FilesPickerViewModelInput {}
