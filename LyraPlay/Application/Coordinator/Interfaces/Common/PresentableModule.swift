//
//  PresentableModule.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 25.08.22.
//

import Foundation

public struct PresentableModule<ViewModel, View>: Presentable where View: PresentableView {
    
    private(set) var view: View
    private(set) var model: ViewModel
    
    public init(view: View, model: ViewModel) {
        
        self.view = view
        self.model = model
    }
    
    public func toPresent() -> PresentableView {
        return view
    }
}
