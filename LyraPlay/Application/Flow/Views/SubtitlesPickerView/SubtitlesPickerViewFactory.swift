//
//  SubtitlesPickerViewFactory.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 10.09.2022.
//

public protocol SubtitlesPickerViewFactory {

    func create(viewModel: FilesPickerViewModel) -> FilesPickerViewController
}
