//
//  FileSharingViewModel.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 17.01.2023.
//

import Foundation

public protocol FileSharingViewModelDelegate: AnyObject {
    
}

public protocol FileSharingViewModelInput: AnyObject {

    func dispose()
}

public protocol FileSharingViewModelOutput: AnyObject {

    var url: URL { get }
}

public protocol FileSharingViewModel: FileSharingViewModelOutput, FileSharingViewModelInput {

}
