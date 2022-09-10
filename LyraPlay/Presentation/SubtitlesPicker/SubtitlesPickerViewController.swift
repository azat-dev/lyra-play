//
//  SubtitlesPickerViewController.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 09.09.22.
//

import Foundation
import UIKit
import UniformTypeIdentifiers

public final class SubtitlesPickerViewController: UIDocumentPickerViewController {

    // MARK: - Properties
    
    private let viewModel: SubtitlesPickerViewModel
    
    // MARK: - Initializers
    
    public init(viewModel: SubtitlesPickerViewModel) {
        
        self.viewModel = viewModel
        if #available(iOS 14.0, *) {
            
            let supportedTypes: [UTType] = viewModel.documentTypes.map { UTType(importedAs: $0) }
            super.init(forOpeningContentTypes: supportedTypes, asCopy: true)
        } else {
            super.init(documentTypes: viewModel.documentTypes, in: .import)
        }

        allowsMultipleSelection = false
        self.delegate = self
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - UIDocumentPickerDelegate

extension SubtitlesPickerViewController: UIDocumentPickerDelegate {
    
    public func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
        
        viewModel.cancel()
    }
    
    public func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        
        guard let url = urls.first else {
            return
        }
        
        viewModel.chooseFile(url: url)
    }
    
    public func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentAt url: URL) {
        
        viewModel.chooseFile(url: url)
    }
}
