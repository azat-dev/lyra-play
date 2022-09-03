//
//  MainTabBarView.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 03.09.2022.
//

public protocol MainTabBarView: PresentableView {

    var libraryContainer: StackPresentationContainer { get }

    var dictionaryContainer: StackPresentationContainer { get }
}