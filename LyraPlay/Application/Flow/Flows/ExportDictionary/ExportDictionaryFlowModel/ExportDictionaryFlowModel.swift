//
//  ExportDictionaryFlowModel.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 19.01.2023.
//

import Foundation
import Combine

public protocol ExportDictionaryFlowModelInput: AnyObject {

}

public protocol ExportDictionaryFlowModelOutput: AnyObject {

    var fileSharingViewModel: CurrentValueSubject<FileSharingViewModel?, Never> { get }
}

public protocol ExportDictionaryFlowModel: ExportDictionaryFlowModelOutput, ExportDictionaryFlowModelInput {

}