//
//  LibraryItemViewController.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 03.07.22.
//

import Foundation
import UIKit

public final class LibraryItemViewController: UIViewController, LibraryItemView {
    
    private let viewModel: LibraryItemViewModel
    
    private var activityIndicator = UIActivityIndicatorView()
    private var imageView = ImageViewShadowed()
    private var titleLabel = UILabel()
    private var artistLabel = UILabel()
    private var durationLabel = UILabel()
    private var playButton = UIButton()
    private var addSubtitlesButton = UIButton()
    
    private var mainGroup = UIView()
    private var subtitlesPresenter = SubtitlesPresenterView()
    
    public init(viewModel: LibraryItemViewModel) {
        
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        setup()
        
        Task {
            await viewModel.load()
        }
    }
    
    private func setup() {
        
        setupViews()
        style()
        layout()
        bind(to: viewModel)
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
    
    private func showSubtitles() {
        
        subtitlesPresenter.viewModel = viewModel.subtitlesPresenterViewModel.value
        subtitlesPresenter.isHidden = false
    }
    
    private func hideSubtitles() {
        subtitlesPresenter.isHidden = true
    }

    private func bind(to viewModel: LibraryItemViewModel) {
        
        viewModel.info.observe(on: self, queue: .main) { [weak self] mediaInfo in
            
            guard let self = self else {
                return
            }

            guard let mediaInfo = mediaInfo else {
                self.updateLoading(true)
                return
            }

            self.imageView.imageView.image = UIImage(data: mediaInfo.coverImage)!
            self.titleLabel.text = mediaInfo.title
            self.artistLabel.text = mediaInfo.artist
            self.durationLabel.text = mediaInfo.duration
            self.updateLoading(false)
        }

        viewModel.isPlaying.observe(on: self, queue: .main) { [weak self] isPlaying in
            
            guard let self = self else {
                return
            }
            
            guard isPlaying else {
                Styles.apply(playButton: self.playButton)
                self.showSubtitles()
                return
            }
            
            Styles.apply(pauseButton: self.playButton)
        }
        
        viewModel.subtitlesPresenterViewModel.observe(on: self, queue: .main) { [weak self] model in
            
            guard model != nil else {
                self?.hideSubtitles()
                return
            }
            
            self?.showSubtitles()
        }
    }
}

// MARK: - Setup Views

extension LibraryItemViewController {
    
    @objc
    private func didTogglePlay() {
        
        Task {
            await viewModel.togglePlay()
        }
    }
    
    @objc
    private func didTapAttachSubtitles() {
        
        Task {
            await viewModel.attachSubtitles(language: "English")
        }
    }
    
    private func setupViews() {
        
        mainGroup.addSubview(imageView)
        mainGroup.addSubview(titleLabel)
        mainGroup.addSubview(artistLabel)
        mainGroup.addSubview(durationLabel)
        mainGroup.addSubview(playButton)
        mainGroup.addSubview(addSubtitlesButton)
        
        view.addSubview(activityIndicator)
        view.addSubview(mainGroup)
        
        view.addSubview(subtitlesPresenter)
        
        playButton.addTarget(
            self,
            action: #selector(Self.didTogglePlay),
            for: .touchUpInside
        )
        
        addSubtitlesButton.addTarget(
            self,
            action: #selector(Self.didTapAttachSubtitles),
            for: .touchUpInside
        )
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
            artistLabel: artistLabel,
            durationLabel: durationLabel,
            playButton: playButton,
            attachSubtitlesButton: addSubtitlesButton
        )
        
        subtitlesPresenter.constraintTo(view: view)
    }
}

// MARK: - Styles

extension LibraryItemViewController {
    
    private func style() {
        
        Styles.apply(contentView: view)
        Styles.apply(imageView: imageView)
        Styles.apply(titleLabel: titleLabel)
        Styles.apply(artistLabel: artistLabel)
        Styles.apply(durationLabel: durationLabel)
        Styles.apply(playButton: playButton)
        Styles.apply(attachSubtitlesButton: addSubtitlesButton)
    }
}

