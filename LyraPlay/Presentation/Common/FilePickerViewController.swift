//
//  FilePickerViewController.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 27.06.22.
//

import Foundation
import UIKit
import UniformTypeIdentifiers

public class FilePickerViewController: UIDocumentPickerViewController, UIDocumentPickerDelegate {

    public typealias CancelCallback = () -> Void
    public typealias SelectCallback = (_ urls: [URL]) -> Void
    
    private var onCancel: CancelCallback!
    private var onSelect: SelectCallback!
    
    static func create(
        allowMultipleSelection: Bool,
        documentTypes: [String],
        onSelect: @escaping SelectCallback,
        onCancel: @escaping CancelCallback
    ) -> FilePickerViewController {
        
        let vc: FilePickerViewController
        
        if #available(iOS 14.0, *) {
            
            let supportedTypes: [UTType] = documentTypes.map { UTType(importedAs: $0) }
            vc = FilePickerViewController(forOpeningContentTypes: supportedTypes)
        } else {
            
            vc = FilePickerViewController(documentTypes: documentTypes, in: .import)
        }
        
        vc.onCancel = onCancel
        vc.onSelect = onSelect
        
        vc.delegate = vc
        vc.allowsMultipleSelection = allowMultipleSelection
        return vc
        
    }
    
    public func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
        self.onCancel()
    }
    
    public func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        self.onSelect(urls)
    }
    
    public func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentAt url: URL) {
        self.onSelect([url])
    }
}
