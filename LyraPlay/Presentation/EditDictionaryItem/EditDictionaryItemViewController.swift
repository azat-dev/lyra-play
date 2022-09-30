//
//  EditDictionaryItemViewController.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 12.09.22.
//

import Foundation
import Combine
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

    private let translationTextGroup = UIView()
    private let translationLanguageLabel = UILabel()
    private let translationTextInput = UITextField()
    
    private var observers = Set<AnyCancellable>()
    
    // MARK: - Initializers
    
    public init(viewModel: EditDictionaryItemViewModel) {
        
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
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
    
    deinit {
        observers.removeAll()
    }
}

// MARK: - Bind viewModel

extension EditDictionaryItemViewController {
    
    private func updateState(state: EditDictionaryItemViewModelState) {
        
        switch state {
            
        case .loading:
            activityIndicator.startAnimating()
            contentGroup.isHidden = true
            
        case .saving:
            activityIndicator.startAnimating()
            
        case .saved:
            activityIndicator.stopAnimating()
            
        case .editing(let data):
            
            contentGroup.isHidden = false
            activityIndicator.stopAnimating()
            
            originalTextInput.text = data.originalText
            translationTextInput.text = data.translation
        }
    }
    
    private func bind(to viewModel: EditDictionaryItemViewModel) {

        self.title = viewModel.title
        
        viewModel.state
            .receive(on: RunLoop.main)
            .sink { [weak self] in self?.updateState(state: $0) }
            .store(in: &observers)
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
    
    @objc
    private func translationTextDidChange() {
        
        viewModel.setTranslationText(value: translationTextInput.text ?? "")
    }
    
    private func setupViews() {
        
        setupNavigationBar()
        
        activityIndicator.hidesWhenStopped = true
        
        originalTextInput.addTarget(
            self,
            action: #selector(Self.originalTextDidChange),
            for: .editingChanged
        )
        
        originalTextGroup.addSubview(originalLanguageLabel)
        originalTextGroup.addSubview(originalTextInput)
        
        translationTextInput.addTarget(
            self,
            action: #selector(Self.translationTextDidChange),
            for: .editingChanged
        )
        
        translationTextGroup.addSubview(translationLanguageLabel)
        translationTextGroup.addSubview(translationTextInput)
        
        contentGroup.addSubview(originalTextGroup)
        contentGroup.addSubview(translationTextGroup)
        
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
            translationTextGroup: translationTextGroup,
            translationLanguageLabel: translationLanguageLabel,
            translationTextInput: translationTextInput
        )
    }
}

// MARK: - Styles

extension EditDictionaryItemViewController {
    
    private func style() {
        
        Styles.apply(contentView: view)
        
        Styles.apply(textGroup: originalTextGroup)
        Styles.apply(originalLanguageLabel: originalLanguageLabel)
        Styles.apply(originalTextInput: originalTextInput)
        
        Styles.apply(textGroup: translationTextGroup)
        Styles.apply(translationLanguageLabel: translationLanguageLabel)
        Styles.apply(translationTextInput: translationTextInput)
    }
}
