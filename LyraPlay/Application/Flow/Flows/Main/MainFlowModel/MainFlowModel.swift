//
//  MainFlowModel.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 07.09.2022.
//

import Foundation
import Combine

public typealias DeepLink = Void

public protocol MainFlowModelInput {

    func openDeepLink(link: DeepLink)
}

public protocol MainFlowModelOutput {

    var mainTabBarViewModel: MainTabBarViewModel { get }

    var libraryFlow: CurrentValueSubject<LibraryFolderFlowModel?, Never> { get }
    
    var dictionaryFlow: CurrentValueSubject<DictionaryFlowModel?, Never> { get }
}

public protocol MainFlowModel: MainFlowModelOutput, MainFlowModelInput {

}
