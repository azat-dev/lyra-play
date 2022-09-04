//
//  PresentableView.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 03.09.22.
//

import Foundation

public protocol PresentableView {}

public protocol PresentableViewForModel: PresentableView {
    
    associatedtype ViewModel
    
    init(viewModel: ViewModel)
}
