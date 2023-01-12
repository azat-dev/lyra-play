//
//  CurrentPlayerStateDetailsViewController.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 30.09.22.
//

import Foundation
import Combine
import UIKit

public final class CurrentPlayerStateDetailsViewController: UIViewController, CurrentPlayerStateDetailsView {
    
    // MARK: - Properties
    
    private let viewModel: CurrentPlayerStateDetailsViewModel
    
    private let activityIndicator = UIActivityIndicatorView()
    private let contentGroup = UIView()
    private let coverImageView = UIImageView()
    
    private let titleLabel = UILabel()
    private let subtitleLabel = UILabel()
    
    private let sliderView = UISlider()
    
    private let buttonsGroup = UIView()
    private let togglePlayButton = UIImageView()
    private let goForwardButton = UIImageView()
    private let goBackwardButton = UIImageView()
    
    private let subtitlesPresenterView = SubtitlesPresenterView()
    
    private var observers = Set<AnyCancellable>()
    
    // MARK: - Initializers
    
    public init(viewModel: CurrentPlayerStateDetailsViewModel) {
        
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        observers.removeAll()
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

extension CurrentPlayerStateDetailsViewController {
    
    private func updateActiveState(_ data: CurrentPlayerStateDetailsViewModelPresentation) {
        
        titleLabel.text = data.title
        subtitleLabel.text = data.subtitle
        
        if let coverImage = data.coverImage {
            
            coverImageView.image = UIImage(data: coverImage)
        }
        
        contentGroup.isHidden = false
        activityIndicator.stopAnimating()
        
        if data.isPlaying {
            
            Styles.apply(pauseButton: togglePlayButton)
        } else {
            
            Styles.apply(playButton: togglePlayButton)
        }
        
        subtitlesPresenterView.viewModel = data.subtitlesPresenterViewModel
    }
    
    private func updateLoadingState() {
        
        contentGroup.isHidden = true
        activityIndicator.startAnimating()
    }
    
    private func updateState(_ newState: CurrentPlayerStateDetailsViewModelState) {
        
        switch newState {
            
        case .loading:
            updateLoadingState()
            
        case .notActive:
            updateLoadingState()
            
        case .active(let data):
            updateActiveState(data)
        }
    }
    
    private func bind(to viewModel: CurrentPlayerStateDetailsViewModel) {
        
        viewModel.state
            .receive(on: RunLoop.main)
            .sink {  [weak self] state in self?.updateState(state) }
            .store(in: &observers)
    }
}

// MARK: - Setup Views

extension CurrentPlayerStateDetailsViewController {
    
    @objc
    private func didTapTogglePlayButton() {
        
        viewModel.togglePlay()
    }
    
    private func setupViews() {
        
        let togglePlayButtonGestureRecognizer = UITapGestureRecognizer(
            target: self,
            action: #selector(self.didTapTogglePlayButton)
        )
        
        togglePlayButton.isUserInteractionEnabled = true
        togglePlayButton.addGestureRecognizer(togglePlayButtonGestureRecognizer)

        buttonsGroup.addSubview(goForwardButton)
        buttonsGroup.addSubview(togglePlayButton)
        buttonsGroup.addSubview(goBackwardButton)
        
        
        contentGroup.addSubview(coverImageView)
        contentGroup.addSubview(titleLabel)
        contentGroup.addSubview(subtitleLabel)
        
        contentGroup.addSubview(sliderView)
        contentGroup.addSubview(buttonsGroup)

        view.addSubview(contentGroup)
        view.addSubview(activityIndicator)
        
        view.addSubview(subtitlesPresenterView)
    }
}

// MARK: - Layout
extension CurrentPlayerStateDetailsViewController {
    
    private func layout() {

        Layout.apply(
            buttonsGroup: buttonsGroup,
            togglePlayButton: togglePlayButton,
            goForwardButton: goForwardButton,
            goBackwardButton: goBackwardButton
        )

        Layout.apply(
            contentGroup: contentGroup,
            coverImageView: coverImageView,
            titleLabel: titleLabel,
            subtitleLabel: subtitleLabel,
            slider: sliderView,
            buttonsGroup: buttonsGroup
        )
        
        Layout.apply(
            contentView: contentGroup,
            subtitlesPresenterView: subtitlesPresenterView
        )

        Layout.apply(
            view: view,
            activityIndicator: activityIndicator,
            contentGroup: contentGroup
        )
    }
}

// MARK: - Styles

extension CurrentPlayerStateDetailsViewController {
    
    private func style() {
        
        Styles.apply(contentView: view)
        Styles.apply(activityIndicator: activityIndicator)
        Styles.apply(coverImage: coverImageView)
        Styles.apply(slider: sliderView)
        
        Styles.apply(goForwardButton: goForwardButton)
        Styles.apply(goBackwardButton: goBackwardButton)
        
        Styles.apply(titleLabel: titleLabel)
        Styles.apply(subtitleLabel: subtitleLabel)
    }
}
