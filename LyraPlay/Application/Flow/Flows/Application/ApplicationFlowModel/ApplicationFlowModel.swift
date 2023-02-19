//
//  ApplicationFlowModel.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 28.01.2023.
//

import Foundation
import Combine

public protocol ApplicationFlowModelInput: AnyObject {

    func runImportDictionaryArchiveFlow(url: URL)
}

public protocol ApplicationFlowModelOutput: AnyObject {

    var mainFlowModel: MainFlowModel { get }
    
    var importDictionaryArchiveFlowModel: CurrentValueSubject<ImportDictionaryArchiveFlowModel?, Never> { get }
}

public protocol ApplicationFlowModel: ApplicationFlowModelOutput, ApplicationFlowModelInput {

}
