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

    private let contentGroup = UIView()
    private let navigationBar = UINavigationBar()
    
    private let originalTextGroup = UIView()
    private let originalLanguageLabel = UILabel()
    
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
    
    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        originalTextInput.becomeFirstResponder()
    }
}

// MARK: - Bind viewModel

extension EditDictionaryItemViewController {
    
    private func bind(to viewModel: EditDictionaryItemViewModel) {

        self.title = viewModel.title
    }
}

// MARK: - Setup Views

extension EditDictionaryItemViewController {
    
    @objc
    private func didSave() {
        
        viewModel.save()
    }
    
    @objc
    private func didCancel() {
        
        viewModel.cancel()
    }
    
    private func setupNavigationBar() {

        navigationItem.rightBarButtonItem = .init(
            title: "Save",
            style: .done,
            target: self,
            action: #selector(Self.didSave)
        )
        
        navigationItem.leftBarButtonItem = .init(
            title: "Cancel",
            style: .plain,
            target: self,
            action: #selector(Self.didCancel)
        )
    }
    
    @objc
    private func originalTextDidChange() {
        
        viewModel.setOriginalText(value: originalTextInput.text ?? "")
    }
    
    private func setupViews() {
        
        setupNavigationBar()
        
        originalTextInput.addTarget(self, action: #selector(Self.originalTextDidChange), for: .valueChanged)
        
        originalTextGroup.addSubview(originalLanguageLabel)
        originalTextGroup.addSubview(originalTextInput)
        
        contentGroup.addSubview(originalTextGroup)
        contentGroup.addSubview(translationTextInput)
        
        view.addSubview(activityIndicator)
        view.addSubview(contentGroup)
    }
}

// MARK: - Layout
extension EditDictionaryItemViewController {
    
    private func layout() {
        
        Layout.apply(
            view: view,
            activityIndicator: activityIndicator,
            contentGroup: contentGroup,
            originalTextGroup: originalTextGroup,
            originalLanguageLabel: originalLanguageLabel,
            originalTextInput: originalTextInput,
            translationTextInput: translationTextInput
        )
    }
}

// MARK: - Styles

extension EditDictionaryItemViewController {
    
    private func style() {
        
        Styles.apply(contentView: view)
        Styles.apply(originalTextGroup: originalTextGroup)
        Styles.apply(languageLabel: originalLanguageLabel)
        Styles.apply(originalTextInput: originalTextInput)
    }
}

