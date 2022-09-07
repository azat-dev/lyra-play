//
//  LibraryFlowModel.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 07.09.2022.
//

import Foundation

public protocol LibraryFlowModelInput: AnyObject {

}

public protocol LibraryFlowModelOutput: AnyObject {

    var listViewModel: AudioFilesBrowserViewModel { get }
}

public protocol LibraryFlowModel: LibraryFlowModelOutput, LibraryFlowModelInput {}
