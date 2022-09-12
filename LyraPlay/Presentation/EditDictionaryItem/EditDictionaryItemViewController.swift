//
//  EditDictionaryItemViewController.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 12.09.22.
//

import Foundation
import UIKit

public final class EditDictionaryItemViewController: UIViewController, EditDictionaryItemView {
    
    // MARK: - Properties
    
    private let viewModel: EditDictionaryItemViewModel
    
    private let activityIndicator = UIActivityIndicatorView()

    private let originalTextInput = UITextField()
    private let translationTextInput = UITextField()
    
    // MARK: - Initializers
    
    public init(viewModel: EditDictionaryItemViewModel) {
        
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        setup()
    }
    
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Methods
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        setup()
    }
    
    private func setup() {
        
        setupViews()
        style()
        layout()
        bind(to: viewModel)
    }
    
    public override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        viewModel.cancel()
    }
}

// MARK: - Bind viewModel

extension EditDictionaryItemViewController {
    
    private func bind(to viewModel: EditDictionaryItemViewModel) {
        
    }
}

// MARK: - Setup Views

extension EditDictionaryItemViewController {
    
    @objc
    private func didSave() {
        
    }
    
    private func setupNavigationBar() {
        
        navigationItem.rightBarButtonItem = .init(
            title: "Save",
            style: .done,
            target: self,
            action: #selector(Self.didSave)
        )
    }
    
    private func setupViews() {
        
        setupNavigationBar()
        
        view.addSubview(activityIndicator)
        view.addSubview(originalTextInput)
        view.addSubview(translationTextInput)
    }
}

// MARK: - Layout
extension EditDictionaryItemViewController {
    
    private func layout() {
        
        Layout.apply(
            view: view,
            activityIndicator: activityIndicator
        )
    }
}

// MARK: - Styles

extension EditDictionaryItemViewController {
    
    private func style() {
        
        Styles.apply(contentView: view)
//        Styles.apply(activityIndicator: activityIndicator)
    }
}

