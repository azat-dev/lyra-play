//
//  CurrentPlayerStateView.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 15.09.22.
//

import Foundation
import Combine
import UIKit

public final class CurrentPlayerStateView: UIView {
    
    // MARK: - Properties
    
    private let viewModel: CurrentPlayerStateViewModel
    
    
    private let textGroup = UIStackView()
    private let titleLabel = UILabel()
    private let descriptionLabel = UILabel()
    private let imageView = UIImageView()
    private let togglePlayButton = UIImageView()
    
    private var observers = Set<AnyCancellable>()
    
    public init(viewModel: CurrentPlayerStateViewModel) {
        
        self.viewModel = viewModel
        super.init(frame: .zero)
        
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
    
    deinit {
        observers.removeAll()
    }
}

// MARK: - Bind ViewModel

extension CurrentPlayerStateView {
    
    private func bind(to viewModel: CurrentPlayerStateViewModel) {
        
        viewModel.state
            .receive(on: RunLoop.main)
            .sink { [weak self] state in self?.updateState(state)}
            .store(in: &observers)
    }
    
    private func updateActiveState(mediaInfo: MediaInfo, state: PlayerState) {
        
        imageView.image = UIImage(data: mediaInfo.coverImage)!
        titleLabel.text = mediaInfo.title
        descriptionLabel.text = mediaInfo.artist
        
        switch state {

        case .stopped, .paused:
            Styles.apply(playButton: togglePlayButton)

        case .playing:
            Styles.apply(pauseButton: togglePlayButton)
        }
    }
    
    private func updateState(_ state: CurrentPlayerStateViewModelState) {
        
        switch state {
        
        case .loading:
            break
        
        case .notActive:
            break
            
        case .active(let mediaInfo, let state):
            updateActiveState(mediaInfo: mediaInfo, state: state)
        }
    }
}

// MARK: - Setup Views

extension CurrentPlayerStateView {
    
    @objc
    private func didTap() {
        
        viewModel.open()
    }
    
    private func setupViews() {
        
        let tapRecognizer = UITapGestureRecognizer(
            target: self,
            action: #selector(self.didTap)
        )
        
        addGestureRecognizer(tapRecognizer)
        addSubview(imageView)
        
        textGroup.addArrangedSubview(titleLabel)
        textGroup.addArrangedSubview(descriptionLabel)
        
        addSubview(textGroup)
        addSubview(togglePlayButton)
    }
}

// MARK: - Layout
extension CurrentPlayerStateView {
    
    private func layout() {
        
        Layout.apply(
            view: self,
            imageView: imageView,
            textGroup: textGroup,
            titleLabel: titleLabel,
            descriptionLabel: descriptionLabel,
            togglePlayButton: togglePlayButton
        )
    }
}

// MARK: - Styles

extension CurrentPlayerStateView {
    
    private func style() {
        
        Styles.apply(contentView: self)
        Styles.apply(imageView: imageView)
        Styles.apply(titleLabel: titleLabel)
        Styles.apply(descriptionLabel: descriptionLabel)
    }
}

