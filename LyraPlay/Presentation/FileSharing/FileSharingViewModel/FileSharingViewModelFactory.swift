//
//  FileSharingViewModelFactory.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 18.01.2023.
//

public protocol FileSharingViewModelFactory {

    func create(delegate: FileSharingViewModelDelegate) -> FileSharingViewModel
}