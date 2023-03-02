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
    private let infoGroup = UIView()
    private let backgroundImageView = UIImageView()
    private let coverImageView = UIImageView()
    
    private let titleLabel = UILabel()
    private let subtitleLabel = UILabel()
    
    private let sliderView = UISlider()
    
    private let buttonsGroup = UIView()
    private let goForwardButton = UIImageView()
    private let goBackwardButton = UIImageView()
    
    private let subtitlesPresenterView = SubtitlesPresenterView()
    
    private let blurView = UIVisualEffectView()
    
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

            let image = UIImage(data: coverImage)
            
            coverImageView.image = image
            backgroundImageView.image = image
        }
        
        contentGroup.isHidden = false
        activityIndicator.stopAnimating()
        
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
        
        view.addSubview(backgroundImageView)
        view.addSubview(activityIndicator)
        
        view.addSubview(blurView)
        view.addSubview(subtitlesPresenterView)

        infoGroup.addSubview(titleLabel)
        infoGroup.addSubview(subtitleLabel)
        infoGroup.addSubview(coverImageView)
        
        view.addSubview(infoGroup)
        
    }
}

// MARK: - Layout
extension CurrentPlayerStateDetailsViewController {
    
    private func layout() {
        
        Layout.apply(
            infoGroup: infoGroup,
            coverImageView: coverImageView,
            titleLabel: titleLabel,
            subtitleLabel: subtitleLabel
        )
        
        Layout.apply(
            contentView: view,
            infoGroup: infoGroup
        )

        Layout.apply(
            contentView: view,
            backgroundImageView: backgroundImageView
        )
        
        Layout.apply(
            contentView: view,
            subtitlesPresenterView: subtitlesPresenterView
        )

        Layout.apply(
            contentView: view,
            activityIndicator: activityIndicator
        )
        
        Layout.apply(
            contentView: view,
            blurView: blurView
        )
    }
}

// MARK: - Styles

extension CurrentPlayerStateDetailsViewController {
    
    private func style() {
        
        Styles.apply(contentView: view)
        Styles.apply(activityIndicator: activityIndicator)
        Styles.apply(backgroundImageView: backgroundImageView)
        Styles.apply(slider: sliderView)
        
        Styles.apply(goForwardButton: goForwardButton)
        Styles.apply(goBackwardButton: goBackwardButton)
        
        Styles.apply(titleLabel: titleLabel)
        Styles.apply(subtitleLabel: subtitleLabel)
        Styles.apply(blurView: blurView)
    }
}
