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
    private let coverImageView = ImageViewShadowed()
    
    private let titleLabel = UILabel()
    private let subtitleLabel = UILabel()
    
    private let controlsGroup = UIView()
    private let sliderView = UISlider()
    
    private let togglePlayButton = UIImageView()
    private let goForwardButton = UIImageView()
    private let goBackwardButton = UIImageView()
    
    private let subtitlesPresenterView = SubtitlesPresenterView()
    
    private let blurView = UIVisualEffectView()
    
    private var observers = Set<AnyCancellable>()
    
    // MARK: - Initializers
    
    public init(
        viewModel: CurrentPlayerStateDetailsViewModel
    ) {
        
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
    
    public override func viewDidDisappear(_ animated: Bool) {

        super.viewDidDisappear(animated)
        viewModel.dispose()
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
    
    private func updateSlider(value: Float) {
        
        sliderView.value = value
    }
    
    private func updateToggleButton(isPlaying: Bool) {
        
        guard isPlaying else {
            Styles.apply(playButton: togglePlayButton)
            return
        }
        
        Styles.apply(pauseButton: togglePlayButton)
    }
    
    private func updateActiveState(_ data: CurrentPlayerStateDetailsViewModelPresentation) {
        
        titleLabel.text = data.title
        subtitleLabel.text = data.subtitle
        
        if let coverImage = data.coverImage {

            let image = UIImage(data: coverImage)
            
            coverImageView.imageView.image = image
            backgroundImageView.image = image
        }
        
        contentGroup.isHidden = false
        activityIndicator.stopAnimating()
        
        subtitlesPresenterView.viewModel = data.subtitlesPresenterViewModel
        
        let isPlaying = data.isPlaying

        updateToggleButton(isPlaying: isPlaying)
        
        sliderView.maximumValue = viewModel.duration
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
            .receive(on: DispatchQueue.main)
            .sink {  [weak self] state in self?.updateState(state) }
            .store(in: &observers)
        
        viewModel.sliderValue
            .receive(on: DispatchQueue.main)
            .sink { [weak self] newValue in
                self?.updateSlider(value: newValue)
            }.store(in: &observers)
    }
}

// MARK: - Setup Views

extension CurrentPlayerStateDetailsViewController {
    
    @objc
    private func didTapTogglePlayButton() {
        
        viewModel.togglePlay()
    }
    
    @objc
    private func didTapForwardButton() {
        
        dismiss(animated: true)
//        viewModel.moveForward()
    }
    
    @objc
    private func didTapBackwardButton() {
        dismiss(animated: true)
//        viewModel.moveBackward()
    }
    
    private func setupTogglePlayButton() {
        
        let tapRecognizer = UITapGestureRecognizer(
            target: self,
            action: #selector(self.didTapTogglePlayButton))
        
        togglePlayButton.isUserInteractionEnabled = true
        togglePlayButton.addGestureRecognizer(tapRecognizer)
    }
    
    private func setupForwardButton() {
        
        let tapRecognizer = UITapGestureRecognizer(
            target: self,
            action: #selector(self.didTapForwardButton)
        )
        
        goForwardButton.addGestureRecognizer(tapRecognizer)
        goForwardButton.isUserInteractionEnabled = true
    }
    
    private func setupBackwardButton() {
        
        let tapRecognizer = UITapGestureRecognizer(
            target: self,
            action: #selector(self.didTapBackwardButton)
        )
        
        goBackwardButton.addGestureRecognizer(tapRecognizer)
        goBackwardButton.isUserInteractionEnabled = true
    }
    
    @objc
    private func didChangeSliderView() {
        
        let time = sliderView.value
        viewModel.seek(time: time)
    }
    
    @objc
    private func didStartChangeSlider() {
        
        viewModel.startSeeking()
    }
    
    @objc
    private func didEndChangeSlider() {
        
        viewModel.endSeeking(time: sliderView.value)
    }
    
    private func setupSlider() {
        
        sliderView.isContinuous = true
        
        sliderView.addTarget(
            self,
            action: #selector(self.didChangeSliderView),
            for: .valueChanged
        )
        
        sliderView.addTarget(
            self,
            action: #selector(self.didStartChangeSlider),
            for: .touchDown
        )
        
        sliderView.addTarget(
            self,
            action: #selector(self.didEndChangeSlider),
            for: [.touchUpInside, .touchUpOutside]
        )
    }
    
    private func setupViews() {
        
        setupTogglePlayButton()
        setupForwardButton()
        setupBackwardButton()
        setupSlider()
        
        view.addSubview(backgroundImageView)
        view.addSubview(activityIndicator)
        
        view.addSubview(blurView)
        view.addSubview(subtitlesPresenterView)

        infoGroup.addSubview(titleLabel)
        infoGroup.addSubview(subtitleLabel)
        infoGroup.addSubview(coverImageView)
        
        view.addSubview(infoGroup)
        
        controlsGroup.addSubview(sliderView)
        controlsGroup.addSubview(goBackwardButton)
        controlsGroup.addSubview(togglePlayButton)
        controlsGroup.addSubview(goForwardButton)
        
        view.addSubview(controlsGroup)
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
            infoGroup: infoGroup,
            controlsGroup: controlsGroup,
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
        
        Layout.apply(
            contentView: view,
            controlsGroup: controlsGroup
        )
        
        Layout.apply(
            controlsGroup: controlsGroup,
            sliderView: sliderView,
            togglePlayButton: togglePlayButton,
            goBackwardButton: goBackwardButton,
            goForwardButton: goForwardButton
        )
    }
}

// MARK: - Styles

extension CurrentPlayerStateDetailsViewController {
    
    private func style() {
        
        Styles.apply(contentView: view)
        Styles.apply(activityIndicator: activityIndicator)
        Styles.apply(coverImageView: coverImageView)
        Styles.apply(backgroundImageView: backgroundImageView)
        
        Styles.apply(slider: sliderView)
        Styles.apply(goForwardButton: goForwardButton)
        Styles.apply(playButton: togglePlayButton)
        Styles.apply(goBackwardButton: goBackwardButton)
        
        Styles.apply(titleLabel: titleLabel)
        Styles.apply(subtitleLabel: subtitleLabel)
        Styles.apply(blurView: blurView)
    }
}
