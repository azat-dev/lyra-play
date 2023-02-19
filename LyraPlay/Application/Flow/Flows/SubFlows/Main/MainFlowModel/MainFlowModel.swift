//
//  MainFlowModel.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 07.09.2022.
//

import Foundation
import Combine

public protocol MainFlowModelOutput: AnyObject {

    var mainTabBarViewModel: MainTabBarViewModel { get }

    var libraryFlow: CurrentValueSubject<LibraryFolderFlowModel?, Never> { get }
    
    var dictionaryFlow: CurrentValueSubject<DictionaryFlowModel?, Never> { get }
    
    var currentPlayerStateDetailsFlow: CurrentValueSubject<CurrentPlayerStateDetailsFlowModel?, Never> { get }
}

public protocol MainFlowModelInput: AnyObject {
    
    func runDictionaryFlow()
}

public protocol MainFlowModel: MainFlowModelOutput, MainFlowModelInput {

}
