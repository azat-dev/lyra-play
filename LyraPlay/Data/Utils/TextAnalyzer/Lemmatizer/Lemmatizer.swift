//
//  Lemmatizer.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 22.07.22.
//

import Foundation

public protocol Lemmatizer {
    
    func lemmatize(text: String) -> [LemmaItem]
}
