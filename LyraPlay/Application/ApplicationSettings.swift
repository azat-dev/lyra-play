//
//  ApplicationSettings.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 22.01.23.
//

import Foundation

public struct ApplicationSettings {
    
    let dbFileName: String
    let imagesFolderName: String
    let audioFilesFolderName: String
    let subtitlesFolderName: String
    let supportedSubtitlesExtensions: [String]
    let coverPlaceholderName: String
    let allowedSubtitlesDocumentTypes: [String]
    let allowedMediaDocumentTypes: [String]
    let defaultDictionaryArchiveName: String
    let dictionaryArchiveExtension: String
    let mediaFilesExtensions: [String]
}
