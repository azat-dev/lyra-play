//
//  ImportMediaFilesFlowModel.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 10.09.2022.
//

import Foundation
import Combine

public protocol ImportMediaFilesFlowModelDelegate: AnyObject {
    
    func importMediaFilesFlowDidFinish()
    
    func importMediaFilesFlowProgress(totalFilesCount: Int, importedFilesCount: Int)
}

public protocol ImportMediaFilesFlowModelInput: AnyObject {}

public protocol ImportMediaFilesFlowModelOutput: AnyObject {

    var filesPickerViewModel: CurrentValueSubject<FilesPickerViewModel?, Never> { get }
}

public protocol ImportMediaFilesFlowModel: ImportMediaFilesFlowModelOutput, ImportMediaFilesFlowModelInput {}
