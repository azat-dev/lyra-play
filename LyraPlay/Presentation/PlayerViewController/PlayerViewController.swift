//
//  PlayerViewController.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 30.06.22.
//

import Foundation
import UIKit
import AVFoundation

public final class PlayerViewController: UIViewController {
    
    private let viewModel: PlayerViewModel
    
    private let playButton = UIButton()
    private let volumeSlider = UISlider()
    private let titleLabel = UILabel()
    private let descriptionLabel = UILabel()
    private let imageView = UIImageView()
    private let activityIndicator = UIActivityIndicatorView()
    
    private let playbackGroup = UIStackView()
    private let mainGroup = UIStackView()
    
    init(viewModel: PlayerViewModel) {
        
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setup() {
        
        setupViews()
        style()
        layout()
        bind(to: viewModel)
    }
}

// MARK: - Bind viewModel

extension PlayerViewController {

    private func updateLoading(_ isLoading: Bool) {

        guard isLoading else {
        
            activityIndicator.isHidden = false
            mainGroup.isHidden = true
            return
        }
        
        activityIndicator.isHidden = false
        mainGroup.isHidden = true
    }
    
    private func bind(to viewModel: PlayerViewModel) {
        
        viewModel.trackInfo.observe(on: self) { [weak self] trackInfo in
            
            guard let self = self else {
                return
            }
            
            guard let trackInfo = trackInfo else {
                
                self.updateLoading(true)
                return
            }

            self.titleLabel.text = trackInfo.title
            self.descriptionLabel.text = trackInfo.description
            self.imageView.image = trackInfo.image
            self.updateLoading(false)
        }
    }
}

// MARK: - Setup Views

extension PlayerViewController {
    
    private func setupViews() {
        
        view.addSubview(activityIndicator)
        
        playbackGroup.addArrangedSubview(playButton)
        
        mainGroup.addSubview(imageView)
        mainGroup.addSubview(playbackGroup)
        view.addSubview(mainGroup)
    }
}

// MARK: - Layout
extension PlayerViewController {
    
    private func layout() {
        
        Layout.apply(
            view: view,
            activityIndicator: activityIndicator
        )
    }
}

// MARK: - Styles

extension PlayerViewController {
    
    private func style() {
        
        Styles.apply(contentView: view)
        Styles.apply(activityIndicator: activityIndicator)
        Styles.apply(titleLabel: titleLabel)
    }
}
