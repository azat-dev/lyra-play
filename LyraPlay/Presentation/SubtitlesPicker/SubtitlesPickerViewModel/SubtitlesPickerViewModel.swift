//
//  SubtitlesPickerViewModel.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 09.09.2022.
//

import Foundation

public protocol SubtitlesPickerViewModelDelegate: AnyObject {

    func subtitlesPickerDidChooseFile(url: URL)
    
    func subtitlesPickerDidCancel()
    
    func subtitlesDidFinish()
}

public protocol SubtitlesPickerViewModelInput: AnyObject {

    func chooseFile(url: URL)

    func cancel()
}

public protocol SubtitlesPickerViewModelOutput: AnyObject {

    var documentTypes: [String] { get }
    
    var delegate: SubtitlesPickerViewModelDelegate? { get set }
}

public protocol SubtitlesPickerViewModel: SubtitlesPickerViewModelOutput, SubtitlesPickerViewModelInput {}
