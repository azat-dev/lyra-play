//
//  MediaLibraryBrowserCell.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 27.06.22.
//

import Foundation
import UIKit

public final class MediaLibraryBrowserCell: UITableViewCell {
    
    // MARK: - Properties
    
    public static let reuseIdentifier = "MediaLibraryBrowserCell"

    private let textGroup = UIStackView()
    private let titleLabel = UILabel()
    private let descritionLabel = UILabel()
    private let coverImageView = UIImageView()
    private let bottomBorder = UIView()
    
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

extension MediaLibraryBrowserCell {

    func fill(with viewModel: MediaLibraryBrowserCellViewModel) {
        
        titleLabel.text = viewModel.title
        descritionLabel.text = viewModel.description
        coverImageView.image = viewModel.image
    }
}

// MARK: - Setup views

extension MediaLibraryBrowserCell {

    private func setupViews() {
        
        textGroup.axis = .vertical
        
        textGroup.addArrangedSubview(titleLabel)
        textGroup.addArrangedSubview(descritionLabel)
        
        contentView.addSubview(textGroup)
        contentView.addSubview(coverImageView)
        contentView.addSubview(bottomBorder)
    }
}

// MARK: - Style

extension MediaLibraryBrowserCell {

    private func style() {

        backgroundView = nil
        backgroundColor = .clear
        
        Styles.apply(contentView: contentView)
        Styles.apply(coverImageView: coverImageView)
        Styles.apply(titleLabel: titleLabel)
        Styles.apply(descriptionLabel: descritionLabel)
        Styles.apply(bottomBorder: bottomBorder)
    }
}

// MARK: - Layout

extension MediaLibraryBrowserCell {
    
    private func layout() {
        
        Layout.apply(
            contentView: contentView,
            coverImageView: coverImageView,
            textGroup: textGroup,
            titleLabel: titleLabel,
            descriptionLabel: descritionLabel,
            bottomBorder: bottomBorder
        )
    }
}
