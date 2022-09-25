//
//  DictionaryListBrowserCell.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 19.08.22.
//

import Foundation
import UIKit

public final class DictionaryListBrowserCell: UITableViewCell {
    
    // MARK: - Properties
    
    public static let reuseIdentifier = "DictionaryListBrowserCell"
    
    private var viewModel: DictionaryListBrowserItemViewModel!
    
    private let textGroup = UIStackView()
    private let titleLabel = UILabel()
    private let descritionLabel = UILabel()
    private let bottomBorder = UIView()
    
    private let playButton = UIImageView()
    
    private var tapRecognizer: UITapGestureRecognizer?
    
    // MARK: - Initializers
    
    public override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setup()
    }
    
    public required init?(coder: NSCoder) {
        
        super.init(coder: coder)
        setup()
    }
    
    // MARK: - Methods
    
    private func setup() {
        setupViews()
        layout()
        style()
    }
}

// MARK: - Fill from viewModel

extension DictionaryListBrowserCell {

    func fill(with viewModel: DictionaryListBrowserItemViewModel) {
        
        self.viewModel = viewModel
        
        titleLabel.text = viewModel.title
        descritionLabel.text = viewModel.description
        
        if viewModel.isSoundPlaying {

            Styles.apply(activePlayButton: playButton)
        } else {
            Styles.apply(playButton: playButton)
        }
    }
}

// MARK: - Setup views

extension DictionaryListBrowserCell {

    @objc
    private func didTapPlay() {
        
        viewModel.playSound()
    }
    
    private func setupViews() {
        
        let tapRecognizer = UITapGestureRecognizer(
            target: self,
            action: #selector(self.didTapPlay)
        )
        
        playButton.isUserInteractionEnabled = true
        playButton.addGestureRecognizer(tapRecognizer)
        self.tapRecognizer = tapRecognizer
        
        textGroup.axis = .vertical
        
        textGroup.addArrangedSubview(titleLabel)
        textGroup.addArrangedSubview(descritionLabel)
        
        textGroup.addSubview(playButton)
        
        contentView.addSubview(textGroup)
        contentView.addSubview(bottomBorder)
    }
}

// MARK: - Style

extension DictionaryListBrowserCell {

    private func style() {

        backgroundView = nil
        backgroundColor = .clear
        
        Styles.apply(contentView: contentView)
        Styles.apply(titleLabel: titleLabel)
        Styles.apply(descriptionLabel: descritionLabel)
        Styles.apply(bottomBorder: bottomBorder)
        Styles.apply(playButton: playButton)
    }
}

// MARK: - Layout

extension DictionaryListBrowserCell {
    
    private func layout() {
        
        Layout.apply(
            contentView: contentView,
            textGroup: textGroup,
            titleLabel: titleLabel,
            descriptionLabel: descritionLabel,
            bottomBorder: bottomBorder,
            playButton: playButton
        )
    }
}

