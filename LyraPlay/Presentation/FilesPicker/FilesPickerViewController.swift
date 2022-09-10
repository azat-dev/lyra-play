//
//  FilesPickerViewController.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 09.09.22.
//

import Foundation
import UIKit
import UniformTypeIdentifiers

public final class FilesPickerViewController: UIDocumentPickerViewController {

    // MARK: - Properties
    
    private let viewModel: FilesPickerViewModel
    
    // MARK: - Initializers
    
    public init(viewModel: FilesPickerViewModel) {
        
        self.viewModel = viewModel
        if #available(iOS 14.0, *) {
            
            let supportedTypes: [UTType] = viewModel.documentTypes.map { UTType(importedAs: $0) }
            super.init(forOpeningContentTypes: supportedTypes, asCopy: true)
        } else {
            super.init(documentTypes: viewModel.documentTypes, in: .import)
        }

        allowsMultipleSelection = viewModel.allowsMultipleSelection
        self.delegate = self
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - UIDocumentPickerDelegate

extension FilesPickerViewController: UIDocumentPickerDelegate {
    
    public func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
        
        viewModel.cancel()
    }
    
    public func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {

        viewModel.choose(urls: urls)
    }
    
    public func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentAt url: URL) {
        
        viewModel.choose(urls: [url])
    }
}
