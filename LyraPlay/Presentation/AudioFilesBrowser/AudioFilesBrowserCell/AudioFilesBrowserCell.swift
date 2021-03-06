//
//  AudioFilesBrowserCell.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 27.06.22.
//

import Foundation
import UIKit

public final class AudioFilesBrowserCell: UITableViewCell {
    
    public static var reuseIdentifier = "AudioFilesBrowserCell"

    private var textGroup = UIStackView()
    private var titleLabel = UILabel()
    private var descritionLabel = UILabel()
    private var coverImageView = UIImageView()
    
    public override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setup()
    }
    
    public required init?(coder: NSCoder) {
        
        super.init(coder: coder)
        setup()
    }
    
    private func setup() {
        setupViews()
        layout()
        style()
    }
}

// MARK: - Fill from viewModel

extension AudioFilesBrowserCell {

    func fill(with viewModel: AudioFilesBrowserCellViewModel) {
        
        titleLabel.text = viewModel.title
        descritionLabel.text = viewModel.description
        coverImageView.image = viewModel.image
    }
}

// MARK: - Setup views

extension AudioFilesBrowserCell {

    private func setupViews() {
        
        textGroup.axis = .vertical
        
        textGroup.addArrangedSubview(titleLabel)
        textGroup.addArrangedSubview(descritionLabel)
        
        contentView.addSubview(textGroup)
        contentView.addSubview(coverImageView)
    }
}

// MARK: - Style

extension AudioFilesBrowserCell {

    private func style() {

        backgroundView = nil
        backgroundColor = .clear
        
        Styles.apply(contentView: contentView)
        Styles.apply(coverImageView: coverImageView)
        Styles.apply(titleLabel: titleLabel)
        Styles.apply(descriptionLabel: descritionLabel)
    }
}

// MARK: - Layout

extension AudioFilesBrowserCell {
    
    private func layout() {
        
        Layout.apply(
            contentView: contentView,
            coverImageView: coverImageView,
            textGroup: textGroup,
            titleLabel: titleLabel,
            descriptionLabel: descritionLabel
        )
    }
}
