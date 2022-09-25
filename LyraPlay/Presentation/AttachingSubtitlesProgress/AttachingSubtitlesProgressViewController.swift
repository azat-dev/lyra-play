//
//  AttachingSubtitlesProgressViewController.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 10.09.22.
//


import Foundation
import UIKit

public final class AttachingSubtitlesProgressViewController: UIViewController {
    
    // MARK: - Properties
    
    private let viewModel: AttachingSubtitlesProgressViewModel
    
    private let dialogBox = UIView()
    private let activityIndicatorView = UIActivityIndicatorView()
    private let titleLabelView = UILabel()
    private let cancelButton = UIButton()
    
    // MARK: - Initializers
    
    init(viewModel: AttachingSubtitlesProgressViewModel) {
        
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        setup()
    }
    
    required init?(coder: NSCoder) {
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
}

// MARK: - Bind viewModel

extension AttachingSubtitlesProgressViewController {
    
    private func bind(to viewModel: AttachingSubtitlesProgressViewModel) {
    }
}

// MARK: - Setup Views

extension AttachingSubtitlesProgressViewController {
    
    private func setupViews() {
        
        view.addSubview(dialogBox)
        
        dialogBox.addSubview(activityIndicatorView)
        dialogBox.addSubview(titleLabelView)
        dialogBox.addSubview(cancelButton)
    }
}

// MARK: - Layout
extension AttachingSubtitlesProgressViewController {
    
    private func layout() {
        
        Layout.apply(
            view: view,
            dialogBox: dialogBox,
            titleLabel: titleLabelView,
            cancelButton: cancelButton
        )
    }
}

// MARK: - Styles

extension AttachingSubtitlesProgressViewController {
    
    private func style() {
        
        Styles.apply(contentView: view)
        Styles.apply(dialogBox: dialogBox)
        Styles.apply(titleLabel: titleLabelView)
        Styles.apply(activityIndicator: activityIndicatorView)
        Styles.apply(cancelButton: cancelButton)
    }
}

