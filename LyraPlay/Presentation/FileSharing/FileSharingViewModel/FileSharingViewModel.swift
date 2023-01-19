//
//  FileSharingViewModel.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 18.01.2023.
//

import Foundation

public protocol FileSharingViewModelDelegate: AnyObject {
 
    func fileSharingViewModelDidDispose()
}

public protocol FileSharingViewModelInput: AnyObject {

    func dispose()
}

public protocol FileSharingViewModelOutput: AnyObject {

    func putFile(at: URL)
    
    func prepareFileURL() -> URL?
}

public protocol FileSharingViewModel: FileSharingViewModelOutput, FileSharingViewModelInput {}
