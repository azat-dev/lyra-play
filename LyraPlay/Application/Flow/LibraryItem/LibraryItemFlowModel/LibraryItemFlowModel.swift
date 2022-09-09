//
//  LibraryItemFlowModel.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 08.09.2022.
//

import Foundation

public protocol LibraryItemFlowModelInput: AnyObject {

    func runAttachSubtitlesFlow(completion: @escaping (_ url: URL?) -> Void)
}

public protocol LibraryItemFlowModelOutput: AnyObject {

    var viewModel: LibraryItemViewModel { get }
}

public protocol LibraryItemFlowModel: LibraryItemFlowModelOutput, LibraryItemFlowModelInput {

}
