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
        super.init(activityItems: [viewModel.url], applicationActivities: [])
    }
}
