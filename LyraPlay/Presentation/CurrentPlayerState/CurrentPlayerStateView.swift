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

    private let blurView = UIVisualEffectView()
    private let textGroup = UIStackView()
    private let titleLabel = UILabel()
    private let descriptionLabel = UILabel()
    private let imageView = UIImageView()
    private let togglePlayButton = UIImageView()
    private let separatorView = UIView()
    
    private var observers = Set<AnyCancellable>()
    private var playerStateObserver: AnyCancellable?
    
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
        playerStateObserver = nil
    }
}

// MARK: - Bind ViewModel

extension CurrentPlayerStateView {
    
    private func bind(to viewModel: CurrentPlayerStateViewModel) {
        
        viewModel.state
            .receive(on: DispatchQueue.main)
            .sink { [weak self] state in self?.updateState(state)}
            .store(in: &observers)
    }
    
    private func updateMediaInfo(_ mediaInfo: MediaInfo) {
        
        imageView.image = UIImage(data: mediaInfo.coverImage)!
        titleLabel.text = mediaInfo.title
        descriptionLabel.text = mediaInfo.artist
    }
    
    private func updatePlayerState(_ newState: PlayerState) {
        
        switch newState {

        case .stopped, .paused:
            Styles.apply(playButton: togglePlayButton)

        case .playing:
            Styles.apply(pauseButton: togglePlayButton)
        }
    }
    
    private func observePlayerState(from state: CurrentValueSubject<PlayerState, Never>) {
        
        playerStateObserver = state
            .receive(on: DispatchQueue.main)
            .sink { [weak self] newState in
            
            self?.updatePlayerState(newState)
        }
    }
    
    private func updateState(_ state: CurrentPlayerStateViewModelState) {
        
        playerStateObserver = nil
        
        switch state {
        
        case .loading:
            isHidden = true
            break
        
        case .notActive:
            isHidden = true
            break
            
        case .active(let mediaInfo, let playerState):
            isHidden = false
            updateMediaInfo(mediaInfo)
            observePlayerState(from: playerState)
            
        }
    }
}

// MARK: - Setup Views

extension CurrentPlayerStateView {
    
    @objc
    private func didTapBackground() {
        
        viewModel.open()
    }
    
    @objc
    private func didTapTogglePlayButton() {
        
        viewModel.togglePlay()
    }
    
    private func setupViews() {
        
        let backgroundTapRecognizer = UITapGestureRecognizer(
            target: self,
            action: #selector(self.didTapBackground)
        )
        addGestureRecognizer(backgroundTapRecognizer)
        
        let toogleButtonTapRecognizer = UITapGestureRecognizer(
            target: self,
            action: #selector(self.didTapTogglePlayButton)
        )
        
        togglePlayButton.isUserInteractionEnabled = true
        togglePlayButton.addGestureRecognizer(toogleButtonTapRecognizer)
        
        addSubview(blurView)
        addSubview(imageView)
        
        textGroup.addArrangedSubview(titleLabel)
        textGroup.addArrangedSubview(descriptionLabel)
        
        addSubview(textGroup)
        addSubview(togglePlayButton)
        addSubview(separatorView)
    }
}

// MARK: - Layout
extension CurrentPlayerStateView {
    
    private func layout() {
        
        Layout.apply(
            view: self,
            blurView: blurView,
            imageView: imageView,
            textGroup: textGroup,
            titleLabel: titleLabel,
            descriptionLabel: descriptionLabel,
            togglePlayButton: togglePlayButton,
            separatorView: separatorView
        )
    }
}

// MARK: - Styles

extension CurrentPlayerStateView {
    
    private func style() {
        
        Styles.apply(contentView: self)
        Styles.apply(blurView: blurView)
        Styles.apply(imageView: imageView)
        Styles.apply(titleLabel: titleLabel)
        Styles.apply(descriptionLabel: descriptionLabel)
        Styles.apply(separator: separatorView)
    }
}

