//
//  PromptDialogViewController.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 20.09.22.
//

import Foundation
import Combine
import UIKit

public final class PromptDialogViewController: UIViewController, PromptDialogView {
    
    // MARK: - Properties
    
    private var viewModel: ViewModel!
    
    private var container = UIView()
    private var dialogView = UIView()
    private let messageLabel = UILabel()
    private let errorLabel = UILabel()
    
    private let textFieldGroup = UIStackView()
    private let textField = UITextField()
    private let buttonsGroup = UIStackView()
    private let cancelButton = UIButton()
    private let submitButton = UIButton()
    private let horizontalSeparator = UIView()
    private let verticalSeparator = UIView()
    private let activityIndicator = UIActivityIndicatorView()
    private var adjustKeyboarView = UIView()
    
    private var observers = Set<AnyCancellable>()
    
    private var keyboardOffsetConstraint: NSLayoutConstraint?

    // MARK: - Initializers
    
    init(viewModel: ViewModel) {
        
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Methods
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        setup()
    }
    
    public override func viewDidDisappear(_ animated: Bool) {

        super.viewDidDisappear(animated)
        viewModel.dispose()
    }
    
    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        textField.becomeFirstResponder()
    }
    
    private func setup() {
        
        setupViews()
        style()
        layout()
        bind(to: viewModel)
    }
}

// MARK: - Bind viewModel

extension PromptDialogViewController {
    
    private func bind(to viewModel: PromptDialogViewModel) {
        
        messageLabel.text = viewModel.messageText
        cancelButton.setTitle(viewModel.cancelText, for: .normal)
        submitButton.setTitle(viewModel.submitText, for: .normal)
        
        viewModel.isProcessing
            .receive(on: RunLoop.main)
            .sink { [weak self] isProcessing in
                
                guard let self = self else {
                    return
                }
                
                if isProcessing {
                    
                    self.dialogView.isUserInteractionEnabled = false
                    self.activityIndicator.startAnimating()
                    Styles.apply(submitButtonProcessing: self.submitButton)
                    
                } else {
                    
                    self.dialogView.isUserInteractionEnabled = true
                    self.activityIndicator.stopAnimating()
                    Styles.apply(submitButton: self.submitButton)
                }
                
            }.store(in: &observers)
        
        viewModel.errorText
            .receive(on: RunLoop.main)
            .sink { [weak self] errorText in
                
                guard let self = self else {
                    return
                }
                
                guard let errorText = errorText else {
                    
                    self.errorLabel.isHidden = true
                    return
                }

                self.errorLabel.isHidden = false
                self.errorLabel.text = errorText
                self.textField.shake(maxAmplitude: 5, duration: 0.6)
            }.store(in: &observers)
    }
}

// MARK: - Setup Views

extension PromptDialogViewController {
    
    @objc
    func didTapCancel() {
        
        viewModel.cancel()
    }
    
    @objc
    func didTapSubmit() {
        
//        textField.becomeFirstResponder()
        viewModel.submit(value: textField.text ?? "")
    }
    
    private func setupViews() {
        
        dialogView.addSubview(messageLabel)
        
        textFieldGroup.addArrangedSubview(textField)
        textFieldGroup.addArrangedSubview(errorLabel)
        
        dialogView.addSubview(textFieldGroup)

        cancelButton.addTarget(
            self,
            action: #selector(didTapCancel),
            for: .touchUpInside
        )
        
        submitButton.addTarget(
            self,
            action: #selector(didTapSubmit),
            for: .touchUpInside
        )
        
        submitButton.addSubview(activityIndicator)
        
        buttonsGroup.addArrangedSubview(cancelButton)
        buttonsGroup.addArrangedSubview(submitButton)
        buttonsGroup.addSubview(horizontalSeparator)
        buttonsGroup.addSubview(verticalSeparator)

        dialogView.addSubview(buttonsGroup)
        
        container.addSubview(dialogView)

        view.addSubview(container)
        view.addSubview(adjustKeyboarView)
        initKeyboardEventsObserver()
    }
}

// MARK: - Layout
extension PromptDialogViewController {
    
    private func layout() {

        Layout.applyButtonWithActivityIndicator(
            submitButton: submitButton,
            activityIndicator: activityIndicator
        )
        
        Layout.applyTextFieldGroupContent(
            textFieldGroup: textFieldGroup,
            textField: textField,
            errorTextLabel: errorLabel
        )

        Layout.applyButtonsGroupContent(
            buttonsGroup: buttonsGroup,
            horizontalSeparator: horizontalSeparator,
            verticalSeparator: verticalSeparator,
            cancelButton: cancelButton,
            submitButton: submitButton
        )

        Layout.applyDialogViewContent(
            dialogView: dialogView,
            messageLabel: messageLabel,
            textFieldGroup: textFieldGroup,
            buttonsGroup: buttonsGroup
        )
        
        Layout.applyDialogViewPosition(
            container: container,
            dialogView: dialogView
        )
        
        Layout.applyContentViewContent(
            contentView: view,
            container: container,
            dialogView: dialogView,
            adjustKeyboarView: adjustKeyboarView
        )
        
        keyboardOffsetConstraint = Layout.applyAdjustKeyboardOffset(
            container: container,
            adjustKeyboarView: adjustKeyboarView
        )
    }
}

// MARK: - Styles

extension PromptDialogViewController {
    
    private func style() {
        
        Styles.apply(contentView: view)
        Styles.apply(dialogView: dialogView)
        Styles.apply(messageLabel: messageLabel)
        Styles.apply(textField: textField)
        Styles.apply(errorLabel: errorLabel)
        Styles.apply(separator: horizontalSeparator)
        Styles.apply(separator: verticalSeparator)
        Styles.apply(cancelButton: cancelButton)
        Styles.apply(submitButton: submitButton)
        Styles.apply(activityIndicator: activityIndicator)
    }
}

// MARK: - Keyboard Management
extension PromptDialogViewController {
    
    private func initKeyboardEventsObserver() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShow),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )
        
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillHide),
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )
    }
    
    private func applyKeyboardOffset(offset: CGFloat) {
        
        keyboardOffsetConstraint?.constant = max(offset - 150, 0)
        
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseInOut) {
            
            self.view.layoutIfNeeded()
        }
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        guard let keyboardSize = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else {
            return
        }

        applyKeyboardOffset(offset: keyboardSize.cgRectValue.height)
    }
    
    @objc func keyboardWillHide() {
        
        if textField.isEditing {
            return
        }
        
        applyKeyboardOffset(offset: 0)
    }
}
