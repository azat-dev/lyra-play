//
//  FileSharingViewController.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 17.01.23.
//

import Foundation
import UIKit


public class FileSharingViewController: UIActivityViewController, FileSharingView {
    
    public required init(viewModel: FileSharingViewModel) {
        
        let provider = FileProvider(fileName: "test.json")
        super.init(activityItems: [provider], applicationActivities: [])
    }
}

extension FileSharingViewController {
    
    class FileProvider: UIActivityItemProvider {
        
        // MARK: - Properties
        
        private let temporaryURL: URL
        
        override var item: Any {
            
            return self.temporaryURL
        }
        
        // MARK: - Initializers
        
        init(fileName: String) {
            
            self.temporaryURL = URL(fileURLWithPath: NSTemporaryDirectory() + "\(fileName)")
            super.init(placeholderItem: self.temporaryURL)
        }
        
    }
}
