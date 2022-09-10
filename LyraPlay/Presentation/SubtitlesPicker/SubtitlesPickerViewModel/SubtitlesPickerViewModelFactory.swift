//
//  SubtitlesPickerViewModelFactory.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 09.09.2022.
//

public protocol SubtitlesPickerViewModelFactory {

    func create(
        documentTypes: [String],
        delegate: SubtitlesPickerViewModelDelegate
    ) -> SubtitlesPickerViewModel
}