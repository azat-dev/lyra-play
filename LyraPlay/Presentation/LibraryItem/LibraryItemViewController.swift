//
//  LibraryItemViewController.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 03.07.22.
//

import Foundation
import UIKit

public final class LibraryItemViewController: UIViewController {
    
    private let viewModel: LibraryItemViewModel
    
    private var activityIndicator = UIActivityIndicatorView()
    private var imageView = UIImageView()
    private var titleLabel = UILabel()
    private var artistLabel = UILabel()
    private var durationLabel = UILabel()
    
    private var mainGroup = UIStackView()
    
    init(viewModel: LibraryItemViewModel) {
        
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViews()
        style()
        layout()
        bind(to: viewModel)
        
        Task {
            await viewModel.load()
        }
    }
}

// MARK: - Bind viewModel

extension LibraryItemViewController {
    
    private func updateLoading(_ isLoading: Bool) {
        
        if isLoading {
            
            if !activityIndicator.isAnimating {
                activityIndicator.startAnimating()
            }
        } else {
            activityIndicator.stopAnimating()
        }
        
        mainGroup.isHidden = isLoading
        activityIndicator.isHidden = !isLoading
    }

    private func bind(to viewModel: LibraryItemViewModel) {
        
        viewModel.info.observe(on: self) { [weak self] mediaInfo in
            
            guard let self = self else {
                return
            }

            guard let mediaInfo = mediaInfo else {
                self.updateLoading(true)
                return
            }

            self.imageView.image = UIImage(data: mediaInfo.coverImage)!
            self.titleLabel.text = mediaInfo.title
            self.artistLabel.text = mediaInfo.artist
            self.durationLabel.text = mediaInfo.duration
            
            self.updateLoading(false)
        }
    }
}

// MARK: - Setup Views

extension LibraryItemViewController {
    
    private func setupViews() {
        
        mainGroup.axis = .vertical
        
        mainGroup.addArrangedSubview(imageView)
        mainGroup.addArrangedSubview(titleLabel)
        mainGroup.addArrangedSubview(artistLabel)
        mainGroup.addArrangedSubview(durationLabel)
        
        view.addSubview(activityIndicator)
        view.addSubview(mainGroup)
    }
}

// MARK: - Layout
extension LibraryItemViewController {
    
    private func layout() {
        
        Layout.apply(
            view: view,
            activityIndicator: activityIndicator,
            mainGroup: mainGroup,
            imageView: imageView,
            titleLabel: titleLabel,
            artistLabel: artistLabel
        )
    }
}

// MARK: - Styles

extension LibraryItemViewController {
    
    private func style() {
        
        Styles.apply(contentView: view)
        Styles.apply(imageView: imageView)
        Styles.apply(titleLabel: titleLabel)
        Styles.apply(artistLabel: artistLabel)
    }
}

