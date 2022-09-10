//
//  PresentableViewFactory.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 03.09.22.
//

import Foundation

public protocol PresentableViewFactory {

    associatedtype View: PresentableView
    
    associatedtype ViewModel
    
    func create(viewModel: ViewModel) -> View
}
