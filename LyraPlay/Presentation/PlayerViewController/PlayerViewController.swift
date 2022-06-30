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
    }
}

// MARK: - Setup Views

extension PlayerViewController {
    
    private func setupViews() {
        
        playbackGroup.addArrangedSubview(playButton)
        
        mainGroup.addSubview(imageView)
        mainGroup.addSubview(playbackGroup)
        view.addSubview(mainGroup)
    }
}

// MARK: - Layout

extension PlayerViewController {
    
    private func style() {
        
        Styles.apply(contentView: view)
    }
}
