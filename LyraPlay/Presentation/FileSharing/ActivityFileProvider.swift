//
//  ActivityFileProvider.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 19.01.23.
//

import Foundation
import UIKit

public class ActivityFileProvider: UIActivityItemProvider {
    
    // MARK: - Properties
    
    private let temporaryURL: URL
    
    private weak var viewModel: FileSharingViewModel?
    
    public override var item: Any {
        
        guard let viewModel = viewModel else {
            return ""
        }

        viewModel.putFile(at: self.temporaryURL)
        return self.temporaryURL
    }
    
    // MARK: - Initializers
    
    public init?(viewModel: FileSharingViewModel) {
        
        guard let url = viewModel.prepareFileURL() else {
            return nil
        }
        
        self.viewModel = viewModel
        self.temporaryURL = url
        
        super.init(placeholderItem: self.temporaryURL)
    }
}
