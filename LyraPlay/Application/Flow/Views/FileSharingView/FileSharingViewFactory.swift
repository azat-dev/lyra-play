//
//  FileSharingViewFactory.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 17.01.2023.
//

public protocol FileSharingViewFactory {

    func create(viewModel: FileSharingViewModel) -> FileSharingViewController
}
