//
//  MainTabBarView.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 03.09.2022.
//

import UIKit

public protocol MainTabBarView: PresentableView {

    var libraryContainer: UINavigationController { get }

    var dictionaryContainer: UINavigationController { get }
}
